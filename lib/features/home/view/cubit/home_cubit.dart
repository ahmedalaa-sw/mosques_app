import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosques_app/core/errors/failures.dart';
import 'package:mosques_app/core/services/adhan_prayer_service.dart';
import 'package:mosques_app/core/services/background_reschedule_service.dart';
import 'package:mosques_app/core/services/notification_service.dart';
import 'package:mosques_app/core/services/shared_location_service.dart';
import 'package:mosques_app/core/utils/app_shared_preferences.dart';
import 'package:mosques_app/core/utils/location_utils.dart';
import 'package:mosques_app/core/utils/timezone_resolver.dart';
import 'package:mosques_app/features/home/model/home_model.dart';
import 'package:mosques_app/features/home/model/home_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> with WidgetsBindingObserver {
  final HomeRepository repository;

  AladhanPrayerTimesModel? _loadedPrayerTimes;
  Timer? _prayerTransitionTimer;

  HomeCubit({required this.repository}) : super(const HomeInitial()) {
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> loadPrayerTimes() async {
    try {
      final hadCache = await _tryInstantLoadFromCache();
      if (!hadCache) emit(const HomeLoading());

      bool hasPermission = await repository.hasLocationPermission();
      if (!hasPermission) {
        bool granted = await repository.requestLocationPermission();
        if (!granted) {
          if (!hadCache) {
            emit(
              const HomePermissionDenied(
                message:
                    'Location permission is required to display prayer times. '
                    'Please enable it in app settings.',
              ),
            );
          }
          return;
        }
      }

      // Auto-retry GPS fetch up to 3 times before surfacing an error.
      Failure? lastFailure;
      for (int attempt = 0; attempt < 3; attempt++) {
        if (attempt > 0) await Future.delayed(const Duration(seconds: 2));

        final result = await repository.getPrayerTimesForCurrentLocation();
        bool succeeded = false;
        result.fold(
          (failure) => lastFailure = failure,
          (prayerTimes) { _onLoaded(prayerTimes); succeeded = true; },
        );
        if (succeeded) return;
      }

      // All attempts failed — only surface error if no cached state is showing.
      if (!hadCache) {
        if (lastFailure is ServerFailure && lastFailure!.statusCode == 403) {
          emit(HomePermissionDenied(message: lastFailure!.message));
        } else {
          emit(HomeError(
            message: lastFailure?.message ?? '',
            statusCode: lastFailure is ServerFailure
                ? (lastFailure as ServerFailure).statusCode
                : null,
          ));
        }
      }
    } catch (e) {
      debugPrint('[Home] CATCH — $e');
      if (state is! HomeLoaded) {
        emit(HomeError(
          message: e.toString().replaceFirst('Exception: ', ''),
          statusCode: null,
        ));
      }
    }
  }

  /// Instantly shows prayer times from cached location without any GPS call.
  /// Returns true if cached coordinates existed and data was emitted.
  Future<bool> _tryInstantLoadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble(BackgroundRescheduleService.prefsLat);
      final lng = prefs.getDouble(BackgroundRescheduleService.prefsLng);
      if (lat == null || lng == null) return false;

      final countryCode =
          prefs.getString(LocationUtils.countryCodePrefsKey) ?? 'US';
      final ianaTimezone = prefs.getString(TimezoneResolver.ianaTimezonePrefsKey) ??
          TimezoneResolver.fromCountryCode(countryCode);
      final result = AdhanPrayerService.calculatePrayerTimesSync(
        latitude: lat,
        longitude: lng,
        countryCode: countryCode,
        ianaTimezone: ianaTimezone,
      );
      _onCacheLoaded(
        AladhanPrayerTimesModel.fromPrayerCalculationResult(
          result: result,
          latitude: lat,
          longitude: lng,
        ),
      );
      return true;
    } catch (e) {
      debugPrint('[Home] _tryInstantLoadFromCache: $e');
      return false;
    }
  }

  /// Lightweight display-only load from cache: emits state and schedules the
  /// prayer timer, but skips notification scheduling and location caching
  /// (those run once fresh GPS data arrives in [_onLoaded]).
  void _onCacheLoaded(AladhanPrayerTimesModel prayerTimes) {
    _loadedPrayerTimes = prayerTimes;
    final currentPrayer = _getCurrentPrayerName(prayerTimes);
    emit(HomeLoaded(
      prayerTimes: prayerTimes,
      prayers: prayerTimes.toHousePrayerModels(currentPrayer),
      currentPrayerName: currentPrayer,
    ));
    _scheduleNextPrayerTransition(prayerTimes);
  }

  Future<void> refreshPrayerTimes() => loadPrayerTimes();

  Future<void> refreshAfterManualLocationChange() async {
    SharedLocationService.instance.invalidateCache();
    try {
      emit(const HomeLoading());
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble(BackgroundRescheduleService.prefsLat);
      final lng = prefs.getDouble(BackgroundRescheduleService.prefsLng);
      if (lat == null || lng == null) {
        await loadPrayerTimes();
        return;
      }
      final countryCode = await LocationUtils.getCountryCode(lat, lng, forceRefresh: true);
      final ianaTimezone = TimezoneResolver.fromCountryCode(countryCode);
      final result = AdhanPrayerService.calculatePrayerTimesSync(
        latitude: lat,
        longitude: lng,
        countryCode: countryCode,
        ianaTimezone: ianaTimezone,
      );
      final model = AladhanPrayerTimesModel.fromPrayerCalculationResult(
        result: result,
        latitude: lat,
        longitude: lng,
      );
      _onLoaded(model);
      await BackgroundRescheduleService.cacheLastLocation(lat, lng);
      await AppPreferences.saveString(LocationUtils.countryCodePrefsKey, countryCode);
      await AppPreferences.saveString(TimezoneResolver.ianaTimezonePrefsKey, ianaTimezone);
    } catch (e) {
      debugPrint('[Home] refreshAfterManualLocationChange error: $e');
      await loadPrayerTimes();
    }
  }

  Future<void> loadPrayerTimesForLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      emit(const HomeLoading());
      final result = await repository.getPrayerTimesForLocation(
        latitude: latitude,
        longitude: longitude,
      );
      result.fold(
        (failure) => emit(
          HomeError(
            message: failure.message,
            statusCode: failure is ServerFailure ? failure.statusCode : null,
          ),
        ),
        (prayerTimes) => _onLoaded(prayerTimes),
      );
    } catch (e) {
      emit(
        HomeError(
          message: e.toString().replaceFirst('Exception: ', ''),
          statusCode: null,
        ),
      );
    }
  }

  // ── Prayer transition timer ───────────────────────────────────────────────

  void _onLoaded(AladhanPrayerTimesModel prayerTimes) {
    _loadedPrayerTimes = prayerTimes;
    final currentPrayer = _getCurrentPrayerName(prayerTimes);
    final prayers = prayerTimes.toHousePrayerModels(currentPrayer);
    emit(HomeLoaded(
      prayerTimes: prayerTimes,
      prayers: prayers,
      currentPrayerName: currentPrayer,
    ));
    _scheduleNotifications(prayerTimes);
    BackgroundRescheduleService.cacheLastLocation(
      prayerTimes.latitude,
      prayerTimes.longitude,
    );
    _cacheTimezone(prayerTimes.ianaTimezone);
    _scheduleNextPrayerTransition(prayerTimes);
  }

  Future<void> _cacheTimezone(String ianaTimezone) async {
    try {
      await AppPreferences.saveString(
        TimezoneResolver.ianaTimezonePrefsKey,
        ianaTimezone,
      );
    } catch (_) {
      // Non-critical — next load will resolve timezone again
    }
  }

  /// Sets a one-shot [Timer] that fires exactly when the next prayer starts.
  /// On firing it re-emits [HomeLoaded] with the updated active prayer and
  /// immediately schedules the timer for the prayer after that.
  ///
  /// After the last prayer of the day (Isha) the timer fires at midnight+1min
  /// so [loadPrayerTimes] can recalculate for the new date.
  ///
  /// Timer delay is computed using the prayer location's timezone so that
  /// the countdown is accurate regardless of the device's local timezone.
  void _scheduleNextPrayerTransition(AladhanPrayerTimesModel prayerTimes) {
    _prayerTransitionTimer?.cancel();

    // Use the prayer location's timezone for "now" — this is critical when
    // the device is in a different timezone than the prayer location.
    final location = tz.getLocation(prayerTimes.ianaTimezone);
    final now = tz.TZDateTime.now(location);

    final upcomingPrayerTimes = [
      _toLocationDateTime(prayerTimes.fajr, location, now),
      _toLocationDateTime(prayerTimes.sunrise, location, now),
      _toLocationDateTime(prayerTimes.dhuhr, location, now),
      _toLocationDateTime(prayerTimes.asr, location, now),
      _toLocationDateTime(prayerTimes.maghrib, location, now),
      _toLocationDateTime(prayerTimes.isha, location, now),
    ].where((t) => t.isAfter(now)).toList();

    if (upcomingPrayerTimes.isNotEmpty) {
      final next = upcomingPrayerTimes.first;
      _prayerTransitionTimer = Timer(next.difference(now), _onPrayerTransition);
    } else {
      // All prayers done for today — reload at midnight+1min in the location tz
      final midnight = tz.TZDateTime(location, now.year, now.month, now.day + 1, 0, 1);
      _prayerTransitionTimer = Timer(
        midnight.difference(now),
        loadPrayerTimes,
      );
    }
  }

  void _onPrayerTransition() {
    final prayerTimes = _loadedPrayerTimes;
    if (prayerTimes == null || state is! HomeLoaded) return;

    final currentPrayer = _getCurrentPrayerName(prayerTimes);
    final prayers = prayerTimes.toHousePrayerModels(currentPrayer);
    emit(HomeLoaded(
      prayerTimes: prayerTimes,
      prayers: prayers,
      currentPrayerName: currentPrayer,
    ));
    _scheduleNextPrayerTransition(prayerTimes);
  }

  /// Called on app resume to immediately correct any stale prayer indicator
  /// that resulted from the Dart timer being paused while the app was backgrounded.
  void _refreshCurrentPrayer() {
    final prayerTimes = _loadedPrayerTimes;
    if (prayerTimes == null) return;

    final currentPrayer = _getCurrentPrayerName(prayerTimes);
    final currentState = state;
    if (currentState is HomeLoaded &&
        currentState.currentPrayerName == currentPrayer) {
      // Prayer hasn't changed but the timer may have missed its window — reschedule.
      _scheduleNextPrayerTransition(prayerTimes);
      return;
    }
    final prayers = prayerTimes.toHousePrayerModels(currentPrayer);
    emit(HomeLoaded(
      prayerTimes: prayerTimes,
      prayers: prayers,
      currentPrayerName: currentPrayer,
    ));
    _scheduleNextPrayerTransition(prayerTimes);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshCurrentPrayer();
      // Re-schedule after returning from system settings (e.g. after the user
      // granted exact alarm permission or battery optimization exemption).
      final loaded = _loadedPrayerTimes;
      if (loaded != null) _scheduleNotifications(loaded);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Determines which prayer is currently active based on the current time
  /// in the prayer location's timezone.
  String? _getCurrentPrayerName(AladhanPrayerTimesModel prayerTimes) {
    try {
      final location = tz.getLocation(prayerTimes.ianaTimezone);
      final now = tz.TZDateTime.now(location);
      final currentMinutes = now.hour * 60 + now.minute;

      final prayers = [
        ('fajr'.tr(), _parseMinutes(prayerTimes.fajr)),
        ('sunrise'.tr(), _parseMinutes(prayerTimes.sunrise)),
        ('dhuhr'.tr(), _parseMinutes(prayerTimes.dhuhr)),
        ('asr'.tr(), _parseMinutes(prayerTimes.asr)),
        ('maghrib'.tr(), _parseMinutes(prayerTimes.maghrib)),
        ('isha'.tr(), _parseMinutes(prayerTimes.isha)),
      ];

      for (int i = 0; i < prayers.length; i++) {
        final (name, startMin) = prayers[i];
        if (i < prayers.length - 1) {
          final endMin = prayers[i + 1].$2;
          if (currentMinutes >= startMin && currentMinutes < endMin) {
            return name;
          }
        } else {
          if (currentMinutes >= startMin) return name;
        }
      }
      // midnight → fajr: still within Isha's time period
      return prayers.last.$1;
    } catch (_) {
      return null;
    }
  }

  int _parseMinutes(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length != 2) return 0;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    return h * 60 + m;
  }

  /// Converts an "HH:mm" string into a [TZDateTime] on [now]'s date in the
  /// prayer location's timezone. This is the timezone-aware replacement for the
  /// old [_toTodayDateTime] that used the device timezone.
  tz.TZDateTime _toLocationDateTime(
    String hhmm,
    tz.Location location,
    tz.TZDateTime now,
  ) {
    final parts = hhmm.split(':');
    final h = int.tryParse(parts[0]) ?? 0;
    final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    return tz.TZDateTime(location, now.year, now.month, now.day, h, m);
  }

  void _scheduleNotifications(AladhanPrayerTimesModel prayerTimes) async {
    final prefs = await SharedPreferences.getInstance();
    final azanEnabled = prefs.getBool('azan_enabled') ?? false;
    final countryCode = prefs.getString(LocationUtils.countryCodePrefsKey) ?? 'US';
    final ianaTimezone = prefs.getString(TimezoneResolver.ianaTimezonePrefsKey) ??
        prayerTimes.ianaTimezone;

    final location = tz.getLocation(ianaTimezone);
    final today = tz.TZDateTime.now(location);

    // Calculate tomorrow based on the location's timezone
    final tomorrowCalcDate = TimezoneResolver.todayAt(ianaTimezone)
        .add(const Duration(days: 1));

    Map<String, DateTime> buildDayMap(
      DateTime day,
      AladhanPrayerTimesModel times,
      tz.Location loc,
    ) {
      DateTime toDateTime(String hhmm) {
        final parts = hhmm.split(':');
        final h = int.tryParse(parts[0]) ?? 0;
        final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
        return tz.TZDateTime(loc, day.year, day.month, day.day, h, m);
      }
      return {
        'Fajr'   : toDateTime(times.fajr),
        'Sunrise': toDateTime(times.sunrise),
        'Dhuhr'  : toDateTime(times.dhuhr),
        'Asr'    : toDateTime(times.asr),
        'Maghrib': toDateTime(times.maghrib),
        'Isha'   : toDateTime(times.isha),
      };
    }

    final tomorrowResult = AdhanPrayerService.calculatePrayerTimesSync(
      latitude: prayerTimes.latitude,
      longitude: prayerTimes.longitude,
      countryCode: countryCode,
      ianaTimezone: ianaTimezone,
      date: tomorrowCalcDate,
    );
    final tomorrowModel = AladhanPrayerTimesModel.fromPrayerCalculationResult(
      result: tomorrowResult,
      latitude: prayerTimes.latitude,
      longitude: prayerTimes.longitude,
    );

    // Today's date in the location timezone for building TZDateTime
    final todayDate = DateTime(today.year, today.month, today.day);
    final tomorrowDate = DateTime(today.year, today.month, today.day)
        .add(const Duration(days: 1));

    await NotificationService.instance.schedulePrayerNotifications(
      [
        buildDayMap(todayDate, prayerTimes, location),
        buildDayMap(tomorrowDate, tomorrowModel, location),
      ],
      azanEnabled: azanEnabled,
      ianaTimezone: ianaTimezone,
    );
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    _prayerTransitionTimer?.cancel();
    return super.close();
  }
}
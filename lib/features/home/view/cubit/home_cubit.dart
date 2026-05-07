import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosques_app/core/errors/failures.dart';
import 'package:mosques_app/core/services/adhan_prayer_service.dart';
import 'package:mosques_app/core/services/background_reschedule_service.dart';
import 'package:mosques_app/core/services/notification_service.dart';
import 'package:mosques_app/core/utils/location_utils.dart';
import 'package:mosques_app/features/home/model/home_model.dart';
import 'package:mosques_app/features/home/model/home_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

      final result = await repository.getPrayerTimesForCurrentLocation();
      result.fold(
        (failure) {
          if (!hadCache) {
            if (failure is ServerFailure && failure.statusCode == 403) {
              emit(HomePermissionDenied(message: failure.message));
            } else {
              emit(
                HomeError(
                  message: failure.message,
                  statusCode: failure is ServerFailure
                      ? failure.statusCode
                      : null,
                ),
              );
            }
          }
        },
        (prayerTimes) => _onLoaded(prayerTimes),
      );
    } catch (e) {
      if (state is! HomeLoaded) {
        emit(
          HomeError(
            message: e.toString().replaceFirst('Exception: ', ''),
            statusCode: null,
          ),
        );
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
      final prayerTimes = AdhanPrayerService.calculatePrayerTimesSync(
        latitude: lat,
        longitude: lng,
        countryCode: countryCode,
      );
      _onCacheLoaded(
        AladhanPrayerTimesModel.fromAdhanPrayerTimes(
          prayerTimes: prayerTimes,
          latitude: lat,
          longitude: lng,
        ),
      );
      return true;
    } catch (_) {
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
    _scheduleNextPrayerTransition(prayerTimes);
  }

  /// Sets a one-shot [Timer] that fires exactly when the next prayer starts.
  /// On firing it re-emits [HomeLoaded] with the updated active prayer and
  /// immediately schedules the timer for the prayer after that.
  ///
  /// After the last prayer of the day (Isha) the timer fires at midnight+1min
  /// so [loadPrayerTimes] can recalculate for the new date.
  void _scheduleNextPrayerTransition(AladhanPrayerTimesModel prayerTimes) {
    _prayerTransitionTimer?.cancel();

    final now = DateTime.now();

    final upcomingPrayerTimes = [
      _toTodayDateTime(prayerTimes.fajr),
      _toTodayDateTime(prayerTimes.sunrise),
      _toTodayDateTime(prayerTimes.dhuhr),
      _toTodayDateTime(prayerTimes.asr),
      _toTodayDateTime(prayerTimes.maghrib),
      _toTodayDateTime(prayerTimes.isha),
    ].where((t) => t.isAfter(now)).toList();

    if (upcomingPrayerTimes.isNotEmpty) {
      final next = upcomingPrayerTimes.first;
      _prayerTransitionTimer = Timer(next.difference(now), _onPrayerTransition);
    } else {
      // All prayers done for today — reload at midnight for tomorrow's schedule.
      final midnight = DateTime(now.year, now.month, now.day + 1, 0, 1);
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
    if (state == AppLifecycleState.resumed) _refreshCurrentPrayer();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String? _getCurrentPrayerName(AladhanPrayerTimesModel prayerTimes) {
    try {
      final now = DateTime.now();
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
      return null;
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

  DateTime _toTodayDateTime(String hhmm) {
    final now = DateTime.now();
    final parts = hhmm.split(':');
    final h = int.tryParse(parts[0]) ?? 0;
    final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    return DateTime(now.year, now.month, now.day, h, m);
  }

  void _scheduleNotifications(AladhanPrayerTimesModel prayerTimes) async {
    final prefs = await SharedPreferences.getInstance();
    final azanEnabled = prefs.getBool('azan_enabled') ?? false;
    final countryCode = prefs.getString(LocationUtils.countryCodePrefsKey) ?? 'US';

    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));

    Map<String, DateTime> buildDayMap(DateTime day, AladhanPrayerTimesModel times) {
      DateTime toDateTime(String hhmm) {
        final parts = hhmm.split(':');
        final h = int.tryParse(parts[0]) ?? 0;
        final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
        return DateTime(day.year, day.month, day.day, h, m);
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

    final tomorrowRaw = AdhanPrayerService.calculatePrayerTimesSync(
      latitude: prayerTimes.latitude,
      longitude: prayerTimes.longitude,
      countryCode: countryCode,
      date: tomorrow,
    );
    final tomorrowModel = AladhanPrayerTimesModel.fromAdhanPrayerTimes(
      prayerTimes: tomorrowRaw,
      latitude: prayerTimes.latitude,
      longitude: prayerTimes.longitude,
    );

    await NotificationService.instance.schedulePrayerNotifications(
      [buildDayMap(today, prayerTimes), buildDayMap(tomorrow, tomorrowModel)],
      azanEnabled: azanEnabled,
    );
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    _prayerTransitionTimer?.cancel();
    return super.close();
  }
}

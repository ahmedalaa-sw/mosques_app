import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosques_app/core/services/adhan_prayer_service.dart';
import 'package:mosques_app/core/services/notification_service.dart';
import 'package:mosques_app/core/utils/location_utils.dart';
import 'package:mosques_app/core/utils/timezone_resolver.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'azan_state.dart';

class AzanCubit extends Cubit<AzanState> {
  static const _key      = 'azan_enabled';
  static const _prefsLat = 'last_known_lat';
  static const _prefsLng = 'last_known_lng';

  AzanCubit() : super(const AzanState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    emit(AzanState(isAzanEnabled: prefs.getBool(_key) ?? false));
  }

  Future<void> toggleAzan() async {
    final newValue = !state.isAzanEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, newValue);
    emit(AzanState(isAzanEnabled: newValue));
    await _rescheduleWithNewPreference(newValue, prefs);
  }

  /// Recalculates today's and tomorrow's prayer times from the cached location
  /// and reschedules all notifications using the correct audio for [enabled].
  /// Uses the cached IANA timezone to convert times correctly.
  Future<void> _rescheduleWithNewPreference(
    bool enabled,
    SharedPreferences prefs,
  ) async {
    try {
      final lat = prefs.getDouble(_prefsLat);
      final lng = prefs.getDouble(_prefsLng);
      if (lat == null || lng == null) return;

      // Read cached country code and timezone — no network calls here.
      final countryCode = prefs.getString(LocationUtils.countryCodePrefsKey) ?? 'US';
      final ianaTimezone = prefs.getString(TimezoneResolver.ianaTimezonePrefsKey) ??
          TimezoneResolver.fromCountryCode(countryCode);

      final location = tz.getLocation(ianaTimezone);
      final todayCalcDate = TimezoneResolver.todayAt(ianaTimezone);
      final tomorrowCalcDate = todayCalcDate.add(const Duration(days: 1));

      Map<String, DateTime> buildDayMap(DateTime calcDate) {
        final result = AdhanPrayerService.calculatePrayerTimesSync(
          latitude: lat,
          longitude: lng,
          countryCode: countryCode,
          ianaTimezone: ianaTimezone,
          date: calcDate,
        );
        // Convert UTC prayer times to location-local wall-clock HH:mm
        String fmt(DateTime? utc) => TimezoneResolver.formatHhMm(utc, ianaTimezone);

        final fajrStr    = fmt(result.prayerTimes.fajr);
        final sunriseStr = fmt(result.prayerTimes.sunrise);
        final dhuhrStr   = fmt(result.prayerTimes.dhuhr);
        final asrStr     = fmt(result.prayerTimes.asr);
        final maghribStr = fmt(result.prayerTimes.maghrib);
        final ishaStr    = fmt(result.prayerTimes.isha);

        // Build TZDateTime in the prayer location's timezone for scheduling
        final localNow = tz.TZDateTime.now(location);
        tz.TZDateTime toSchedule(String hhmm) {
          final parts = hhmm.split(':');
          final h = int.tryParse(parts[0]) ?? 0;
          final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
          return tz.TZDateTime(location, localNow.year, localNow.month, localNow.day, h, m);
        }
        return {
          'Fajr'   : toSchedule(fajrStr),
          'Sunrise': toSchedule(sunriseStr),
          'Dhuhr'  : toSchedule(dhuhrStr),
          'Asr'    : toSchedule(asrStr),
          'Maghrib': toSchedule(maghribStr),
          'Isha'   : toSchedule(ishaStr),
        };
      }

      Map<String, DateTime> buildTomorrowMap() {
        final result = AdhanPrayerService.calculatePrayerTimesSync(
          latitude: lat,
          longitude: lng,
          countryCode: countryCode,
          ianaTimezone: ianaTimezone,
          date: tomorrowCalcDate,
        );
        String fmt(DateTime? utc) => TimezoneResolver.formatHhMm(utc, ianaTimezone);

        final tomorrow = tz.TZDateTime.now(location).add(const Duration(days: 1));
        tz.TZDateTime toSchedule(String hhmm) {
          final parts = hhmm.split(':');
          final h = int.tryParse(parts[0]) ?? 0;
          final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
          return tz.TZDateTime(location, tomorrow.year, tomorrow.month, tomorrow.day, h, m);
        }
        return {
          'Fajr'   : toSchedule(fmt(result.prayerTimes.fajr)),
          'Sunrise': toSchedule(fmt(result.prayerTimes.sunrise)),
          'Dhuhr'  : toSchedule(fmt(result.prayerTimes.dhuhr)),
          'Asr'    : toSchedule(fmt(result.prayerTimes.asr)),
          'Maghrib': toSchedule(fmt(result.prayerTimes.maghrib)),
          'Isha'   : toSchedule(fmt(result.prayerTimes.isha)),
        };
      }

      await NotificationService.instance.schedulePrayerNotifications(
        [buildDayMap(todayCalcDate), buildTomorrowMap()],
        azanEnabled: enabled,
        ianaTimezone: ianaTimezone,
      );
    } catch (_) {
      // Fail silently — existing notifications remain until next app open.
    }
  }
}
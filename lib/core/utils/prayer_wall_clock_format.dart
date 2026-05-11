import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/foundation.dart';
import 'package:mosques_app/core/utils/timezone_resolver.dart';

/// Debug helper that logs prayer times converted to the given timezone.
class PrayerWallClockFormat {
  PrayerWallClockFormat._();

  static String hourMinute(DateTime? t, {required String ianaTimezone}) {
    if (t == null) return '00:00';
    return TimezoneResolver.formatHhMm(t, ianaTimezone);
  }

  static void debugLogPrayerSchedule(
    String tag,
    PrayerTimes pt, {
    required String ianaTimezone,
  }) {
    if (!kDebugMode) return;

    void line(String label, DateTime utcInstant) {
      final wall = TimezoneResolver.utcToLocationLocal(utcInstant, ianaTimezone);
      debugPrint(
        '$tag $label │ utc=$utcInstant isUtc=${utcInstant.isUtc} '
        '│ tz=$ianaTimezone '
        '│ local=$wall ⇒ ${hourMinute(utcInstant, ianaTimezone: ianaTimezone)}',
      );
    }

    debugPrint('$tag ─── prayer wall-clock trace (location tz=$ianaTimezone)');
    line('fajr', pt.fajr);
    line('sunrise', pt.sunrise);
    line('dhuhr', pt.dhuhr);
    line('asr', pt.asr);
    line('maghrib', pt.maghrib);
    line('isha', pt.isha);
  }
}
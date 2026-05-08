import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/foundation.dart';

class PrayerWallClockFormat {
  PrayerWallClockFormat._();

  static String hourMinute(DateTime? t) {
    if (t == null) return '00:00';
    final local = t.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  static void debugLogPrayerSchedule(String tag, PrayerTimes pt) {
    if (!kDebugMode) return;

    final deviceOffset = DateTime.now().timeZoneOffset;

    void line(String label, DateTime utcInstant) {
      final wall = utcInstant.toLocal();
      final wronglyShiftedUtcFields = utcInstant.add(deviceOffset);
      debugPrint(
        '$tag $label │ utc=$utcInstant isUtc=${utcInstant.isUtc} '
        '│ offset=$deviceOffset '
        '│ GOOD.toLocal=$wall ⇒ ${hourMinute(utcInstant)} '
        '│ BAD.add(offset)UTCfields=${wronglyShiftedUtcFields.hour}'
        ':${wronglyShiftedUtcFields.minute.toString().padLeft(2, '0')} (wrong)',
      );
    }

    debugPrint('$tag ─── prayer wall-clock trace (device now=${DateTime.now()})');
    line('fajr', pt.fajr);
    line('sunrise', pt.sunrise);
    line('dhuhr', pt.dhuhr);
    line('asr', pt.asr);
    line('maghrib', pt.maghrib);
    line('isha', pt.isha);
  }
}

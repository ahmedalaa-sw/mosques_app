import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/foundation.dart';

/// Validates prayer times for sanity and correctness.
///
/// Detects abnormal orderings, unrealistic offsets, timezone failures,
/// and ensures prayer times follow the natural astronomical sequence:
/// Fajr < Sunrise < Dhuhr < Asr < Maghrib < Isha.
class PrayerTimeValidator {
  PrayerTimeValidator._();

  /// Validates that all prayer times are in the correct ascending order
  /// and within reasonable bounds. Returns a list of warning messages
  /// (empty = all OK).
  ///
  /// [pt] — the computed [PrayerTimes] from adhan_dart (UTC DateTimes).
  static List<String> validate(PrayerTimes pt) {
    final warnings = <String>[];

    final times = [
      ('Fajr', pt.fajr),
      ('Sunrise', pt.sunrise),
      ('Dhuhr', pt.dhuhr),
      ('Asr', pt.asr),
      ('Maghrib', pt.maghrib),
      ('Isha', pt.isha),
    ];

    // 1. Check ascending order
    for (int i = 0; i < times.length - 1; i++) {
      final (nameA, timeA) = times[i];
      final (nameB, timeB) = times[i + 1];
      if (!timeB.isAfter(timeA)) {
        warnings.add(
          'Order violation: $nameB (${_fmt(timeB)}) is not after '
          '$nameA (${_fmt(timeA)})',
        );
      }
    }

    // 2. Fajr must be before Sunrise by at least 30 minutes
    final fajrToSunrise = pt.sunrise.difference(pt.fajr).inMinutes;
    if (fajrToSunrise < 30) {
      warnings.add(
        'Fajr-to-Sunrise gap too small: ${fajrToSunrise}min (expected ≥30)',
      );
    }
    // Fajr should not be more than 3.5 hours before Sunrise
    if (fajrToSunrise > 210) {
      warnings.add(
        'Fajr-to-Sunrise gap too large: ${fajrToSunrise}min (expected ≤210)',
      );
    }

    // 3. Sunrise to Dhuhr should be at least 3 hours
    final sunriseToDhuhr = pt.dhuhr.difference(pt.sunrise).inMinutes;
    if (sunriseToDhuhr < 180) {
      warnings.add(
        'Sunrise-to-Dhuhr gap too small: ${sunriseToDhuhr}min (expected ≥180)',
      );
    }

    // 4. Dhuhr to Asr should be at least 1 hour
    final dhuhrToAsr = pt.asr.difference(pt.dhuhr).inMinutes;
    if (dhuhrToAsr < 60) {
      warnings.add(
        'Dhuhr-to-Asr gap too small: ${dhuhrToAsr}min (expected ≥60)',
      );
    }

    // 5. Maghrib should be very close to sunset (within a few minutes)
    // — this is inherent in adhan_dart's calculation

    // 6. Maghrib to Isha should be at least 30 minutes
    final maghribToIsha = pt.isha.difference(pt.maghrib).inMinutes;
    if (maghribToIsha < 30) {
      warnings.add(
        'Maghrib-to-Isha gap too small: ${maghribToIsha}min (expected ≥30)',
      );
    }

    if (warnings.isNotEmpty && kDebugMode) {
      debugPrint('[PrayerTimeValidator] ⚠️ ${warnings.length} warning(s):');
      for (final w in warnings) {
        debugPrint('[PrayerTimeValidator]   • $w');
      }
    }

    return warnings;
  }

  /// Returns true if the prayer times pass all validation checks.
  static bool isValid(PrayerTimes pt) => validate(pt).isEmpty;

  static String _fmt(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')} '
      '(UTC: ${dt.toUtc().hour.toString().padLeft(2, '0')}:'
      '${dt.toUtc().minute.toString().padLeft(2, '0')})';
}

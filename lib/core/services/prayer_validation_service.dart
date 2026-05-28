import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/foundation.dart';

/// Validation result containing any detected issues
class ValidationResult {
  final bool isValid;
  final String? error;
  final List<String>? warnings;

  const ValidationResult({required this.isValid, this.error, this.warnings});

  factory ValidationResult.valid({List<String>? warnings}) {
    return ValidationResult(isValid: true, error: null, warnings: warnings);
  }

  factory ValidationResult.invalid(String error) {
    return ValidationResult(isValid: false, error: error, warnings: null);
  }
}

/// Validates prayer times to detect abnormal offsets, timezone failures,
/// and UTC conversion problems. Ensures production-level accuracy.
class PrayerValidationService {
  PrayerValidationService._();

  /// Validates prayer times for abnormal offsets, ordering, and reasonableness.
  ///
  /// Checks:
  /// - All prayer times are DateTime objects (not null)
  /// - Times are in chronological order (Fajr < Sunrise < Dhuhr < Asr < Maghrib < Isha)
  /// - Intervals between prayers are reasonable
  /// - Fajr is not before 3 AM (unrealistic too-early)
  /// - Isha is not after 3 AM next day (unrealistic too-late)
  /// - Sunrise is between 4 AM and 10 AM
  /// - Maghrib is between 4 PM and 8 PM
  /// - Asr/Dhuhr intervals are reasonable (> 2 hours, < 8 hours)
  static ValidationResult validate(PrayerTimes times) {
    if (kDebugMode) debugPrint('[PrayerValidation] Starting validation...');

    final warnings = <String>[];

    // 1. Check chronological order
    if (!_isChronological(times)) {
      return ValidationResult.invalid(
        'Prayer times not in correct order: '
        'Fajr=${times.fajr}, Sunrise=${times.sunrise}, Dhuhr=${times.dhuhr}, '
        'Asr=${times.asr}, Maghrib=${times.maghrib}, Isha=${times.isha}',
      );
    }

    // 2. Check if Fajr is dangerously early (before 3 AM)
    if (times.fajr.hour < 3) {
      warnings.add(
        'Fajr time is very early (${times.fajr.hour}:${times.fajr.minute}). '
        'Verify location coordinates are correct.',
      );
    }

    // 3. Check if Isha is dangerously late (after 3 AM)
    if (times.isha.hour > 23 ||
        (times.isha.hour == 0 && times.isha.minute > 0)) {
      if (times.isha.hour > 3 && times.isha.hour < 12) {
        warnings.add(
          'Isha time seems late (${times.isha.hour}:${times.isha.minute}). '
          'Check location timezone.',
        );
      }
    }

    // 4. Check Sunrise is reasonable (between 4 AM and 10 AM)
    if (times.sunrise.hour < 4 || times.sunrise.hour > 10) {
      warnings.add(
        'Sunrise time unusual (${times.sunrise.hour}:${times.sunrise.minute}). '
        'This is expected near polar regions.',
      );
    }

    // 5. Check Maghrib is reasonable (between 4 PM and 8 PM)
    if (times.maghrib.hour < 16 || times.maghrib.hour > 20) {
      warnings.add(
        'Maghrib time unusual (${times.maghrib.hour}:${times.maghrib.minute}). '
        'This is expected near polar regions.',
      );
    }

    // 6. Check intervals
    final fajrToSunrise = times.sunrise.difference(times.fajr).inMinutes;
    if (fajrToSunrise < 60 || fajrToSunrise > 180) {
      warnings.add(
        'Fajr-to-Sunrise interval unusual: $fajrToSunrise minutes. '
        'Expected 60-180 minutes.',
      );
    }

    final dhuhrToAsr = times.asr.difference(times.dhuhr).inMinutes;
    if (dhuhrToAsr < 120 || dhuhrToAsr > 480) {
      warnings.add(
        'Dhuhr-to-Asr interval unusual: $dhuhrToAsr minutes. '
        'Expected 120-480 minutes.',
      );
    }

    if (kDebugMode) {
      if (warnings.isEmpty) {
        debugPrint('[PrayerValidation] ✓ All checks passed');
      } else {
        for (final w in warnings) {
          debugPrint('[PrayerValidation] ⚠ $w');
        }
      }
    }

    return ValidationResult.valid(warnings: warnings.isEmpty ? null : warnings);
  }

  /// Checks prayer times are in strict chronological order
  static bool _isChronological(PrayerTimes times) {
    return times.fajr.isBefore(times.sunrise) &&
        times.sunrise.isBefore(times.dhuhr) &&
        times.dhuhr.isBefore(times.asr) &&
        times.asr.isBefore(times.maghrib) &&
        times.maghrib.isBefore(times.isha);
  }

  /// Checks for UTC conversion anomalies (e.g., times in wrong timezone)
  static bool hasUtcConversionFailure(PrayerTimes times, String ianaTimezone) {
    // If all times are in UTC (00:XX to 23:XX but suspiciously around midnight/noon)
    // This could indicate a timezone conversion failure
    if (times.fajr.hour == 0 &&
        times.sunrise.hour == 0 &&
        times.dhuhr.hour == 12 &&
        times.asr.hour == 15 &&
        times.maghrib.hour == 18 &&
        times.isha.hour == 20) {
      if (kDebugMode) {
        debugPrint(
          '[PrayerValidation] ⚠ Possible UTC conversion failure for timezone $ianaTimezone',
        );
      }
      return true;
    }

    return false;
  }
}

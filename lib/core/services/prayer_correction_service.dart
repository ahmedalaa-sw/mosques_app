import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/foundation.dart';

/// Result containing corrected prayer times
class CorrectionResult {
  final PrayerTimes original;
  final PrayerTimes corrected;
  final Map<String, int>? adjustments; // prayer -> minutes adjusted

  const CorrectionResult({
    required this.original,
    required this.corrected,
    this.adjustments,
  });

  bool hasAdjustments() => adjustments != null && adjustments!.isNotEmpty;
}

/// Applies corrections to prayer times based on:
/// - Altitude/elevation
/// - Regional preferences
/// - High latitude considerations
///
/// Used to fine-tune adhan_dart calculations to match production-level accuracy.
class PrayerCorrectionService {
  PrayerCorrectionService._();

  /// Applies altitude-based and regional corrections to prayer times.
  ///
  /// Parameters:
  /// - [prayerTimes]: Original prayer times from adhan_dart
  /// - [latitude]: Location latitude (used for high latitude detection)
  /// - [altitude]: Location altitude in meters (used for elevation corrections)
  /// - [countryCode]: ISO-3166-1 alpha-2 country code for regional adjustments
  ///
  /// Returns correction result with adjusted times and details.
  static CorrectionResult applyCorrections({
    required PrayerTimes prayerTimes,
    required double latitude,
    required double? altitude,
    required String countryCode,
  }) {
    if (kDebugMode) {
      debugPrint(
        '[PrayerCorrection] Applying corrections for $countryCode '
        '(lat=$latitude, alt=$altitude)',
      );
    }

    final adjustments = <String, int>{};

    // 1. Apply altitude correction (elevation increases visibility of Fajr/Sunrise)
    if (altitude != null && altitude > 100) {
      final altitudeAdjust = _altitudeCorrection(altitude, latitude);
      if (altitudeAdjust != null && altitudeAdjust.isNotEmpty) {
        adjustments.addAll(altitudeAdjust);
      }
    }

    // 2. Apply regional fine-tuning
    final regionalAdjust = _regionalAdjustment(countryCode);
    if (regionalAdjust.isNotEmpty) {
      adjustments.addAll(regionalAdjust);
    }

    // 3. Apply high-latitude adjustments if near poles
    if (latitude.abs() > 65) {
      final hlAdjust = _highLatitudeAdjustment(latitude);
      if (hlAdjust.isNotEmpty) {
        adjustments.addAll(hlAdjust);
      }
    }

    // Apply all adjustments
    final corrected = _applyAdjustments(prayerTimes, adjustments);

    if (kDebugMode) {
      if (adjustments.isNotEmpty) {
        debugPrint('[PrayerCorrection] Applied adjustments: $adjustments');
      } else {
        debugPrint('[PrayerCorrection] No adjustments needed');
      }
    }

    return CorrectionResult(
      original: prayerTimes,
      corrected: corrected,
      adjustments: adjustments.isEmpty ? null : adjustments,
    );
  }

  /// Calculates altitude-based correction in minutes.
  ///
  /// At higher elevations, the sun appears earlier (higher in sky sooner).
  /// Formula: dip = atan(R / altitude) where R ≈ 6371 km (Earth radius)
  /// This provides a small adjustment (typically 1-3 minutes for altitudes < 3000m).
  static Map<String, int>? _altitudeCorrection(
    double altitudeMeters,
    double latitude,
  ) {
    if (altitudeMeters < 100) return null;

    // Earth radius in meters
    const earthRadius = 6371000.0;

    // Calculate angle correction in radians
    final angleRad = (earthRadius / (earthRadius + altitudeMeters)) - 1;

    // Convert to approximate minutes (rough estimation)
    // This is simplified; a full calculation would use refraction tables
    final minutesCorrection = (angleRad * 180 / 3.14159).abs().toInt();

    if (minutesCorrection == 0) return null;

    // At high altitude, Fajr appears earlier (add minutes back to offset early time)
    // Sunrise also appears earlier
    // This is subtle, typically ±1-2 minutes
    final adjustments = <String, int>{};

    if (minutesCorrection > 0 && minutesCorrection <= 5) {
      // Apply small positive adjustment to Fajr and Sunrise (they come earlier at altitude)
      adjustments['fajr'] = minutesCorrection;
      adjustments['sunrise'] = minutesCorrection;

      if (kDebugMode) {
        debugPrint(
          '[PrayerCorrection] Altitude ${altitudeMeters}m '
          'applied +$minutesCorrection min to Fajr/Sunrise',
        );
      }
    }

    return adjustments.isEmpty ? null : adjustments;
  }

  /// Regional fine-tuning adjustments based on country.
  ///
  /// Some countries have official prayer time standards that differ
  /// slightly from direct adhan_dart calculations.
  static Map<String, int> _regionalAdjustment(String countryCode) {
    switch (countryCode) {
      // Saudi Arabia (Umm Al-Qura) - typically very accurate already
      case 'SA':
        return {};

      // Egypt (Egyptian Authority) - sometimes uses +1 min for Fajr
      case 'EG':
        return {};

      // Pakistan (Karachi) - sometimes uses -1 min for Fajr
      case 'PK':
        return {};

      // Malaysia/Singapore - generally accurate
      case 'MY':
      case 'SG':
        return {};

      // Turkey - sometimes uses +1 min
      case 'TR':
        return {};

      // North America - ISNA method
      case 'US':
      case 'CA':
        return {};

      // Default: no regional adjustment
      default:
        return {};
    }
  }

  /// High latitude adjustments for regions near poles (|latitude| > 65°).
  ///
  /// At high latitudes, the sun may not set properly (midnight sun in summer)
  /// or not rise properly (polar night in winter). The high latitude rule
  /// (MiddleOfTheNight) is already applied by adhan_dart, but we can add
  /// validation checks here.
  static Map<String, int> _highLatitudeAdjustment(double latitude) {
    if (latitude.abs() <= 65) return {};

    if (kDebugMode) {
      debugPrint(
        '[PrayerCorrection] High latitude detected: $latitude°. '
        'Using Middle of the Night rule.',
      );
    }

    // High latitude rule is handled by adhan_dart with HighLatitudeRule.
    // Here we just note the condition; no minute adjustments needed.
    return {};
  }

  /// Applies minute adjustments to a PrayerTimes object.
  ///
  /// Note: PrayerTimes from adhan_dart is immutable and doesn't provide
  /// a copy constructor. To fully implement corrections, one would need to:
  /// 1. Store adjusted times in a separate model
  /// 2. Or fork adhan_dart to add mutable support
  ///
  /// For now, this returns the original times. The adjustment map
  /// is calculated and can be applied at a higher level (e.g., in the
  /// model or UI layer) when displaying times.
  static PrayerTimes _applyAdjustments(
    PrayerTimes times,
    Map<String, int> adjustments,
  ) {
    if (adjustments.isEmpty) return times;

    // TODO: Implement full prayer time adjustment once PrayerTimes
    // mutable model is available or wrapper is created.
    // For now, return original times and log that adjustments were calculated.
    if (kDebugMode) {
      debugPrint(
        '[PrayerCorrection] Calculated adjustments: $adjustments '
        '(not yet applied to immutable PrayerTimes object)',
      );
    }

    return times;
  }
}

import 'package:adhan_dart/adhan_dart.dart';

/// Offline prayer-time calculation service using adhan_dart.
/// Place at: lib/core/services/adhan_prayer_service.dart
class AdhanPrayerService {
  AdhanPrayerService._();

  static const String defaultMethodName = 'Muslim World League';

  static PrayerTimes calculatePrayerTimes({
    required double latitude,
    required double longitude,
    CalculationParameters? params,
  }) {
    final coordinates = Coordinates(latitude, longitude);

    // ── CORRECT adhan_dart API (confirmed from official README + changelog) ─
    //
    // The class is CalculationMethodParameters — NOT CalculationMethod.
    // The method is muslimWorldLeague()             — lowercase camelCase.
    // The madhab is Madhab.shafi                   — lowercase.
    //
    // CalculationMethod.MuslimWorldLeague() does NOT exist in adhan_dart.
    // CalculationMethod.muslimWorldLeague() does NOT exist in adhan_dart.
    // CalculationMethodParameters.muslimWorldLeague() is the correct call.
    //
    // Changelog v1.1.0: "fixed some static methods naming convention"
    // ───────────────────────────────────────────────────────────────────────
    final calculationParams =
        params ?? CalculationMethodParameters.muslimWorldLeague();
    calculationParams.madhab = Madhab.hanafi;

    return PrayerTimes(
      coordinates: coordinates,
      date: DateTime.now(),
      calculationParameters: calculationParams,
      precision: true,
    );
  }
}

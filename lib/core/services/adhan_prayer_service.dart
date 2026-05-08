import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/foundation.dart';
import 'package:mosques_app/features/home/model/prayer_method_mapper.dart';
import '../utils/location_utils.dart';

class AdhanPrayerService {
  AdhanPrayerService._();

  static const String defaultMethodName = 'AdhanCalculation';

  // ── async version used by HomeRepository ──────────────────────────────────
  static Future<PrayerTimes> calculatePrayerTime({
    required double latitude,
    required double longitude,
  }) async {
    final coordinates = Coordinates(latitude, longitude);
    final countryCode = await LocationUtils.getCountryCode(latitude, longitude);
    final params = PrayerMethodMapper.fromCountry(countryCode);
    params.madhab = Madhab.shafi;
    debugPrint(
      '[AdhanPrayerService] Calculating with country=$countryCode, '
      'lat=$latitude, lng=$longitude',
    );

    final now = DateTime.now();

    // Gregorian calendar anchor; SolarTime reads only year/month/day (Julian).
    final calendar = DateTime(now.year, now.month, now.day);
    return PrayerTimes(
      coordinates: coordinates,
      date: DateTime.utc(calendar.year, calendar.month, calendar.day),
      calculationParameters: params,
      precision: true,
    );
  }

  // ── sync version used by BackgroundRescheduleService ──────────────────────
  // The background isolate cannot use async/await at the top level, so we
  // expose a synchronous variant. The signature is calculatePrayerTimes
  // (plural) to match how BackgroundRescheduleService calls it.
  static PrayerTimes calculatePrayerTimes({
    required double latitude,
    required double longitude,
    CalculationParameters? params,
  }) {
    final coordinates = Coordinates(latitude, longitude);
    final inferred = LocationUtils.offlineCountryIsoGuessForPrayer(latitude, longitude);

    CalculationParameters calculationParams =
        params ??
        (inferred != null
            ? PrayerMethodMapper.fromCountry(inferred)
            : CalculationMethodParameters.muslimWorldLeague());
    calculationParams.madhab = Madhab.shafi;

    final now = DateTime.now();
    final calendar = DateTime(now.year, now.month, now.day);

    return PrayerTimes(
      coordinates: coordinates,
      date: DateTime.utc(calendar.year, calendar.month, calendar.day),
      calculationParameters: calculationParams,
      precision: true,
    );
  }
}

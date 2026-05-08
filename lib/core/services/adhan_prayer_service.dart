import 'package:adhan_dart/adhan_dart.dart';
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

    final now = DateTime.now();

    // ── FIX 1: pass a UTC-only date (year/month/day, no time component) ────
    // adhan_dart's official docs state prayer times are returned as UTC values.
    // Passing DateTime.now() (local) embeds the local timezone offset into the
    // date object, causing the library to double-count the offset internally
    // and produce times that are ~+10 h wrong for Kuwait (UTC+3).
    // Using DateTime.utc(y, m, d) strips the time component entirely and gives
    // the library a clean UTC midnight anchor to calculate from.
    return PrayerTimes(
      coordinates: coordinates,
      date: DateTime.utc(now.year, now.month, now.day),
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
    final calculationParams = params ?? CalculationMethodParameters.muslimWorldLeague();
    calculationParams.madhab = Madhab.shafi;

    final now = DateTime.now();

    return PrayerTimes(
      coordinates: coordinates,
      date: DateTime.utc(now.year, now.month, now.day),
      calculationParameters: calculationParams,
      precision: true,
    );
  }
}
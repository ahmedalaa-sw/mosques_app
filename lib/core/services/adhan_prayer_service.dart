import 'package:adhan_dart/adhan_dart.dart';
import 'package:mosques_app/features/home/model/prayer_method_mapper.dart';
import '../utils/location_utils.dart';
import '../utils/timezone_resolver.dart';

/// Result of a prayer time calculation that bundles the [PrayerTimes]
/// with the resolved IANA timezone name and country code.
class PrayerCalculationResult {
  final PrayerTimes prayerTimes;
  final String ianaTimezone;
  final String countryCode;

  const PrayerCalculationResult({
    required this.prayerTimes,
    required this.ianaTimezone,
    required this.countryCode,
  });
}

class AdhanPrayerService {
  AdhanPrayerService._();

  static const String defaultMethodName = 'AdhanCalculation';
  static const String defaultIanaTimezone = 'Asia/Riyadh';

  /// Async version — resolves country code via geocoding if not cached.
  /// Use this on the foreground (home screen load).
  ///
  /// Returns a [PrayerCalculationResult] that includes the IANA timezone
  /// name for the prayer location, so callers can convert UTC times to
  /// the correct local wall-clock time.
  static Future<PrayerCalculationResult> calculatePrayerTime({
    required double latitude,
    required double longitude,
  }) async {
    final coordinates = Coordinates(latitude, longitude);
    final countryCode = await LocationUtils.getCountryCode(latitude, longitude);
    final ianaTimezone = TimezoneResolver.fromCountryCode(countryCode);
    final params = PrayerMethodMapper.fromCountry(
      countryCode,
      latitude: latitude,
    );
    params.madhab = Madhab.shafi;
    final date = TimezoneResolver.todayAt(ianaTimezone);
    return PrayerCalculationResult(
      prayerTimes: PrayerTimes(
        coordinates: coordinates,
        date: date,
        calculationParameters: params,
        precision: true,
      ),
      ianaTimezone: ianaTimezone,
      countryCode: countryCode,
    );
  }

  /// Sync version — no network, no geocoding.
  /// Use this in background tasks and when toggling azan preference,
  /// where the country code is already cached in SharedPreferences.
  ///
  /// [countryCode] — ISO-3166-1 alpha-2 code (e.g. 'EG'); defaults to 'US'
  ///                 which maps to Muslim World League (safe global default).
  /// [ianaTimezone] — IANA timezone name for the prayer location (e.g.
  ///                  'Asia/Riyadh'). Must match the country code's timezone.
  /// [date]         — date for which to calculate; defaults to "today" at
  ///                  the prayer location's timezone.
  static PrayerCalculationResult calculatePrayerTimesSync({
    required double latitude,
    required double longitude,
    String countryCode = 'US',
    String? ianaTimezone,
    DateTime? date,
  }) {
    final coordinates = Coordinates(latitude, longitude);
    final resolvedTimezone =
        ianaTimezone ?? TimezoneResolver.fromCountryCode(countryCode);
    final params = PrayerMethodMapper.fromCountry(
      countryCode,
      latitude: latitude,
    );
    params.madhab = Madhab.shafi;
    final resolvedDate = date ?? TimezoneResolver.todayAt(resolvedTimezone);
    return PrayerCalculationResult(
      prayerTimes: PrayerTimes(
        coordinates: coordinates,
        date: resolvedDate,
        calculationParameters: params,
        precision: true,
      ),
      ianaTimezone: resolvedTimezone,
      countryCode: countryCode,
    );
  }
}

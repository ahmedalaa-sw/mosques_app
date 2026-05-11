import 'package:adhan_dart/adhan_dart.dart';
import 'package:mosques_app/features/home/model/prayer_method_mapper.dart';
import '../utils/location_utils.dart';

class AdhanPrayerService {
  AdhanPrayerService._();

  static const String defaultMethodName = 'AdhanCalculation';

  /// Async version — resolves country code via geocoding if not cached.
  /// Use this on the foreground (home screen load).
  static Future<PrayerTimes> calculatePrayerTime({
    required double latitude,
    required double longitude,
  }) async {
    final coordinates = Coordinates(latitude, longitude);
    final countryCode = await LocationUtils.getCountryCode(latitude, longitude);
    final params = PrayerMethodMapper.fromCountry(countryCode);
    params.madhab = Madhab.shafi;
    return PrayerTimes(
      coordinates: coordinates,
      date: DateTime.now(),
      calculationParameters: params,
      precision: true,
    );
  }

  /// Sync version — no network, no geocoding.
  /// Use this in background tasks and when toggling azan preference,
  /// where the country code is already cached in SharedPreferences.
  ///
  /// [countryCode] — ISO-3166-1 alpha-2 code (e.g. 'EG'); defaults to 'US'
  ///                 which maps to Muslim World League (safe global default).
  /// [date]        — date for which to calculate; defaults to today.
  static PrayerTimes calculatePrayerTimesSync({
    required double latitude,
    required double longitude,
    String countryCode = 'US',
    DateTime? date,
  }) {
    final coordinates = Coordinates(latitude, longitude);
    final params = PrayerMethodMapper.fromCountry(countryCode);
    params.madhab = Madhab.shafi;
    return PrayerTimes(
      coordinates: coordinates,
      date: date ?? DateTime.now(),
      calculationParameters: params,
      precision: true,
    );
  }
}
import 'package:adhan_dart/adhan_dart.dart';
import 'package:mosques_app/features/home/model/prayer_method_mapper.dart';
import '../utils/location_utils.dart';

class AdhanPrayerService {
  AdhanPrayerService._();
  
  // ✅ تعريف المتغير الثابت
  static const String defaultMethodName = 'AdhanCalculation';
  
  static Future<PrayerTimes> calculatePrayerTime({
    required double latitude,
    required double longitude,
  }) async {
    final coordinates = Coordinates(latitude, longitude);

    /// 🌍 هات الدولة (cached بعد أول مرة)
    final countryCode = await LocationUtils.getCountryCode(latitude, longitude);

    /// 🧠 اختار method الصح
    final params = PrayerMethodMapper.fromCountry(countryCode);

    /// ⚖️ Madhab
    params.madhab = Madhab.shafi;

    return PrayerTimes(
      coordinates: coordinates,
      date: DateTime.now(),
      calculationParameters: params,
      precision: true,
    );
  }
}
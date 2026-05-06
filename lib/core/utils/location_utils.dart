import 'dart:math';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationUtils {
  static const _countryKey = 'cached_country_code';
  static const _latKey = 'cached_lat';
  static const _lngKey = 'cached_lng';

  /// 🧠 محاولة تحديد الدولة بدون نت (تقريبية)
  static String? _detectOffline(double lat, double lng) {
    /// 🇪🇬 Egypt
    if (lat >= 22 && lat <= 32 && lng >= 25 && lng <= 36) {
      return 'EG';
    }

    /// 🇸🇦 Saudi
    if (lat >= 16 && lat <= 32 && lng >= 34 && lng <= 56) {
      return 'SA';
    }

    /// 🇰🇼 Kuwait
    if (lat >= 28 && lat <= 31 && lng >= 46 && lng <= 49) {
      return 'KW';
    }

    return null; // fallback
  }

  /// 📍 هل المستخدم اتحرك مسافة كبيرة؟
  static bool _hasMoved(
      double oldLat, double oldLng, double newLat, double newLng) {
    const thresholdKm = 50;

    double distance = _distanceKm(oldLat, oldLng, newLat, newLng);
    return distance > thresholdKm;
  }

  static double _distanceKm(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  static double _deg2rad(double deg) => deg * (pi / 180);

  /// 🌍 Main function
  static Future<String> getCountryCode(
      double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();

    final cachedCountry = prefs.getString(_countryKey);
    final oldLat = prefs.getDouble(_latKey);
    final oldLng = prefs.getDouble(_lngKey);

    /// 📍 لو المستخدم اتحرك → امسح الكاش
    if (cachedCountry != null &&
        oldLat != null &&
        oldLng != null &&
        _hasMoved(oldLat, oldLng, lat, lng)) {
      await prefs.remove(_countryKey);
    }

    /// ✅ استخدم الكاش لو موجود
    final newCached = prefs.getString(_countryKey);
    if (newCached != null) return newCached;

    /// ⚡ حاول offline detection
    final offline = _detectOffline(lat, lng);
    if (offline != null) {
      await prefs.setString(_countryKey, offline);
      await prefs.setDouble(_latKey, lat);
      await prefs.setDouble(_lngKey, lng);
      return offline;
    }

    /// 🌐 fallback → geocoding (مرة واحدة)
    final placemarks = await placemarkFromCoordinates(lat, lng);
    final code = placemarks.first.isoCountryCode ?? 'US';

    await prefs.setString(_countryKey, code);
    await prefs.setDouble(_latKey, lat);
    await prefs.setDouble(_lngKey, lng);

    return code;
  }
}
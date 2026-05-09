import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationUtils {
  /// Exposed so background services and cubits can read the cached value
  /// directly from SharedPreferences without going through geocoding.
  static const countryCodePrefsKey = 'cached_country_code';

  static const _countryKey = countryCodePrefsKey;
  // Distinct from AppConstants.cachedLat/Lng (used by MosqueSearchCubit) to
  // prevent the two caches from stomping each other in SharedPreferences.
  static const _latKey = 'loc_utils_lat';
  static const _lngKey = 'loc_utils_lng';

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
    debugPrint('[Country] A — getCountryCode lat=$lat lng=$lng');
    final prefs = await SharedPreferences.getInstance();

    final cachedCountry = prefs.getString(_countryKey);
    final oldLat = prefs.getDouble(_latKey);
    final oldLng = prefs.getDouble(_lngKey);
    debugPrint('[Country] B — cachedCountry=$cachedCountry');

    if (cachedCountry != null &&
        oldLat != null &&
        oldLng != null &&
        _hasMoved(oldLat, oldLng, lat, lng)) {
      debugPrint('[Country] C — moved, clearing cache');
      await prefs.remove(_countryKey);
    }

    final newCached = prefs.getString(_countryKey);
    if (newCached != null) {
      debugPrint('[Country] D — returning cached: $newCached');
      return newCached;
    }

    final offline = _detectOffline(lat, lng);
    debugPrint('[Country] E — offline detection: $offline');
    if (offline != null) {
      await prefs.setString(_countryKey, offline);
      await prefs.setDouble(_latKey, lat);
      await prefs.setDouble(_lngKey, lng);
      return offline;
    }

    debugPrint('[Country] F — calling geocoding...');
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng)
          .timeout(const Duration(seconds: 5), onTimeout: () => <Placemark>[]);
      debugPrint('[Country] G — geocoding returned ${placemarks.length} results');
      if (placemarks.isEmpty) return 'US'; // timeout/no result — don't cache
      final code = placemarks.first.isoCountryCode ?? 'US';
      debugPrint('[Country] H — geocoded country: $code');
      await prefs.setString(_countryKey, code);
      await prefs.setDouble(_latKey, lat);
      await prefs.setDouble(_lngKey, lng);
      return code;
    } catch (e) {
      debugPrint('[Country] ERROR — geocoding failed: $e');
      return 'US';
    }
  }
}
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

    /// 🇰🇼 Kuwait (must be BEFORE the broad Saudi/Gulf box)
    if (lat >= 28 && lat <= 31 && lng >= 46 && lng <= 49) {
      return 'KW';
    }

    /// 🇸🇦 Saudi Arabia & parts of the Arabian Peninsula
    if (lat >= 16 && lat <= 32 && lng >= 34 && lng <= 56) {
      return 'SA';
    }

    /// 🇺🇸 Contiguous USA (Mountain View falls here)
    if (lat >= 24.0 && lat <= 50.0 && lng >= -125.0 && lng <= -66.0) {
      return 'US';
    }

    /// 🇨🇦 Canada (mainland, coarse)
    if (lat >= 41.0 && lat <= 70.0 && lng >= -141.0 && lng <= -52.0) {
      return 'CA';
    }

    return null; // fallback
  }

  /// Sync guess for isolates / non-await code paths (no SharedPreferences).
  /// Returns `null` when unknown — caller should fall back to a global default.
  static String? offlineCountryIsoGuessForPrayer(double lat, double lng) =>
      _detectOffline(lat, lng);

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
    if (kDebugMode) debugPrint('[Country] A — getCountryCode lat=$lat lng=$lng');
    final prefs = await SharedPreferences.getInstance();

    final cachedCountry = prefs.getString(_countryKey);
    final oldLat = prefs.getDouble(_latKey);
    final oldLng = prefs.getDouble(_lngKey);
    if (kDebugMode) debugPrint('[Country] B — cachedCountry=$cachedCountry');

    if (cachedCountry != null &&
        oldLat != null &&
        oldLng != null &&
        _hasMoved(oldLat, oldLng, lat, lng)) {
      if (kDebugMode) debugPrint('[Country] C — moved, clearing cache');
      await prefs.remove(_countryKey);
    }

    final newCached = prefs.getString(_countryKey);
    if (newCached != null) {
      if (kDebugMode) debugPrint('[Country] D — returning cached: $newCached');
      return newCached;
    }

    final offline = _detectOffline(lat, lng);
    if (kDebugMode) debugPrint('[Country] E — offline detection: $offline');
    if (offline != null) {
      await prefs.setString(_countryKey, offline);
      await prefs.setDouble(_latKey, lat);
      await prefs.setDouble(_lngKey, lng);
      return offline;
    }

    if (kDebugMode) debugPrint('[Country] F — calling geocoding...');
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng)
          .timeout(const Duration(seconds: 5), onTimeout: () => <Placemark>[]);
      if (kDebugMode) debugPrint('[Country] G — geocoding returned ${placemarks.length} results');
      if (placemarks.isEmpty) return 'US';
      final code = placemarks.first.isoCountryCode ?? 'US';
      if (kDebugMode) debugPrint('[Country] H — geocoded country: $code');
      await prefs.setString(_countryKey, code);
      await prefs.setDouble(_latKey, lat);
      await prefs.setDouble(_lngKey, lng);
      return code;
    } catch (e) {
      if (kDebugMode) debugPrint('[Country] ERROR — geocoding failed: $e');
      return 'US';
    }
  }
}
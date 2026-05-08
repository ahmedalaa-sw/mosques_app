import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class LocationUtils {
  static const _countryKey = 'cached_country_code';
  static const _latKey = 'cached_lat';
  static const _lngKey = 'cached_lng';

  /// Regions used for calculation-method inference (offline, approximate).
  static String? _approximateOfflineRegion(double lat, double lng) {
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

    /// 🇺🇸 Contiguous USA (Mountain View falls here).
    /// Excludes overlapping northern Canada by longitude/latitude heuristics.
    if (lat >= 24.0 &&
        lat <= 50.0 &&
        lng >= -125.0 &&
        lng <= -66.0) {
      return 'US';
    }

    /// 🇨🇦 Canada (mainland, coarse).
    if (lat >= 41.0 &&
        lat <= 70.0 &&
        lng >= -141.0 &&
        lng <= -52.0) {
      return 'CA';
    }

    return null;
  }

  /// Sync guess for isolates / non-await code paths (no SharedPreferences).
  /// Returns `null` when unknown — caller should fall back to a global default.
  static String? offlineCountryIsoGuessForPrayer(double lat, double lng) =>
      _approximateOfflineRegion(lat, lng);

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

  /// Offline-only country/code resolver.
  static Future<String> getCountryCode(double lat, double lng) async {
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
    final offline = _approximateOfflineRegion(lat, lng);
    if (offline != null) {
      await prefs.setString(_countryKey, offline);
      await prefs.setDouble(_latKey, lat);
      await prefs.setDouble(_lngKey, lng);
      return offline;
    }

    // Fully offline fallback.
    await prefs.setString(_countryKey, 'US');
    await prefs.setDouble(_latKey, lat);
    await prefs.setDouble(_lngKey, lng);
    return 'US';
  }
}
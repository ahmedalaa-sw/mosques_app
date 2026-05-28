import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:mosques_app/core/services/background_reschedule_service.dart';
import 'package:mosques_app/features/home/model/prayer_method_mapper.dart';
import 'package:mosques_app/core/utils/location_utils.dart';
import 'package:mosques_app/core/utils/timezone_resolver.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mosques_app/features/home/model/home_model.dart';

class PrayerCacheService {
  PrayerCacheService._();

  static const String _cacheKey = 'cached_prayer_times_json';
  static const double _locationThresholdMeters = 50000;

  static Future<void> savePrayerTimes(
    AladhanPrayerTimesModel prayerTimes,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(prayerTimes.toJson()));
    await prefs.setString(
      LocationUtils.countryCodePrefsKey,
      prayerTimes.countryCode,
    );
    await prefs.setString(
      TimezoneResolver.ianaTimezonePrefsKey,
      prayerTimes.ianaTimezone,
    );
    await prefs.setDouble(
      BackgroundRescheduleService.prefsLat,
      prayerTimes.latitude,
    );
    await prefs.setDouble(
      BackgroundRescheduleService.prefsLng,
      prayerTimes.longitude,
    );
  }

  static Future<AladhanPrayerTimesModel?> loadCachedPrayerTimes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return AladhanPrayerTimesModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  static Future<AladhanPrayerTimesModel?> loadValidCachedPrayerTimes() async {
    final cached = await loadCachedPrayerTimes();
    if (cached == null) return null;

    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(BackgroundRescheduleService.prefsLat);
    final lng = prefs.getDouble(BackgroundRescheduleService.prefsLng);
    final countryCode = prefs.getString(LocationUtils.countryCodePrefsKey);
    final ianaTimezone = prefs.getString(TimezoneResolver.ianaTimezonePrefsKey);

    if (lat == null ||
        lng == null ||
        countryCode == null ||
        ianaTimezone == null) {
      return null;
    }

    if (!_isSameDay(cached.date, ianaTimezone)) return null;
    if (cached.countryCode.toUpperCase() != countryCode.toUpperCase())
      return null;
    if (cached.ianaTimezone != ianaTimezone) return null;
    if (!_isSameMethod(cached.methodName, countryCode)) return null;
    if (!_isSameLocation(lat, lng, cached.latitude, cached.longitude))
      return null;

    return cached;
  }

  static bool _isSameDay(DateTime cachedDate, String ianaTimezone) {
    final now = TimezoneResolver.nowAt(ianaTimezone);
    return cachedDate.year == now.year &&
        cachedDate.month == now.month &&
        cachedDate.day == now.day;
  }

  static bool _isSameLocation(
    double oldLat,
    double oldLng,
    double newLat,
    double newLng,
  ) {
    final distance = Geolocator.distanceBetween(oldLat, oldLng, newLat, newLng);
    return distance <= _locationThresholdMeters;
  }

  static bool _isSameMethod(String cachedMethod, String countryCode) {
    return cachedMethod == PrayerMethodMapper.methodNameForCountry(countryCode);
  }
}

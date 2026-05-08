import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static const _prefsLat = 'last_known_lat';
  static const _prefsLng = 'last_known_lng';
  static const _getPositionTimeout = Duration(seconds: 8);

  static const defaultLatitude = 29.3759;
  static const defaultLongitude = 47.9774;

  Future<Position> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(
        'Location services are disabled. Please enable GPS on your device and try again.',
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission was denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission is permanently denied. Please enable it in settings.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
      ),
    ).timeout(_getPositionTimeout);
    await cacheLastKnownLocation(position.latitude, position.longitude);
    return position;
  }

  Future<({double latitude, double longitude})> getBestEffortCoordinates() async {
    try {
      final position = await getCurrentLocation();
      return (latitude: position.latitude, longitude: position.longitude);
    } catch (_) {
      final cached = await getCachedLocation();
      if (cached != null) return cached;
      // If we have no cached coordinates, still return something deterministic
      // so adhan_dart can calculate fully offline.
      return (
        latitude: defaultLatitude,
        longitude: defaultLongitude,
      );
    }
  }

  Future<void> cacheLastKnownLocation(double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_prefsLat, lat);
    await prefs.setDouble(_prefsLng, lng);
  }

  Future<({double latitude, double longitude})?> getCachedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(_prefsLat);
    final lng = prefs.getDouble(_prefsLng);
    if (lat == null || lng == null) return null;
    return (latitude: lat, longitude: lng);
  }

  Stream<Position> getPositionStream({int distanceFilter = 50}) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: distanceFilter,
      ),
    );
  }

  static Future<bool> hasPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> requestPermission() async {
    try {
      final permission = await Geolocator.requestPermission();
      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (_) {
      return false;
    }
  }

  Future<bool> openSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (_) {
      return false;
    }
  }
}

import 'package:geolocator/geolocator.dart';

/// Shared location service used by MosqueSearchCubit.
///
/// Place at: lib/core/services/location_service.dart
///
/// This is a separate class from GeolocationService (used by the home feature).
/// MosqueSearchCubit instantiates LocationService directly as an instance
/// (not a static class), so we keep it as a normal class with instance methods.
class LocationService {
  /// Returns the device's current [Position].
  ///
  /// Handles all permission and service-enabled checks internally.
  /// Throws a plain [Exception] with a clear message on any failure so
  /// MosqueSearchCubit can catch it and emit MosqueSearchError.
  Future<Position> getCurrentLocation() async {
    // 1. Check if GPS / network location is switched on
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(
        'Location services are disabled. '
        'Please enable GPS on your device and try again.',
      );
    }

    // 2. Check current permission status
    LocationPermission permission = await Geolocator.checkPermission();

    // 3. Request if not yet decided
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception(
          'Location permission was denied. '
          'Please allow location access to find nearby mosques.',
        );
      }
    }

    // 4. Permanently denied — must go to system settings
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission is permanently denied. '
        'Please enable it in your device settings.',
      );
    }

    // 5. Permission granted — get the position
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
      timeLimit: const Duration(seconds: 15),
    );
  }
}
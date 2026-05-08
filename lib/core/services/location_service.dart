import 'package:geolocator/geolocator.dart';

/// Shared location service used by MosqueSearchCubit.
/// Place at: lib/core/services/location_service.dart
class LocationService {
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

    // 5. Permission granted — get position
    //
    // geolocator v14 API:
    //   • desiredAccuracy and timeLimit were removed as top-level params (deprecated since v9)
    //   • They moved into LocationSettings, but timeLimit was also removed from
    //     LocationSettings in v14 — the official docs example only uses accuracy
    //     and distanceFilter. Using timeLimit causes a TimeoutException on many
    //     Android devices (known geolocator issue #1611).
    //   • Drop timeLimit entirely; rely on the OS to resolve the position.
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
      ),
    );
  }
}
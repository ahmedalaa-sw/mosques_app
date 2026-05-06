  import 'package:geolocator/geolocator.dart';

  /// Service for handling device geolocation with permission management
  class GeolocationService {
    /// Get user's current location coordinates
    /// Throws exception if location permission is denied or unavailable
    static Future<Position> getCurrentLocation() async {
      try {
        // Check if location services are enabled
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          throw Exception('Location services are disabled. Please enable them.');
        }

        // Check current permission status
        LocationPermission permission = await Geolocator.checkPermission();

        // Request permission if not granted
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            throw Exception('Location permissions are denied.');
          }
        }

        // Handle permanently denied permissions
        if (permission == LocationPermission.deniedForever) {
          throw Exception(
            'Location permissions are permanently denied. '
            'Please enable them in app settings.',
          );
        }

        // Get and return the current position
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 15),
        );

        return position;
      } catch (e) {
        throw Exception('Failed to get location: $e');
      }
    }

    /// Request location permission explicitly
    /// Returns true if permission is granted
    static Future<bool> requestLocationPermission() async {
      try {
        final permission = await Geolocator.requestPermission();
        return permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always;
      } catch (e) {
        return false;
      }
    }

    /// Check if location permission is granted
    static Future<bool> hasLocationPermission() async {
      try {
        final permission = await Geolocator.checkPermission();
        return permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always;
      } catch (e) {
        return false;
      }
    }

    /// Open app settings for the user to manually enable location
    static Future<bool> openLocationSettings() async {
      try {
        return await Geolocator.openLocationSettings();
      } catch (e) {
        return false;
      }
    }
  }

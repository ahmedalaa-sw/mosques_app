import 'package:geolocator/geolocator.dart';
import 'package:mosques_app/core/constants/app_strings.dart';

class LocationException implements Exception {
  final String message;
  const LocationException(this.message);

  @override
  String toString() => message;
}

class LocationService {
  Future<Position> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException(AppStrings.locationServicesDisabled);
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationException(AppStrings.locationPermissionDenied);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        AppStrings.locationPermissionPermanentlyDenied,
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }
}

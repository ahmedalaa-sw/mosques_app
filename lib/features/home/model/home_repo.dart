import 'package:dartz/dartz.dart';
import 'package:mosques_app/core/services/adhan_prayer_service.dart';
import 'package:mosques_app/core/utils/geolocation_service.dart';
import 'package:mosques_app/core/errors/failures.dart';
import 'home_model.dart';

/// Repository for offline prayer-time calculation using adhan_dart.
/// Zero network calls — all computation happens on-device.
class HomeRepository {
  // ── Public API ─────────────────────────────────────────────────────────────

  /// Resolve device GPS position, then calculate today's prayer times.
  Future<Either<Failure, AladhanPrayerTimesModel>>
  getPrayerTimesForCurrentLocation() async {
    try {
      final position = await GeolocationService.getCurrentLocation();
      return _calculate(position.latitude, position.longitude);
    } on LocationPermissionException catch (e) {
      return Left(
        ServerFailure('Location permission error: ${e.message}', 403),
      );
    } catch (e) {
      return Left(ServerFailure('Failed to get location: $e', 500));
    }
  }

  /// Calculate prayer times for explicit [latitude] / [longitude] coordinates.
  /// Useful for manual location entry — no GPS required.
  Future<Either<Failure, AladhanPrayerTimesModel>> getPrayerTimesForLocation({
    required double latitude,
    required double longitude,
  }) => _calculate(latitude, longitude);

  Future<bool> hasLocationPermission() =>
      GeolocationService.hasLocationPermission();

  Future<bool> requestLocationPermission() =>
      GeolocationService.requestLocationPermission();

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<Either<Failure, AladhanPrayerTimesModel>> _calculate(
    double latitude,
    double longitude,
  ) async {
    try {
      final prayerTimes = AdhanPrayerService.calculatePrayerTimes(
        latitude: latitude,
        longitude: longitude,
      );
      return Right(
        AladhanPrayerTimesModel.fromAdhanPrayerTimes(
          prayerTimes: prayerTimes,
          latitude: latitude,
          longitude: longitude,
          methodName: AdhanPrayerService.defaultMethodName,
        ),
      );
    } catch (e) {
      return Left(ServerFailure('Prayer time calculation failed: $e', 500));
    }
  }
}

/// Thrown by [GeolocationService] when location permission is missing.
/// Defined here so both the service and the repository share one import.
class LocationPermissionException implements Exception {
  final String message;
  const LocationPermissionException(this.message);

  @override
  String toString() => 'LocationPermissionException: $message';
}

import 'package:dartz/dartz.dart';
import 'package:mosques_app/core/services/adhan_prayer_service.dart';
import 'package:mosques_app/core/services/location_service.dart';
import 'package:mosques_app/core/services/shared_location_service.dart';
import 'package:mosques_app/core/errors/failures.dart';
import 'home_model.dart';

class HomeRepository {
  Future<Either<Failure, AladhanPrayerTimesModel>>
  getPrayerTimesForCurrentLocation() async {
    try {
      final position =
          await SharedLocationService.instance.getCurrentLocation();
      return _calculatePrayerTime(position.latitude, position.longitude);
    } catch (e) {
      return Left(ServerFailure('Failed to get location: $e', 500));
    }
  }

  Future<Either<Failure, AladhanPrayerTimesModel>> getPrayerTimesForLocation({
    required double latitude,
    required double longitude,
  }) => _calculatePrayerTime(latitude, longitude);

  Future<bool> hasLocationPermission() => LocationService.hasPermission();

  Future<bool> requestLocationPermission() =>
      LocationService.requestPermission();

  Future<Either<Failure, AladhanPrayerTimesModel>> _calculatePrayerTime(
    double latitude,
    double longitude,
  ) async {
    try {
      final result = await AdhanPrayerService.calculatePrayerTime(
        latitude: latitude,
        longitude: longitude,
      ).timeout(const Duration(seconds: 10));

      return Right(
        AladhanPrayerTimesModel.fromPrayerCalculationResult(
          result: result,
          latitude: latitude,
          longitude: longitude,
        ),
      );
    } catch (e) {
      return Left(ServerFailure('Prayer time calculation failed: $e', 500));
    }
  }
}
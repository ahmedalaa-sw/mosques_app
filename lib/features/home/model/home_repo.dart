import 'package:dartz/dartz.dart';
import 'package:mosques_app/core/services/adhan_prayer_service.dart';
import 'package:mosques_app/core/services/location_service.dart';
import 'package:mosques_app/core/errors/failures.dart';
import 'home_model.dart';

class HomeRepository {
  final _locationService = LocationService();

  Future<Either<Failure, AladhanPrayerTimesModel>>
  getPrayerTimesForCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
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

  Future<bool> requestLocationPermission() => LocationService.requestPermission();

  Future<Either<Failure, AladhanPrayerTimesModel>> _calculatePrayerTime(
    double latitude,
    double longitude,
  ) async {
    try {
      final prayerTimes = await AdhanPrayerService.calculatePrayerTime(
        latitude: latitude,
        longitude: longitude,
      );

      return Right(
        AladhanPrayerTimesModel.fromAdhanPrayerTimes(
          prayerTimes: prayerTimes,
          latitude: latitude,
          longitude: longitude,
        ),
      );
    } catch (e) {
      print('❌ Prayer time calculation failed: $e');
      return Left(ServerFailure('Prayer time calculation failed: $e', 500));
    }
  }
}

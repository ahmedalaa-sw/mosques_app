import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:mosques_app/core/services/adhan_prayer_service.dart';
import 'package:mosques_app/core/services/location_service.dart';
import 'package:mosques_app/core/errors/failures.dart';
import 'package:mosques_app/core/utils/prayer_wall_clock_format.dart';
import 'home_model.dart';

class HomeRepository {
  final _locationService = LocationService();

  Future<Either<Failure, AladhanPrayerTimesModel>>
  getPrayerTimesForCurrentLocation() async {
    try {
      final coordinates = await _locationService.getBestEffortCoordinates();
      return _calculatePrayerTime(coordinates.latitude, coordinates.longitude);
    } catch (e) {
      return Left(
        ServerFailure('Failed to resolve coordinates for prayer times: $e', 500),
      );
    }
  }

  Future<Either<Failure, AladhanPrayerTimesModel>> getPrayerTimesForLocation({
    required double latitude,
    required double longitude,
  }) => _calculatePrayerTime(latitude, longitude);

  Future<Either<Failure, AladhanPrayerTimesModel>> _calculatePrayerTime(
    double latitude,
    double longitude,
  ) async {
    try {
      final prayerTimes = await AdhanPrayerService.calculatePrayerTime(
        latitude: latitude,
        longitude: longitude,
      );

      PrayerWallClockFormat.debugLogPrayerSchedule('[HomeRepository]', prayerTimes);

      return Right(
        AladhanPrayerTimesModel.fromAdhanPrayerTimes(
          prayerTimes: prayerTimes,
          latitude: latitude,
          longitude: longitude,
        ),
      );
    } catch (e) {
      debugPrint('❌ Prayer time calculation failed: $e');
      return Left(ServerFailure('Prayer time calculation failed: $e', 500));
    }
  }
}

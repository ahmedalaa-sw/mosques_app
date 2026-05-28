import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:mosques_app/core/errors/failures.dart';
import 'package:mosques_app/core/services/adhan_prayer_service.dart';
import 'package:mosques_app/core/services/location_service.dart';
import 'package:mosques_app/core/services/prayer_api_service.dart';
import 'package:mosques_app/core/services/prayer_cache_service.dart';
import 'package:mosques_app/core/services/prayer_validation_service.dart';
import 'package:mosques_app/core/services/shared_location_service.dart';
import 'package:mosques_app/core/utils/location_utils.dart';
import 'package:mosques_app/core/utils/timezone_resolver.dart';
import 'home_model.dart';

class HomeRepository {
  Future<Either<Failure, AladhanPrayerTimesModel>>
  getPrayerTimesForCurrentLocation() async {
    try {
      final position = await SharedLocationService.instance
          .getCurrentLocation();
      return _calculatePrayerTime(
        position.latitude,
        position.longitude,
        altitude: position.altitude,
      );
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
    double longitude, {
    double? altitude,
  }) async {
    final countryCode = await LocationUtils.getCountryCode(latitude, longitude);
    final ianaTimezone = TimezoneResolver.fromCountryCode(countryCode);

    // Use cached prayers if valid, before network or fallback calculations.
    final cached = await PrayerCacheService.loadValidCachedPrayerTimes();
    if (cached != null) {
      return Right(cached);
    }

    try {
      final apiPrayer = await PrayerApiService.fetchPrayerTimes(
        latitude: latitude,
        longitude: longitude,
        altitude: altitude ?? 0,
        countryCode: countryCode,
        ianaTimezone: ianaTimezone,
      );

      await PrayerCacheService.savePrayerTimes(apiPrayer);
      return Right(apiPrayer);
    } catch (apiError) {
      if (kDebugMode) {
        debugPrint('[HomeRepo] AlAdhan API failed: $apiError');
      }
    }

    try {
      final result = await AdhanPrayerService.calculatePrayerTime(
        latitude: latitude,
        longitude: longitude,
      ).timeout(const Duration(seconds: 10));

      final validation = PrayerValidationService.validate(result.prayerTimes);
      if (!validation.isValid) {
        if (kDebugMode) {
          debugPrint('[HomeRepo] Validation error: ${validation.error}');
        }
        return Left(
          ServerFailure(
            'Prayer time validation failed: ${validation.error}',
            500,
          ),
        );
      }

      if (validation.warnings != null && validation.warnings!.isNotEmpty) {
        if (kDebugMode) {
          for (final w in validation.warnings!) {
            debugPrint('[HomeRepo] ⚠ $w');
          }
        }
      }

      final fallbackPrayer =
          AladhanPrayerTimesModel.fromPrayerCalculationResult(
            result: result,
            latitude: latitude,
            longitude: longitude,
            countryCode: countryCode,
            altitude: altitude ?? 0,
          );
      await PrayerCacheService.savePrayerTimes(fallbackPrayer);
      return Right(fallbackPrayer);
    } catch (e) {
      return Left(ServerFailure('Prayer time calculation failed: $e', 500));
    }
  }
}

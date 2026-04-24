import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:mosques_app/core/network/dio_helper.dart';
import 'package:mosques_app/core/utils/geolocation_service.dart';
import 'package:mosques_app/core/errors/failures.dart';
import 'home_model.dart';

/// Repository for handling prayer times data and location services
class HomeRepository {
  /// Fetch prayer times from Aladhan API based on user's geolocation
  Future<Either<Failure, AladhanPrayerTimesModel>> getPrayerTimesForCurrentLocation() async {
    try {
      // Step 1: Get user's current location
      final position = await GeolocationService.getCurrentLocation();

      // Step 2: Fetch prayer times from Aladhan API
      return await _fetchPrayerTimesFromApi(
        position.latitude,
        position.longitude,
      );
    } on LocationPermissionException catch (e) {
      return Left(ServerFailure('Location permission error: ${e.message}', 403));
    } catch (e) {
      return Left(ServerFailure('Failed to get prayer times: $e', 500));
    }
  }

  /// Fetch prayer times from Aladhan API for specific coordinates
  /// Method 2 is the most accurate (Jafari method)
  /// Adjustment parameter: 0 for no adjustment, 1 for midnight sun, 2 for half of night, etc.
  Future<Either<Failure, AladhanPrayerTimesModel>> _fetchPrayerTimesFromApi(
    double latitude,
    double longitude,
  ) async {
    try {
      final apiUrl =
          'https://api.aladhan.com/v1/timings/${DateTime.now().millisecondsSinceEpoch ~/ 1000}';

      final response = await DioHelper.getData(
        endpoint: apiUrl,
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'method': 2, // Jafari method
          'school': 0, // Shafi school
          'adjustment': 0,
        },
      );

      if (response.statusCode != 200) {
        return Left(ServerFailure(
          'API returned status code ${response.statusCode}',
          response.statusCode ?? 500,
        ));
      }

      final data = response.data;
      if (data == null || data is! Map<String, dynamic>) {
        return Left(ServerFailure('Invalid API response format', 400));
      }

      if (data['code'] != 200) {
        return Left(ServerFailure(
          'API error: ${data['status'] ?? 'Unknown error'}',
          data['code'] ?? 500,
        ));
      }

      final prayerModel = AladhanPrayerTimesModel.fromJson(data['data']);
      return Right(prayerModel);
    } on DioException catch (e) {
      return Left(ServerFailure(
        'Network error: ${e.message ?? 'Unknown error'}',
        e.response?.statusCode ?? 500,
      ));
    } catch (e) {
      return Left(ServerFailure('Failed to fetch prayer times: $e', 500));
    }
  }

  /// Get prayer times with explicit coordinates (for testing or manual location)
  Future<Either<Failure, AladhanPrayerTimesModel>> getPrayerTimesForLocation({
    required double latitude,
    required double longitude,
  }) async {
    return await _fetchPrayerTimesFromApi(latitude, longitude);
  }

  /// Check if location permission is already granted
  Future<bool> hasLocationPermission() {
    return GeolocationService.hasLocationPermission();
  }

  /// Request location permission
  Future<bool> requestLocationPermission() {
    return GeolocationService.requestLocationPermission();
  }
}

/// Custom exception for location permission errors
class LocationPermissionException implements Exception {
  final String message;
  LocationPermissionException(this.message);

  @override
  String toString() => 'LocationPermissionException: $message';
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosques_app/core/errors/failures.dart';
import 'package:mosques_app/features/home/model/home_model.dart';
import 'package:mosques_app/features/home/model/home_repo.dart';
import 'home_state.dart';

/// Cubit for managing home screen state
/// Handles prayer times fetching and location permissions
class HomeCubit extends Cubit<HomeState> {
  final HomeRepository repository;

  HomeCubit({required this.repository}) : super(const HomeInitial());

  /// Load prayer times based on user's current location
  /// Automatically requests location permission if needed
  Future<void> loadPrayerTimes() async {
    try {
      emit(const HomeLoading());

      // Check if location permission is granted
      bool hasPermission = await repository.hasLocationPermission();

      if (!hasPermission) {
        // Request permission if not granted
        bool permissionGranted =
            await repository.requestLocationPermission();

        if (!permissionGranted) {
          emit(const HomePermissionDenied(
            message:
                'Location permission is required to display prayer times. '
                'Please enable it in app settings.',
          ));
          return;
        }
      }

      // Fetch prayer times for current location
      final result = await repository.getPrayerTimesForCurrentLocation();

      result.fold(
        (failure) {
          if (failure is ServerFailure && failure.statusCode == 403) {
            emit(HomePermissionDenied(message: failure.message));
          } else {
            emit(HomeError(
              message: failure.message,
              statusCode: failure is ServerFailure ? failure.statusCode : null,
            ));
          }
        },
        (prayerTimes) {
          // Get current prayer (simplified - in production, calculate based on actual time)
          final currentPrayer = _getCurrentPrayerName(prayerTimes);

          // Convert to prayer model list
          final prayers = prayerTimes.toHousePrayerModels(currentPrayer);

          emit(HomeLoaded(prayerTimes: prayerTimes, prayers: prayers));
        },
      );
    } catch (e) {
      emit(HomeError(
        message: e.toString().replaceFirst('Exception: ', ''),
        statusCode: null,
      ));
    }
  }

  /// Reload prayer times (manual refresh)
  Future<void> refreshPrayerTimes() {
    return loadPrayerTimes();
  }

  /// Get prayer times for specific coordinates (for manual location input)
  Future<void> loadPrayerTimesForLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      emit(const HomeLoading());

      final result = await repository.getPrayerTimesForLocation(
        latitude: latitude,
        longitude: longitude,
      );

      result.fold(
        (failure) {
          emit(HomeError(
            message: failure.message,
            statusCode: failure is ServerFailure ? failure.statusCode : null,
          ));
        },
        (prayerTimes) {
          final currentPrayer = _getCurrentPrayerName(prayerTimes);
          final prayers = prayerTimes.toHousePrayerModels(currentPrayer);

          emit(HomeLoaded(prayerTimes: prayerTimes, prayers: prayers));
        },
      );
    } catch (e) {
      emit(HomeError(
        message: e.toString().replaceFirst('Exception: ', ''),
        statusCode: null,
      ));
    }
  }

  /// Determine which prayer is currently ongoing
  /// This is a simplified version - in production, you'd compare with actual prayer times
  String? _getCurrentPrayerName(AladhanPrayerTimesModel prayerTimes) {
    // This is a placeholder - you can enhance it to parse actual prayer times
    // and compare with current time to determine which prayer is ongoing
    // For now, we'll return null which means no specific prayer is highlighted
    return null;
  }
}

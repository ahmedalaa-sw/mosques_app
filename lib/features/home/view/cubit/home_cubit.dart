import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosques_app/core/errors/failures.dart';
import 'package:mosques_app/core/services/background_reschedule_service.dart';
import 'package:mosques_app/core/services/notification_service.dart';
import 'package:mosques_app/features/home/model/home_model.dart';
import 'package:mosques_app/features/home/model/home_repo.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository repository;

  HomeCubit({required this.repository}) : super(const HomeInitial());

  Future<void> loadPrayerTimes() async {
    try {
      emit(const HomeLoading());

      bool hasPermission = await repository.hasLocationPermission();
      if (!hasPermission) {
        bool granted = await repository.requestLocationPermission();
        if (!granted) {
          emit(
            const HomePermissionDenied(
              message:
                  'Location permission is required to display prayer times. '
                  'Please enable it in app settings.',
            ),
          );
          return;
        }
      }

      final result = await repository.getPrayerTimesForCurrentLocation();
      result.fold(
        (failure) {
          if (failure is ServerFailure && failure.statusCode == 403) {
            emit(HomePermissionDenied(message: failure.message));
          } else {
            emit(
              HomeError(
                message: failure.message,
                statusCode: failure is ServerFailure
                    ? failure.statusCode
                    : null,
              ),
            );
          }
        },
        (prayerTimes) {
          final currentPrayer = _getCurrentPrayerName(prayerTimes);
          final prayers = prayerTimes.toHousePrayerModels(currentPrayer);
          emit(HomeLoaded(prayerTimes: prayerTimes, prayers: prayers));
          _scheduleNotifications(prayerTimes);
          BackgroundRescheduleService.cacheLastLocation(
            prayerTimes.latitude,
            prayerTimes.longitude,
          );
        },
      );
    } catch (e) {
      emit(
        HomeError(
          message: e.toString().replaceFirst('Exception: ', ''),
          statusCode: null,
        ),
      );
    }
  }

  Future<void> refreshPrayerTimes() => loadPrayerTimes();

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
        (failure) => emit(
          HomeError(
            message: failure.message,
            statusCode: failure is ServerFailure ? failure.statusCode : null,
          ),
        ),
        (prayerTimes) {
          final currentPrayer = _getCurrentPrayerName(prayerTimes);
          final prayers = prayerTimes.toHousePrayerModels(currentPrayer);
          emit(HomeLoaded(prayerTimes: prayerTimes, prayers: prayers));
          _scheduleNotifications(prayerTimes);
          BackgroundRescheduleService.cacheLastLocation(
            prayerTimes.latitude,
            prayerTimes.longitude,
          );
        },
      );
    } catch (e) {
      emit(
        HomeError(
          message: e.toString().replaceFirst('Exception: ', ''),
          statusCode: null,
        ),
      );
    }
  }

  String? _getCurrentPrayerName(AladhanPrayerTimesModel prayerTimes) {
    try {
      final now = DateTime.now();
      final currentMinutes = now.hour * 60 + now.minute;

      // TimeOfDay.fromString() does NOT exist in Flutter's SDK.
      // We parse "HH:mm" strings directly instead.
      final prayers = [
        ('Fajr', _parseMinutes(prayerTimes.fajr)),
        ('Sunrise', _parseMinutes(prayerTimes.sunrise)),
        ('Dhuhr', _parseMinutes(prayerTimes.dhuhr)),
        ('Asr', _parseMinutes(prayerTimes.asr)),
        ('Maghrib', _parseMinutes(prayerTimes.maghrib)),
        ('Isha', _parseMinutes(prayerTimes.isha)),
      ];

      for (int i = 0; i < prayers.length; i++) {
        final (name, startMin) = prayers[i];
        if (i < prayers.length - 1) {
          final endMin = prayers[i + 1].$2;
          if (currentMinutes >= startMin && currentMinutes < endMin) {
            return name;
          }
        } else {
          // After Isha — still Isha until midnight
          if (currentMinutes >= startMin) return name;
        }
      }
      return null; // before Fajr
    } catch (_) {
      return null;
    }
  }

  /// Parse "HH:mm" string into total minutes since midnight.
  int _parseMinutes(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length != 2) return 0;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    return h * 60 + m;
  }

  /// Convert prayer time strings to today's DateTimes and hand them to the
  /// [NotificationService] for 15-min-before scheduling.
  void _scheduleNotifications(AladhanPrayerTimesModel prayerTimes) {
    final today = DateTime.now();

    DateTime _toDateTime(String hhmm) {
      final parts = hhmm.split(':');
      final h = int.tryParse(parts[0]) ?? 0;
      final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
      return DateTime(today.year, today.month, today.day, h, m);
    }

    final prayers = <String, DateTime>{
      'Fajr': _toDateTime(prayerTimes.fajr),
      'Sunrise': _toDateTime(prayerTimes.sunrise),
      'Dhuhr': _toDateTime(prayerTimes.dhuhr),
      'Asr': _toDateTime(prayerTimes.asr),
      'Maghrib': _toDateTime(prayerTimes.maghrib),
      'Isha': _toDateTime(prayerTimes.isha),
    };

    NotificationService.instance.schedulePrayerNotifications(prayers);
  }
}

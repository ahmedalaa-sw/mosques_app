import 'package:mosques_app/features/home/model/home_model.dart';

/// Base class for home screen states
abstract class HomeState {
  const HomeState();
}

/// Initial state - no data loaded yet
class HomeInitial extends HomeState {
  const HomeInitial();
}

/// Loading state - fetching prayer times
class HomeLoading extends HomeState {
  const HomeLoading();
}

/// Success state - prayer times loaded successfully
class HomeLoaded extends HomeState {
  final AladhanPrayerTimesModel prayerTimes;
  final List<PrayerModel> prayers;

  const HomeLoaded({required this.prayerTimes, required this.prayers});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HomeLoaded &&
          runtimeType == other.runtimeType &&
          prayerTimes == other.prayerTimes;

  @override
  int get hashCode => prayerTimes.hashCode;
}

/// Error state - failed to load prayer times
class HomeError extends HomeState {
  final String message;
  final int? statusCode;

  const HomeError({required this.message, this.statusCode});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HomeError &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          statusCode == other.statusCode;

  @override
  int get hashCode => message.hashCode ^ statusCode.hashCode;
}

/// Permission denied state - location permission was denied
class HomePermissionDenied extends HomeState {
  final String message;

  const HomePermissionDenied({required this.message});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HomePermissionDenied &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}
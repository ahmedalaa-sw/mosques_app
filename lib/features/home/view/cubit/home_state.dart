import 'package:mosques_app/features/home/model/home_model.dart';

abstract class HomeState {
  const HomeState();
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final AladhanPrayerTimesModel prayerTimes;
  final List<PrayerModel> prayers;

  // Included in equality so that a prayer transition (same data, different
  // active prayer) is treated as a new state and triggers BlocBuilder rebuilds.
  final String? currentPrayerName;

  const HomeLoaded({
    required this.prayerTimes,
    required this.prayers,
    this.currentPrayerName,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HomeLoaded &&
          runtimeType == other.runtimeType &&
          prayerTimes == other.prayerTimes &&
          currentPrayerName == other.currentPrayerName;

  @override
  int get hashCode => prayerTimes.hashCode ^ currentPrayerName.hashCode;
}

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

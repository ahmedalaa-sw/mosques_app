import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import 'location_permission_state.dart';

class LocationPermissionCubit extends Cubit<LocationPermissionState> {
  LocationPermissionCubit() : super(LocationPermissionInitial());

  Future<void> checkPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(LocationServiceDisabled());
        return;
      }
      final permission = await Geolocator.checkPermission();
      emit(_fromPermission(permission));
    } catch (_) {
      emit(LocationPermissionDenied());
    }
  }

  Future<void> requestPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(LocationServiceDisabled());
        return;
      }
      final permission = await Geolocator.requestPermission();
      emit(_fromPermission(permission));
    } catch (_) {
      emit(LocationPermissionDenied());
    }
  }

  LocationPermissionState _fromPermission(LocationPermission permission) =>
      switch (permission) {
        LocationPermission.always ||
        LocationPermission.whileInUse =>
          LocationPermissionGranted(),
        LocationPermission.deniedForever => LocationPermissionDeniedForever(),
        _ => LocationPermissionDenied(),
      };
}

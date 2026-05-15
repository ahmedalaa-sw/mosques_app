abstract class LocationPermissionState {}

class LocationPermissionInitial extends LocationPermissionState {}

class LocationPermissionGranted extends LocationPermissionState {}

class LocationPermissionDenied extends LocationPermissionState {}

class LocationPermissionDeniedForever extends LocationPermissionState {}

class LocationServiceDisabled extends LocationPermissionState {}

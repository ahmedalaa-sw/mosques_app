import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> getCurrentLocation() async {
    if (kDebugMode) debugPrint('[Loc] A — isLocationServiceEnabled?');
    final serviceEnabled = await Geolocator.isLocationServiceEnabled()
        .timeout(const Duration(seconds: 5));
    if (kDebugMode) debugPrint('[Loc] B — serviceEnabled=$serviceEnabled');
    if (!serviceEnabled) {
      throw Exception(
        'Location services are disabled. '
        'Please enable GPS on your device and try again.',
      );
    }

    if (kDebugMode) debugPrint('[Loc] C — checkPermission');
    final permission = await Geolocator.checkPermission()
        .timeout(const Duration(seconds: 5));
    if (kDebugMode) debugPrint('[Loc] D — permission=$permission');

    // Only guard; permission requesting belongs to HomeCubit / the caller.
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission is not granted. '
        'Please allow location access in app settings.',
      );
    }

    if (kDebugMode) debugPrint('[Loc] E — getCurrentPosition (timeout 15s)');
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 15),
      ),
    ).timeout(
      const Duration(seconds: 15),
      onTimeout: () => throw Exception(
        'Location timed out. Please ensure GPS is enabled and try again.',
      ),
    );
    if (kDebugMode) debugPrint('[Loc] F — position=${pos.latitude},${pos.longitude}');
    return pos;
  }

  /// Returns a continuous position stream filtered at the OS level.
  ///
  /// [distanceFilter] — minimum metres the device must move before the OS
  /// emits a new position (saves battery). The app-level threshold check in
  /// [MosqueSearchCubit] is separate and coarser.
  Stream<Position> getPositionStream({int distanceFilter = 50}) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: distanceFilter,
      ),
    );
  }

  static Future<bool> hasPermission() async {
    try {
      final p = await Geolocator.checkPermission();
      return p == LocationPermission.whileInUse || p == LocationPermission.always;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> requestPermission() async {
    try {
      final p = await Geolocator.requestPermission();
      return p == LocationPermission.whileInUse || p == LocationPermission.always;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> openSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (_) {
      return false;
    }
  }
}

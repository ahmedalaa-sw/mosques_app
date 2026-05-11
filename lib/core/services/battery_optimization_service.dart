import 'dart:io';
import 'package:flutter/services.dart';

/// Checks and requests Android battery-optimization exemption via a native
/// MethodChannel backed by MainActivity.kt.
///
/// On iOS (and on failure) every method is a safe no-op / returns true so
/// callers need no platform guards.
class BatteryOptimizationService {
  BatteryOptimizationService._();

  static const _channel = MethodChannel('com.example.mosques_app/system');

  /// Returns true if the app is already excluded from battery optimization,
  /// or if the platform is not Android.
  static Future<bool> isIgnoringBatteryOptimizations() async {
    if (!Platform.isAndroid) return true;
    try {
      return await _channel.invokeMethod<bool>('isIgnoringBatteryOptimizations') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Opens the system dialog that lets the user exempt this app from battery
  /// optimization. On Android 6+ this shows a system dialog; on older versions
  /// it falls back to the battery settings screen.
  static Future<void> requestIgnoreBatteryOptimizations() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('requestIgnoreBatteryOptimizations');
    } catch (_) {}
  }
}

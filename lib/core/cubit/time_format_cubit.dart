import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'time_format_state.dart';

/// Reads the LIVE 12h/24h system setting via a native platform channel.
/// Polls every 3 seconds so the UI reacts even if the user flips
/// the toggle in Android Settings while the app is running.
class TimeFormatCubit extends Cubit<TimeFormatState>
    with WidgetsBindingObserver {
  TimeFormatCubit() : super(const TimeFormatState(is24Hour: false));

  static const _channel = MethodChannel('com.example.mosques_app/time_format');
  Timer? _pollTimer;

  /// Call once after creation (e.g. right after BlocProvider).
  void init() {
    WidgetsBinding.instance.addObserver(this);
    _fetchAndEmit(); // initial read
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _fetchAndEmit();
    });
  }

  /// Reads the live system value from the native side.
  Future<void> _fetchAndEmit() async {
    try {
      final bool is24 = await _channel.invokeMethod<bool>('is24HourFormat') ?? false;
      if (is24 != state.is24Hour) {
        emit(TimeFormatState(is24Hour: is24));
      }
    } on PlatformException catch (_) {
      // Native channel not available (e.g. iOS / desktop) —
      // fall back to PlatformDispatcher.
      final fallback = WidgetsBinding.instance.platformDispatcher.alwaysUse24HourFormat;
      if (fallback != state.is24Hour) {
        emit(TimeFormatState(is24Hour: fallback));
      }
    }
  }

  /// Also re-check when the app comes back to foreground.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _fetchAndEmit();
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    return super.close();
  }
}
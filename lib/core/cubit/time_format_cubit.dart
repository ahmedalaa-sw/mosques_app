import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'time_format_state.dart';

/// Reads the 12h/24h system setting via a native platform channel.
/// Re-checks once at startup and again whenever the app comes back to the
/// foreground — the only moment the setting could have changed.
class TimeFormatCubit extends Cubit<TimeFormatState>
    with WidgetsBindingObserver {
  TimeFormatCubit() : super(const TimeFormatState(is24Hour: false));

  static const _channel = MethodChannel('com.example.mosques_app/time_format');

  /// Call once after creation (e.g. right after BlocProvider).
  void init() {
    WidgetsBinding.instance.addObserver(this);
    _fetchAndEmit();
  }

  Future<void> _fetchAndEmit() async {
    try {
      final bool is24 = await _channel.invokeMethod<bool>('is24HourFormat') ?? false;
      if (is24 != state.is24Hour) emit(TimeFormatState(is24Hour: is24));
    } on PlatformException catch (_) {
      final fallback = WidgetsBinding.instance.platformDispatcher.alwaysUse24HourFormat;
      if (fallback != state.is24Hour) emit(TimeFormatState(is24Hour: fallback));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _fetchAndEmit();
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    return super.close();
  }
}
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosques_app/core/services/adhan_prayer_service.dart';
import 'package:mosques_app/core/services/notification_service.dart';
import 'package:mosques_app/features/home/model/home_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'azan_state.dart';

class AzanCubit extends Cubit<AzanState> {
  static const _key        = 'azan_enabled';
  static const _prefsLat   = 'last_known_lat';
  static const _prefsLng   = 'last_known_lng';

  AzanCubit() : super(const AzanState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    emit(AzanState(isAzanEnabled: prefs.getBool(_key) ?? false));
  }

  Future<void> toggleAzan() async {
    final newValue = !state.isAzanEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, newValue);
    emit(AzanState(isAzanEnabled: newValue));
    await _rescheduleWithNewPreference(newValue, prefs);
  }

  /// Recalculates today's prayer times from the cached location and
  /// reschedules all notifications using the correct audio file for [enabled].
  Future<void> _rescheduleWithNewPreference(
    bool enabled,
    SharedPreferences prefs,
  ) async {
    try {
      final lat = prefs.getDouble(_prefsLat);
      final lng = prefs.getDouble(_prefsLng);
      if (lat == null || lng == null) return;

      final rawTimes = await AdhanPrayerService.calculatePrayerTime(
        latitude: lat,
        longitude: lng,
      );
      final model = AladhanPrayerTimesModel.fromAdhanPrayerTimes(
        prayerTimes: rawTimes,
        latitude: lat,
        longitude: lng,
      );

      final today = DateTime.now();
      DateTime toDateTime(String hhmm) {
        final parts = hhmm.split(':');
        final h = int.tryParse(parts[0]) ?? 0;
        final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
        return DateTime(today.year, today.month, today.day, h, m);
      }

      await NotificationService.instance.schedulePrayerNotifications(
        {
          'Fajr'   : toDateTime(model.fajr),
          'Sunrise': toDateTime(model.sunrise),
          'Dhuhr'  : toDateTime(model.dhuhr),
          'Asr'    : toDateTime(model.asr),
          'Maghrib': toDateTime(model.maghrib),
          'Isha'   : toDateTime(model.isha),
        },
        azanEnabled: enabled,
      );
    } catch (_) {
      // Fail silently — prayer notifications remain from the last full schedule.
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosques_app/core/services/adhan_prayer_service.dart';
import 'package:mosques_app/core/services/notification_service.dart';
import 'package:mosques_app/core/utils/location_utils.dart';
import 'package:mosques_app/features/home/model/home_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'azan_state.dart';

class AzanCubit extends Cubit<AzanState> {
  static const _key      = 'azan_enabled';
  static const _prefsLat = 'last_known_lat';
  static const _prefsLng = 'last_known_lng';

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

  /// Recalculates today's and tomorrow's prayer times from the cached location
  /// and reschedules all notifications using the correct audio for [enabled].
  Future<void> _rescheduleWithNewPreference(
    bool enabled,
    SharedPreferences prefs,
  ) async {
    try {
      final lat = prefs.getDouble(_prefsLat);
      final lng = prefs.getDouble(_prefsLng);
      if (lat == null || lng == null) return;

      // Read cached country code so we don't need a network call here.
      final countryCode = prefs.getString(LocationUtils.countryCodePrefsKey) ?? 'US';

      final today    = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));

      Map<String, DateTime> buildDayMap(DateTime day) {
        // calculatePrayerTimesSync is sync — no await needed, no geocoding.
        final raw = AdhanPrayerService.calculatePrayerTimesSync(
          latitude: lat,
          longitude: lng,
          countryCode: countryCode,
          date: day,
        );
        final model = AladhanPrayerTimesModel.fromAdhanPrayerTimes(
          prayerTimes: raw,
          latitude: lat,
          longitude: lng,
        );
        DateTime toDateTime(String hhmm) {
          final parts = hhmm.split(':');
          final h = int.tryParse(parts[0]) ?? 0;
          final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
          return DateTime(day.year, day.month, day.day, h, m);
        }
        return {
          'Fajr'   : toDateTime(model.fajr),
          'Sunrise': toDateTime(model.sunrise),
          'Dhuhr'  : toDateTime(model.dhuhr),
          'Asr'    : toDateTime(model.asr),
          'Maghrib': toDateTime(model.maghrib),
          'Isha'   : toDateTime(model.isha),
        };
      }

      await NotificationService.instance.schedulePrayerNotifications(
        [buildDayMap(today), buildDayMap(tomorrow)],
        azanEnabled: enabled,
      );
    } catch (_) {
      // Fail silently — existing notifications remain until next app open.
    }
  }
}

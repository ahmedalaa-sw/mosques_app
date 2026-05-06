import 'dart:developer' as dev;
import 'dart:ui' show Color;

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';

import 'adhan_prayer_service.dart';
import 'prayer_notification_config.dart';

const _uniqueName         = 'prayerNotificationReschedule';
const _uniqueNamePeriodic = 'prayerNotificationDailySync';

@pragma('vm:entry-point')
void rescheduleCallbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      await BackgroundRescheduleService._rescheduleAll();
      return true;
    } catch (e, st) {
      dev.log('[BackgroundReschedule] FAILED', error: e, stackTrace: st);
      return false;
    }
  });
}

class BackgroundRescheduleService {
  BackgroundRescheduleService._();

  static const _prefsLat     = 'last_known_lat';
  static const _prefsLng     = 'last_known_lng';
  static const _prefsAzanKey = 'azan_enabled';

  static Future<void> registerTasks() async {
    await Workmanager().registerOneOffTask(
      _uniqueName,
      _uniqueName,
      initialDelay: const Duration(minutes: 1),
      existingWorkPolicy: ExistingWorkPolicy.replace,
      constraints: Constraints(networkType: NetworkType.notRequired),
    );
    await Workmanager().registerPeriodicTask(
      _uniqueNamePeriodic,
      _uniqueNamePeriodic,
      frequency: const Duration(hours: 6),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      constraints: Constraints(networkType: NetworkType.notRequired),
    );
  }

  static Future<void> cacheLastLocation(double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_prefsLat, lat);
    await prefs.setDouble(_prefsLng, lng);
  }

  static Future<bool> _rescheduleAll() async {
    tz.initializeTimeZones();
    try {
      final loc = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(loc));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('notification_logo'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
      ),
    );

    final android = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      for (final id in kLegacyChannelIds) {
        await android.deleteNotificationChannel(id);
      }

      await android.createNotificationChannel(
        const AndroidNotificationChannel(
          kPreAlertChannelId,
          kPreAlertChannelName,
          description: kPreAlertChannelDesc,
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
          enableLights: true,
        ),
      );

      for (final config in kPrayerConfigs.values) {
        await android.createNotificationChannel(
          AndroidNotificationChannel(
            config.callChannelId,
            config.channelName,
            description: config.channelDescription,
            importance: Importance.max,
            playSound: true,
            sound: RawResourceAndroidNotificationSound(config.callSound),
            enableVibration: true,
            enableLights: true,
          ),
        );
        await android.createNotificationChannel(
          AndroidNotificationChannel(
            config.azanChannelId,
            '${config.channelName} + Azan',
            description: config.channelDescription,
            importance: Importance.max,
            playSound: true,
            sound: RawResourceAndroidNotificationSound(config.azanSound),
            enableVibration: true,
            enableLights: true,
          ),
        );
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(_prefsLat);
    final lng = prefs.getDouble(_prefsLng);

    double latitude, longitude;
    if (lat != null && lng != null) {
      latitude  = lat;
      longitude = lng;
    } else {
      try {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.low,
            timeLimit: Duration(seconds: 10),
          ),
        );
        latitude  = pos.latitude;
        longitude = pos.longitude;
        await cacheLastLocation(latitude, longitude);
      } catch (_) {
        dev.log('[BackgroundReschedule] No location — cannot reschedule');
        return false;
      }
    }

    final prayerTimes = AdhanPrayerService.calculatePrayerTimes(
      latitude: latitude,
      longitude: longitude,
    );

    final today = DateTime.now();
    DateTime toLocal(DateTime Function(PrayerTimes) getter) {
      final d = getter(prayerTimes).toLocal();
      return DateTime(today.year, today.month, today.day, d.hour, d.minute);
    }

    final prayers = <String, DateTime>{
      'Fajr'   : toLocal((p) => p.fajr),
      'Sunrise': toLocal((p) => p.sunrise),
      'Dhuhr'  : toLocal((p) => p.dhuhr),
      'Asr'    : toLocal((p) => p.asr),
      'Maghrib': toLocal((p) => p.maghrib),
      'Isha'   : toLocal((p) => p.isha),
    };

    // Cancel all previous notifications (including old azan IDs 300–305).
    for (int i = kPreAlertBaseId; i < kPreAlertBaseId + kMaxPrayers; i++) {
      await plugin.cancel(i);
    }
    for (int i = kAtTimeBaseId; i < kAtTimeBaseId + kMaxPrayers; i++) {
      await plugin.cancel(i);
    }
    for (int i = 300; i < 306; i++) {
      await plugin.cancel(i);
    }

    final azanEnabled = prefs.getBool(_prefsAzanKey) ?? false;
    final now = DateTime.now();
    int preId = kPreAlertBaseId;
    int atId  = kAtTimeBaseId;

    for (final entry in prayers.entries) {
      final name = entry.key;
      final time = entry.value;

      final preTime = time.subtract(const Duration(minutes: 15));
      if (!preTime.isBefore(now)) {
        await plugin.zonedSchedule(
          preId,
          '🕌 $name (${_arabic(name)}) in 15 minutes',
          'Get ready — $name starts at ${_fmt(time)}.',
          tz.TZDateTime.from(preTime, tz.local),
          _preAlertDetails(name),
          androidScheduleMode: AndroidScheduleMode.alarmClock,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'pre_alert:$name',
        );
      }

      if (!time.isBefore(now)) {
        await plugin.zonedSchedule(
          atId,
          '🕌 $name (${_arabic(name)}) prayer time',
          "It's time for $name prayer — ${_fmt(time)}.",
          tz.TZDateTime.from(time, tz.local),
          _atTimeDetails(name, azanEnabled: azanEnabled),
          androidScheduleMode: AndroidScheduleMode.alarmClock,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'at_time:$name',
        );
      }

      preId++;
      atId++;
    }

    dev.log(
      '[BackgroundReschedule] Done — rescheduled ${prayers.length} prayers, '
      'azan=${azanEnabled ? "on" : "off"}',
    );
    return true;
  }

  // ── Notification details ──────────────────────────────────────────────────

  static NotificationDetails _preAlertDetails(String name) =>
      NotificationDetails(
        android: AndroidNotificationDetails(
          kPreAlertChannelId,
          kPreAlertChannelName,
          channelDescription: kPreAlertChannelDesc,
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.reminder,
          visibility: NotificationVisibility.public,
          icon: 'notification_logo',
          color: const Color(0xFF84D5C5),
          colorized: true,
          styleInformation: BigTextStyleInformation(
            'Get ready — $name prayer is in 15 minutes.',
            contentTitle: '🕌 $name (${_arabic(name)}) in 15 min',
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      );

  static NotificationDetails _atTimeDetails(
    String name, {
    required bool azanEnabled,
  }) {
    final config = kPrayerConfigs[name] ?? kFallbackPrayerConfig;
    return NotificationDetails(
      android: AndroidNotificationDetails(
        config.channelId(azanEnabled: azanEnabled),
        config.channelDisplayName(azanEnabled: azanEnabled),
        channelDescription: config.channelDescription,
        importance: Importance.max,
        priority: Priority.max,
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
        icon: 'notification_logo',
        color: const Color(0xFFE9C349),
        colorized: true,
        sound: RawResourceAndroidNotificationSound(
          config.sound(azanEnabled: azanEnabled),
        ),
        styleInformation: BigTextStyleInformation(
          "It's time for $name prayer.",
          contentTitle: '🕌 $name (${_arabic(name)})',
        ),
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: config.sound(azanEnabled: azanEnabled),
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );
  }

  static String _fmt(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}';

  static String _arabic(String name) => kArabicNames[name] ?? name;
}

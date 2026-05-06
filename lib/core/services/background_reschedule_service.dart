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

const _uniqueName = 'prayerNotificationReschedule';
const _uniqueNamePeriodic = 'prayerNotificationDailySync';

class _PrayerChannelConfig {
  final String channelId;
  final String channelName;
  final String channelDescription;
  final String soundResource;

  const _PrayerChannelConfig({
    required this.channelId,
    required this.channelName,
    required this.channelDescription,
    required this.soundResource,
  });
}

const _prayerConfigs = <String, _PrayerChannelConfig>{
  'Fajr': _PrayerChannelConfig(
    channelId: 'prayer_fajr_v2',
    channelName: 'Fajr Prayer Time',
    channelDescription: 'Notification for Fajr prayer time',
    soundResource: 'fajr_call',
  ),
  'Sunrise': _PrayerChannelConfig(
    channelId: 'prayer_sunrise_v2',
    channelName: 'Sunrise Time',
    channelDescription: 'Notification for Sunrise time',
    soundResource: 'sunrise_call',
  ),
  'Dhuhr': _PrayerChannelConfig(
    channelId: 'prayer_dhuhr_v2',
    channelName: 'Dhuhr Prayer Time',
    channelDescription: 'Notification for Dhuhr prayer time',
    soundResource: 'dhuhr_call',
  ),
  'Asr': _PrayerChannelConfig(
    channelId: 'prayer_asr_v2',
    channelName: 'Asr Prayer Time',
    channelDescription: 'Notification for Asr prayer time',
    soundResource: 'asr_call',
  ),
  'Maghrib': _PrayerChannelConfig(
    channelId: 'prayer_maghrib_v2',
    channelName: 'Maghrib Prayer Time',
    channelDescription: 'Notification for Maghrib prayer time',
    soundResource: 'maghrib_call',
  ),
  'Isha': _PrayerChannelConfig(
    channelId: 'prayer_isha_v2',
    channelName: 'Isha Prayer Time',
    channelDescription: 'Notification for Isha prayer time',
    soundResource: 'isha_call',
  ),
};

const _fallbackConfig = _PrayerChannelConfig(
  channelId: 'prayer_fajr_v2',
  channelName: 'Fajr Prayer Time',
  channelDescription: 'Notification for Fajr prayer time',
  soundResource: 'fajr_call',
);

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

  static const _prefsLat = 'last_known_lat';
  static const _prefsLng = 'last_known_lng';

  // Must match NotificationService — this isolate is separate so we cannot
  // share constants via instance access without re-creating the channels.
  static const _preAlertChannelId = 'prayer_pre_alert_v2';
  static const _preAlertChannelName = 'Prayer Pre-Alert';
  static const _preAlertChannelDesc =
      'Notifies 15 minutes before each prayer';

  static const _legacyChannelIds = [
    'prayer_times_channel',
    'prayer_at_time_v2',
  ];

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
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    final android = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      for (final id in _legacyChannelIds) {
        await android.deleteNotificationChannel(id);
      }

      await android.createNotificationChannel(
        const AndroidNotificationChannel(
          _preAlertChannelId,
          _preAlertChannelName,
          description: _preAlertChannelDesc,
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
          enableLights: true,
        ),
      );

      for (final config in _prayerConfigs.values) {
        await android.createNotificationChannel(
          AndroidNotificationChannel(
            config.channelId,
            config.channelName,
            description: config.channelDescription,
            importance: Importance.max,
            playSound: true,
            sound: RawResourceAndroidNotificationSound(config.soundResource),
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
      latitude = lat;
      longitude = lng;
    } else {
      try {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.low,
            timeLimit: Duration(seconds: 10),
          ),
        );
        latitude = pos.latitude;
        longitude = pos.longitude;
        await cacheLastLocation(latitude, longitude);
      } catch (_) {
        dev.log(
          '[BackgroundReschedule] No location available — cannot reschedule',
        );
        return false;
      }
    }

    final prayerTimes = AdhanPrayerService.calculatePrayerTimes(
      latitude: latitude,
      longitude: longitude,
    );

    final today = DateTime.now();

    DateTime toLocalDateTime(DateTime Function(PrayerTimes) getter) {
      final d = getter(prayerTimes).toLocal();
      return DateTime(today.year, today.month, today.day, d.hour, d.minute);
    }

    final prayers = <String, DateTime>{
      'Fajr': toLocalDateTime((p) => p.fajr),
      'Sunrise': toLocalDateTime((p) => p.sunrise),
      'Dhuhr': toLocalDateTime((p) => p.dhuhr),
      'Asr': toLocalDateTime((p) => p.asr),
      'Maghrib': toLocalDateTime((p) => p.maghrib),
      'Isha': toLocalDateTime((p) => p.isha),
    };

    for (int i = 100; i < 106; i++) {
      await plugin.cancel(i);
    }
    for (int i = 200; i < 206; i++) {
      await plugin.cancel(i);
    }

    final now = DateTime.now();
    int id15 = 100;
    int idAt = 200;

    for (final entry in prayers.entries) {
      final name = entry.key;
      final time = entry.value;

      final notifyAt = time.subtract(const Duration(minutes: 15));
      if (!notifyAt.isBefore(now)) {
        await plugin.zonedSchedule(
          id15,
          '🕌 $name (${_arabic(name)}) in 15 minutes',
          'Get ready — $name starts at ${_fmt(time)}.',
          tz.TZDateTime.from(notifyAt, tz.local),
          _preAlertDetails(name),
          androidScheduleMode: AndroidScheduleMode.alarmClock,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'pre_alert:$name',
        );
      }

      if (!time.isBefore(now)) {
        await plugin.zonedSchedule(
          idAt,
          '🕌 $name (${_arabic(name)}) prayer time',
          "It's time for $name prayer — ${_fmt(time)}.",
          tz.TZDateTime.from(time, tz.local),
          _atTimeDetails(name),
          androidScheduleMode: AndroidScheduleMode.alarmClock,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'at_time:$name',
        );
      }

      id15++;
      idAt++;
    }

    dev.log(
      '[BackgroundReschedule] Done — rescheduled ${prayers.length} prayers',
    );
    return true;
  }

  static NotificationDetails _preAlertDetails(String name) =>
      NotificationDetails(
        android: AndroidNotificationDetails(
          _preAlertChannelId,
          _preAlertChannelName,
          channelDescription: _preAlertChannelDesc,
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.reminder,
          visibility: NotificationVisibility.public,
          icon: 'ic_stat_notification',
          largeIcon:
              const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
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

  static NotificationDetails _atTimeDetails(String name) {
    final config = _prayerConfigs[name] ?? _fallbackConfig;

    return NotificationDetails(
      android: AndroidNotificationDetails(
        config.channelId,
        config.channelName,
        channelDescription: config.channelDescription,
        importance: Importance.max,
        priority: Priority.max,
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
        icon: 'ic_stat_notification',
        largeIcon:
            const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        color: const Color(0xFFE9C349),
        colorized: true,
        sound: RawResourceAndroidNotificationSound(config.soundResource),
        styleInformation: BigTextStyleInformation(
          "It's time for $name prayer.",
          contentTitle: '🕌 $name (${_arabic(name)})',
        ),
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: config.soundResource,
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );
  }

  static String _fmt(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}';

  static String _arabic(String name) {
    const map = {
      'Fajr': 'الفجر',
      'Sunrise': 'الشروق',
      'Dhuhr': 'الظهر',
      'Asr': 'العصر',
      'Maghrib': 'المغرب',
      'Isha': 'العشاء',
    };
    return map[name] ?? name;
  }
}
import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Singleton service for local prayer notifications.
///
/// Two channels are used so each can have its own importance/sound:
/// • [_preAlertChannelId] — 15-min warning (Importance.high)
/// • [_atTimeChannelId] — at-prayer reminder (Importance.max)
///
/// Channel IDs are versioned (`_v2`) so that any settings change triggers a
/// brand-new channel — Android freezes channel settings at creation time and
/// ignores later code changes for an existing channel ID.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ── Channels (versioned) ──────────────────────────────────────────────────
  static const _preAlertChannelId = 'prayer_pre_alert_v2';
  static const _preAlertChannelName = 'Prayer Pre-Alert';
  static const _preAlertChannelDesc = 'Notifies 15 minutes before each prayer';

  static const _atTimeChannelId = 'prayer_at_time_v2';
  static const _atTimeChannelName = 'Prayer Time';
  static const _atTimeChannelDesc = 'Notifies at the start of each prayer';

  // ── Notification IDs ──────────────────────────────────────────────────────
  static const _preAlertBaseId = 100; // 100..105
  static const _atTimeBaseId = 200;   // 200..205
  static const _maxPrayers = 6;

  // Legacy channel kept around so we can clean up notifications scheduled
  // against the previous (frozen) channel.
  static const _legacyChannelId = 'prayer_times_channel';

  // ── Public API ────────────────────────────────────────────────────────────

  /// Initialise timezone data, the plugin, channels, and runtime permissions.
  /// Safe to call multiple times — only the first call does the work.
  Future<void> init() async {
    if (_initialized) return;

    // Timezone setup.
    tz.initializeTimeZones();
    try {
      final locationName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(locationName));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onTap,
    );

    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (android != null) {
      // Drop the legacy channel so its frozen low-importance settings don't
      // linger on devices that installed an older build.
      await android.deleteNotificationChannel(_legacyChannelId);

      // Create channels explicitly — never rely on lazy creation.
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
      await android.createNotificationChannel(
        const AndroidNotificationChannel(
          _atTimeChannelId,
          _atTimeChannelName,
          description: _atTimeChannelDesc,
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          enableLights: true,
        ),
      );

      // Runtime permissions — required on Android 13+ and 12+ respectively.
      await android.requestNotificationsPermission();
      await android.requestExactAlarmsPermission();
    }

    _initialized = true;
  }

  /// Cancels all previously scheduled prayer notifications, then schedules:
  /// • a 15-min warning before each upcoming prayer (today)
  /// • a notification at the start of each upcoming prayer (today)
  Future<void> schedulePrayerNotifications(
    Map<String, DateTime> prayers,
  ) async {
    if (!_initialized) {
      debugPrint('[NotificationService] Not initialized — skipping');
      return;
    }

    await _cancelAllPrayerNotifications();

    final now = DateTime.now();
    debugPrint(
      '[NotificationService] tz=${tz.local.name}, now=$now, prayers=$prayers',
    );

    int preId = _preAlertBaseId;
    int atId = _atTimeBaseId;
    int scheduled = 0;

    for (final entry in prayers.entries) {
      final name = entry.key;
      final time = entry.value;

      // 15-min warning.
      final notifyAt = time.subtract(const Duration(minutes: 15));
      if (notifyAt.isAfter(now)) {
        final tzWhen = tz.TZDateTime.from(notifyAt, tz.local);
        debugPrint(
          '[NotificationService] schedule pre-alert "$name" id=$preId at=$tzWhen',
        );
        await _plugin.zonedSchedule(
          preId,
          '🕌 $name (${_arabic(name)}) in 15 minutes',
          'Get ready — $name starts at ${_fmt(time)}.',
          tzWhen,
          _preAlertDetails(name),
          androidScheduleMode: AndroidScheduleMode.alarmClock,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'pre_alert:$name',
        );
        scheduled++;
      }

      // At-prayer-time.
      if (time.isAfter(now)) {
        final tzWhen = tz.TZDateTime.from(time, tz.local);
        debugPrint(
          '[NotificationService] schedule at-time "$name" id=$atId at=$tzWhen',
        );
        await _plugin.zonedSchedule(
          atId,
          '🕌 $name (${_arabic(name)}) prayer time',
          "It's time for $name prayer — ${_fmt(time)}.",
          tzWhen,
          _atTimeDetails(name),
          androidScheduleMode: AndroidScheduleMode.alarmClock,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'at_time:$name',
        );
        scheduled++;
      }

      preId++;
      atId++;
    }

    debugPrint(
      '[NotificationService] Scheduled $scheduled notifications across '
      '${prayers.length} prayers.',
    );
  }

  /// Shows an immediate test notification — useful for verifying that
  /// channel/icon/permission setup actually works on the device.
  Future<void> showTestNotification() async {
    await init();
    await _plugin.show(
      9999,
      '🕌 Test prayer notification',
      'If you see this on your home screen, notifications are working.',
      _atTimeDetails('Test'),
    );
  }

  // ── Notification details ──────────────────────────────────────────────────

  NotificationDetails _preAlertDetails(String prayerName) => NotificationDetails(
        android: AndroidNotificationDetails(
          _preAlertChannelId,
          _preAlertChannelName,
          channelDescription: _preAlertChannelDesc,
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.reminder,
          visibility: NotificationVisibility.public,
          icon: 'ic_stat_notification',
          largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          color: const Color(0xFF84D5C5), // AppColor.primaryColor1
          colorized: true,
          styleInformation: BigTextStyleInformation(
            'Get ready — $prayerName prayer is in 15 minutes.',
            contentTitle: '🕌 $prayerName (${_arabic(prayerName)}) in 15 min',
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      );

  NotificationDetails _atTimeDetails(String prayerName) => NotificationDetails(
        android: AndroidNotificationDetails(
          _atTimeChannelId,
          _atTimeChannelName,
          channelDescription: _atTimeChannelDesc,
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.reminder,
          visibility: NotificationVisibility.public,
          icon: 'ic_stat_notification',
          largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          color: const Color(0xFFE9C349), // AppColor.secondaryColor (gold)
          colorized: true,
          styleInformation: BigTextStyleInformation(
            "It's time for $prayerName prayer.",
            contentTitle: '🕌 $prayerName (${_arabic(prayerName)})',
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      );

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<void> _cancelAllPrayerNotifications() async {
    for (int i = _preAlertBaseId; i < _preAlertBaseId + _maxPrayers; i++) {
      await _plugin.cancel(i);
    }
    for (int i = _atTimeBaseId; i < _atTimeBaseId + _maxPrayers; i++) {
      await _plugin.cancel(i);
    }
  }

  static void _onTap(NotificationResponse response) {
    // Tapping the notification launches the app via the default activity.
    // Hook into routing here once a deep-link target is decided.
    debugPrint('[NotificationService] Tapped: ${response.payload}');
  }

  String _fmt(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}';

  String _arabic(String name) {
    const map = {
      'Fajr': 'الفجر',
      'Sunrise': 'الشروق',
      'Dhuhr': 'الظهر',
      'Asr': 'العصر',
      'Maghrib': 'المغرب',
      'Isha': 'العشاء',
      'Test': 'اختبار',
    };
    return map[name] ?? name;
  }
}

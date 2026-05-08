import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'prayer_notification_config.dart';

/// Singleton service for scheduling local prayer notifications.
///
/// Each prayer has two Android channels (call-only / call+azan merged).
/// [schedulePrayerNotifications] picks the right channel based on [azanEnabled],
/// so a single call is all callers need — no separate azan scheduling.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // Cached path of the notification logo written to the temp dir on iOS.
  // Null until init() completes or if caching fails (notifications still fire).
  String? _iosImagePath;

  // ── Public API ────────────────────────────────────────────────────────────

  /// Initialises timezone data, the plugin, all channels, and runtime
  /// permissions. Safe to call multiple times — only the first call acts.
  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('notification_logo'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
      ),
      onDidReceiveNotificationResponse: _onTap,
    );

    final android = _plugin.resolvePlatformSpecificImplementation<
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

      await android.requestNotificationsPermission();
      await android.requestExactAlarmsPermission();
    }

    if (Platform.isIOS) await _cacheIosImage();

    _initialized = true;
  }

  /// Copies the notification logo from Flutter assets into the system temp
  /// directory so iOS can attach it to delivered notifications.
  /// Uses [Directory.systemTemp] — no extra packages required.
  Future<void> _cacheIosImage() async {
    try {
      final file = File('${Directory.systemTemp.path}/notification_logo.png');
      if (!file.existsSync()) {
        final data = await rootBundle.load('assets/notification-logo.png');
        await file.writeAsBytes(data.buffer.asUint8List());
      }
      _iosImagePath = file.path;
    } catch (_) {
      _iosImagePath = null; // notifications still fire without the image
    }
  }

  /// Cancels all existing prayer notifications, then schedules:
  /// - a 15-min pre-alert for each upcoming prayer (default system sound)
  /// - an at-time notification for each upcoming prayer using either the
  ///   call-only or the merged call+azan audio file, based on [azanEnabled]
  Future<void> schedulePrayerNotifications(
    Map<String, DateTime> prayers, {
    required bool azanEnabled,
  }) async {
    if (!_initialized) {
      debugPrint('[NotificationService] Not initialized — skipping');
      return;
    }

    await _cancelAll();

    final now = DateTime.now();
    int preId = kPreAlertBaseId;
    int atId  = kAtTimeBaseId;
    int scheduled = 0;

    for (final entry in prayers.entries) {
      final name = entry.key;
      final time = entry.value;

      if (kDebugMode) {
        debugPrint(
          '[NotificationService] $name naiveInput=$time → '
          'tzLocal=${tz.TZDateTime.from(time, tz.local)}',
        );
      }

      final preTime = time.subtract(const Duration(minutes: 15));
      if (preTime.isAfter(now)) {
        await _plugin.zonedSchedule(
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
        scheduled++;
      }

      if (time.isAfter(now)) {
        await _plugin.zonedSchedule(
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
        scheduled++;
      }

      preId++;
      atId++;
    }

    debugPrint(
      '[NotificationService] Scheduled $scheduled notifications '
      '(azan=${azanEnabled ? "on" : "off"})',
    );
  }

  /// Shows an immediate test notification.
  /// Uses the call-only or merged channel based on [azanEnabled] so the
  /// correct audio plays — identical to a real prayer notification.
  Future<void> showTestNotification({required bool azanEnabled}) async {
    await init();
    await _plugin.show(
      9999,
      '🕌 Test — ${azanEnabled ? "Call + Azan" : "Call only"}',
      azanEnabled
          ? 'Merged call + azan audio should play now.'
          : 'Prayer call audio should play now.',
      _atTimeDetails('Fajr', azanEnabled: azanEnabled),
    );
  }

  // ── Notification details ──────────────────────────────────────────────────

  NotificationDetails _preAlertDetails(String name) => NotificationDetails(
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
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.timeSensitive,
          attachments: _iosImagePath != null
              ? [DarwinNotificationAttachment(_iosImagePath!)]
              : null,
        ),
      );

  NotificationDetails _atTimeDetails(
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
        attachments: _iosImagePath != null
            ? [DarwinNotificationAttachment(_iosImagePath!)]
            : null,
      ),
    );
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<void> _cancelAll() async {
    for (int i = kPreAlertBaseId; i < kPreAlertBaseId + kMaxPrayers; i++) {
      await _plugin.cancel(i);
    }
    for (int i = kAtTimeBaseId; i < kAtTimeBaseId + kMaxPrayers; i++) {
      await _plugin.cancel(i);
    }
    // Cancel old azan IDs (300–305) from the previous two-step architecture.
    for (int i = 300; i < 306; i++) {
      await _plugin.cancel(i);
    }
  }

  static void _onTap(NotificationResponse response) {
    debugPrint('[NotificationService] Tapped: ${response.payload}');
  }

  String _fmt(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}';

  String _arabic(String name) => kArabicNames[name] ?? name;
}

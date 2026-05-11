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
///
/// Notifications are scheduled using [ianaTimezone] (the prayer location's
/// timezone) so they fire at the correct wall-clock time regardless of the
/// device's timezone setting.
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

    await _initTimezone();

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
      // Exact alarm permission is checked separately via canScheduleExactAlarms()
      // and surfaced to the user from the home screen with an explanation dialog,
      // rather than silently opening settings at startup.
    }

    if (Platform.isIOS) await _cacheIosImage();

    _initialized = true;
  }

  /// Copies the notification logo from Flutter assets into the system temp
  /// directory so iOS can attach it to delivered notifications.
  Future<void> _cacheIosImage() async {
    try {
      final file = File('${Directory.systemTemp.path}/notification_logo.png');
      if (!file.existsSync()) {
        final data = await rootBundle.load('assets/notification-logo.png');
        await file.writeAsBytes(data.buffer.asUint8List());
      }
      _iosImagePath = file.path;
    } catch (_) {
      _iosImagePath = null;
    }
  }

  /// Cancels all existing prayer notifications, then schedules:
  /// - a 15-min pre-alert for each upcoming prayer (default system sound)
  /// - an at-time notification for each upcoming prayer using either the
  ///   call-only or the merged call+azan audio file, based on [azanEnabled]
  ///
  /// [prayerDays] — ordered list of day maps (index 0 = today, 1 = tomorrow …).
  /// Each map: prayer name → scheduled TZDateTime in the prayer location's timezone.
  /// Supports up to [kDaysToSchedule] days.
  ///
  /// [ianaTimezone] — the IANA timezone name for the prayer location (e.g.
  /// 'Asia/Riyadh'). Used to resolve [tz.Location] for scheduling. The DateTime
  /// values in [prayerDays] should already be TZDateTime instances in this
  /// timezone. Falls back to [tz.local] if not provided (device timezone).
  Future<void> schedulePrayerNotifications(
    List<Map<String, DateTime>> prayerDays, {
    required bool azanEnabled,
    String? ianaTimezone,
  }) async {
    if (!_initialized) {
      debugPrint('[NotificationService] Not initialized — skipping');
      return;
    }

    await _cancelAll();

    // Resolve the prayer location's timezone for TZDateTime scheduling.
    // Callers that build TZDateTime values (like HomeCubit) already pass
    // location-aware DateTimes, so this mainly ensures consistent resolution
    // for any raw DateTime values that slip through.
    tz.Location location = tz.local;
    if (ianaTimezone != null) {
      try {
        location = tz.getLocation(ianaTimezone);
      } catch (_) {
        // Keep the fallback to tz.local
      }
    }

    final now = DateTime.now();
    int scheduled = 0;

    for (int dayIndex = 0; dayIndex < prayerDays.length; dayIndex++) {
      final prayers = prayerDays[dayIndex];
      int preId = kPreAlertBaseId + (dayIndex * kMaxPrayers);
      int atId  = kAtTimeBaseId  + (dayIndex * kMaxPrayers);

      for (final entry in prayers.entries) {
        final name = entry.key;
        final time = entry.value;

        // Ensure we have a proper TZDateTime for scheduling.
        // If the caller already provided a TZDateTime in the correct location,
        // TZDateTime.from is a no-op (same location). If it's a raw DateTime,
        // this converts it to the prayer location's timezone.
        final tzTime = time is tz.TZDateTime
            ? time
            : tz.TZDateTime.from(time, location);

        final preTime = tzTime.subtract(const Duration(minutes: 15));
        if (preTime.isAfter(now)) {
          await _plugin.zonedSchedule(
            preId,
            '🕌 $name (${_arabic(name)}) in 15 minutes',
            'Get ready — $name starts at ${_fmt(tzTime)}.',
            tz.TZDateTime.from(preTime, location),
            _preAlertDetails(name),
            androidScheduleMode: AndroidScheduleMode.alarmClock,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            payload: 'pre_alert:$name',
          );
          scheduled++;
        }

        if (tzTime.isAfter(now)) {
          await _plugin.zonedSchedule(
            atId,
            '🕌 $name (${_arabic(name)}) prayer time',
            "It's time for $name prayer — ${_fmt(tzTime)}.",
            tz.TZDateTime.from(tzTime, location),
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
    }

    debugPrint(
      '[NotificationService] Scheduled $scheduled notifications '
      '(azan=${azanEnabled ? "on" : "off"}, days=${prayerDays.length}, '
      'tz=$ianaTimezone)',
    );
  }

  /// Returns true if the app can schedule exact alarms (AlarmClock-mode).
  /// On Android < 12 always returns true. On 12+ requires user to grant
  /// SCHEDULE_EXACT_ALARM from system settings.
  Future<bool> canScheduleExactAlarms() async {
    if (!Platform.isAndroid) return true;
    try {
      const ch = MethodChannel('com.example.mosques_app/system');
      return await ch.invokeMethod<bool>('canScheduleExactAlarms') ?? true;
    } catch (_) {
      return true;
    }
  }

  /// Opens the system "Alarms & reminders" settings page where the user can
  /// grant SCHEDULE_EXACT_ALARM to this app.
  Future<void> openExactAlarmSettings() async {
    if (!Platform.isAndroid) return;
    await init();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestExactAlarmsPermission();
  }

  /// Shows an immediate test notification.
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

  // ── Timezone initialisation ───────────────────────────────────────────────

  /// Initialises the timezone package database and sets [tz.local].
  ///
  /// Strategy (each step is tried only if the previous one fails):
  /// 1. flutter_timezone IANA name  — accurate, DST-aware
  /// 2. UTC-offset-based IANA name  — covers the common plugin-failure case
  /// 3. UTC                         — last resort; notifications fire but at
  ///                                  wrong local time until next app open
  static Future<void> _initTimezone() async {
    tz.initializeTimeZones();

    // 1 — preferred: IANA name from flutter_timezone
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
      return;
    } catch (e) {
      debugPrint('[NotificationService] FlutterTimezone failed ($e) — trying offset fallback');
    }

    // 2 — fallback: derive a representative IANA name from the device's UTC offset
    try {
      final offset = DateTime.now().timeZoneOffset;
      final name = _ianaFromOffset(offset);
      tz.setLocalLocation(tz.getLocation(name));
      debugPrint('[NotificationService] Timezone fallback: $name (offset ${offset.inMinutes} min)');
      return;
    } catch (_) {}

    // 3 — last resort
    debugPrint('[NotificationService] WARNING: using UTC — notifications may fire at wrong local time');
    tz.setLocalLocation(tz.UTC);
  }

  /// Returns a representative IANA timezone name for the given UTC [offset].
  static String _ianaFromOffset(Duration offset) {
    const table = <int, String>{
      -720: 'Etc/GMT+12',
      -660: 'Pacific/Pago_Pago',
      -600: 'Pacific/Honolulu',
      -570: 'Pacific/Marquesas',
      -540: 'America/Anchorage',
      -480: 'America/Los_Angeles',
      -420: 'America/Denver',
      -360: 'America/Chicago',
      -300: 'America/New_York',
      -240: 'America/Halifax',
      -210: 'America/St_Johns',
      -180: 'America/Sao_Paulo',
      -120: 'Atlantic/South_Georgia',
      -60:  'Atlantic/Azores',
          0: 'Europe/London',
         60: 'Europe/Paris',
        120: 'Africa/Cairo',
        180: 'Asia/Riyadh',
        210: 'Asia/Tehran',
        240: 'Asia/Dubai',
        270: 'Asia/Kabul',
        300: 'Asia/Karachi',
        330: 'Asia/Kolkata',
        345: 'Asia/Kathmandu',
        360: 'Asia/Dhaka',
        390: 'Asia/Yangon',
        420: 'Asia/Bangkok',
        480: 'Asia/Shanghai',
        525: 'Australia/Eucla',
        540: 'Asia/Tokyo',
        570: 'Australia/Darwin',
        600: 'Australia/Sydney',
        630: 'Australia/Lord_Howe',
        660: 'Pacific/Noumea',
        720: 'Pacific/Auckland',
        765: 'Pacific/Chatham',
        780: 'Pacific/Apia',
        840: 'Pacific/Kiritimati',
    };

    final minutes = offset.inMinutes;
    if (table.containsKey(minutes)) return table[minutes]!;

    // Pick nearest entry by absolute distance
    final nearest = table.keys.reduce(
      (a, b) => (a - minutes).abs() <= (b - minutes).abs() ? a : b,
    );
    return table[nearest]!;
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<void> _cancelAll() => Future.wait([
    for (int i = kPreAlertBaseId; i < kPreAlertBaseId + kMaxPrayers * kDaysToSchedule; i++)
      _plugin.cancel(i),
    for (int i = kAtTimeBaseId; i < kAtTimeBaseId + kMaxPrayers * kDaysToSchedule; i++)
      _plugin.cancel(i),
    // Cancel old azan IDs (300–305) from the previous two-step architecture.
    for (int i = 300; i < 306; i++)
      _plugin.cancel(i),
  ]);

  static void _onTap(NotificationResponse response) {
    debugPrint('[NotificationService] Tapped: ${response.payload}');
  }

  String _fmt(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}';

  String _arabic(String name) => kArabicNames[name] ?? name;
}
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Singleton service for local push notifications.
///
/// Usage:
/// 1. Call [init] once from main().
/// 2. After prayer times load, call [scheduleNextPrayerNotification].
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ── Android notification channel ──────────────────────────────────────────
  static const _channelId = 'prayer_times_channel';
  static const _channelName = 'Prayer Times';
  static const _channelDesc =
      'Notifies 15 minutes before the next prayer time';

  // ── Fixed notification ID for the single "next prayer" alert ─────────────
  static const _prayerNotificationId = 100;

  // ── Public API ────────────────────────────────────────────────────────────

  /// Initialise timezone data and the notifications plugin.
  /// Must be called once before any scheduling.
  Future<void> init() async {
    if (_initialized) return;

    // ── Timezone setup ────────────────────────────────────────────────────
    tz.initializeTimeZones();
    try {
      final String locationName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(locationName));
    } catch (_) {
      // Fall back to UTC if timezone lookup fails (e.g. in unit tests).
      tz.setLocalLocation(tz.UTC);
    }

    // ── Plugin init ────────────────────────────────────────────────────────
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
    );

    // Request POST_NOTIFICATIONS permission on Android 13+.
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  /// Finds the **next** upcoming prayer from [prayers], and schedules a single
  /// notification exactly 15 minutes before it.
  ///
  /// Any previously scheduled prayer notification is cancelled first.
  ///
  /// [prayers] maps prayer name (e.g. "Fajr") → local [DateTime] for today.
  Future<void> scheduleNextPrayerNotification(
    Map<String, DateTime> prayers,
  ) async {
    if (!_initialized) {
      debugPrint('[NotificationService] Not initialized — skipping scheduling');
      return;
    }

    // Always cancel the old notification first.
    await _plugin.cancel(_prayerNotificationId);

    final now = DateTime.now();

    // ── Find the nearest future prayer ──────────────────────────────────
    String? nextPrayerName;
    DateTime? nextPrayerTime;

    for (final entry in prayers.entries) {
      if (entry.value.isAfter(now)) {
        if (nextPrayerTime == null || entry.value.isBefore(nextPrayerTime)) {
          nextPrayerName = entry.key;
          nextPrayerTime = entry.value;
        }
      }
    }

    // All prayers for today are in the past — nothing to schedule.
    if (nextPrayerName == null || nextPrayerTime == null) {
      debugPrint(
        '[NotificationService] All prayers already passed — no notification scheduled',
      );
      return;
    }

    // Notification fires 15 minutes before the prayer.
    final notifyAt = nextPrayerTime.subtract(const Duration(minutes: 15));

    // If the 15-min window is already past, skip scheduling.
    if (notifyAt.isBefore(now)) {
      debugPrint(
        '[NotificationService] 15-min window for $nextPrayerName already passed',
      );
      return;
    }

    // ── Convert to TZDateTime ──────────────────────────────────────────
    final tzNotifyAt = tz.TZDateTime(
      tz.local,
      notifyAt.year,
      notifyAt.month,
      notifyAt.day,
      notifyAt.hour,
      notifyAt.minute,
      notifyAt.second,
    );

    await _plugin.zonedSchedule(
      _prayerNotificationId,
      '🕌 $nextPrayerName prayer in 15 minutes',
      'Get ready — $nextPrayerName starts at ${_fmt(nextPrayerTime)}.',
      tzNotifyAt,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    debugPrint(
      '[NotificationService] ✅ Scheduled "$nextPrayerName" alert at $tzNotifyAt',
    );
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Format DateTime as HH:mm for notification body text.
  String _fmt(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}';
}

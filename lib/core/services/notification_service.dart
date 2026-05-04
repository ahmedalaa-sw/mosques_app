import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Singleton service for local push notifications.
///
/// Usage:
/// 1. Call [init] once from main().
/// 2. After prayer times load, call [schedulePrayerNotifications].
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
      'Notifies 15 minutes before each prayer time';

  // ── Notification IDs: 100 = Fajr, 101 = Sunrise, … 105 = Isha ───────────
  static const _baseId = 100;
  static const _atPrayerBaseId = 200;
  static const _maxPrayers = 6;

  // ── Public API ────────────────────────────────────────────────────────────

  /// Shows an immediate test notification to verify push notifications work.
  Future<void> showTestNotification() async {
    await init();
    await _plugin.show(
      9999,
      '🕌 Test Notification',
      'Prayer notifications are working correctly!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

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

  /// Cancels all previous prayer notifications, then schedules a notification
  /// **15 minutes before every remaining prayer** for today.
  ///
  /// [prayers] maps prayer name (e.g. "Fajr") → local [DateTime] for today.
  Future<void> schedulePrayerNotifications(
    Map<String, DateTime> prayers,
  ) async {
    if (!_initialized) {
      debugPrint('[NotificationService] Not initialized — skipping');
      return;
    }

    // Cancel all previously scheduled prayer notifications.
    for (int i = _baseId; i < _baseId + _maxPrayers; i++) {
      await _plugin.cancel(i);
    }
    for (int i = _atPrayerBaseId; i < _atPrayerBaseId + _maxPrayers; i++) {
      await _plugin.cancel(i);
    }

    final now = DateTime.now();
    int id = _baseId;
    int scheduled = 0;

    for (final entry in prayers.entries) {
      final prayerName = entry.key;
      final prayerTime = entry.value;

      // Notification should fire 15 minutes before the prayer.
      final notifyAt = prayerTime.subtract(const Duration(minutes: 15));

      // Skip if the 15-min mark has already passed.
      if (notifyAt.isBefore(now)) {
        id++;
        continue;
      }

      // Convert to TZDateTime for zonedSchedule.
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
        id,
        '🕌 $prayerName prayer in 15 minutes',
        'Get ready — $prayerName starts at ${_fmt(prayerTime)}.',
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
        '[NotificationService] ✅ Scheduled "$prayerName" alert at $tzNotifyAt (id: $id)',
      );

      scheduled++;
      id++;
    }

    // ── At-prayer-time notifications (IDs 200–205) ───────────────────────
    int atPrayerId = _atPrayerBaseId;
    for (final entry in prayers.entries) {
      final prayerName = entry.key;
      final prayerTime = entry.value;

      if (prayerTime.isBefore(now)) {
        atPrayerId++;
        continue;
      }

      final tzPrayerAt = tz.TZDateTime(
        tz.local,
        prayerTime.year,
        prayerTime.month,
        prayerTime.day,
        prayerTime.hour,
        prayerTime.minute,
        prayerTime.second,
      );

      await _plugin.zonedSchedule(
        atPrayerId,
        '🕌 $prayerName prayer time now',
        'It\'s time for $prayerName prayer.',
        tzPrayerAt,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDesc,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
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
        '[NotificationService] ✅ Scheduled "$prayerName" at-prayer alert at $tzPrayerAt (id: $atPrayerId)',
      );

      atPrayerId++;
    }

    debugPrint(
      '[NotificationService] Total scheduled: $scheduled / ${prayers.length}',
    );
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Format DateTime as HH:mm for notification body text.
  String _fmt(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}';
}

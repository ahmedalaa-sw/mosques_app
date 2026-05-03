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

  // ── Android channel constants ─────────────────────────────────────────────
  static const _channelId = 'prayer_times_channel';
  static const _channelName = 'Prayer Times';
  static const _channelDesc =
      'Notifies 15 minutes before each upcoming prayer';

  // ── Notification ID range reserved for prayer alerts ─────────────────────
  // IDs 100–105 map to: Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha
  static const _baseId = 100;

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

  /// Cancels all existing prayer alerts and schedules fresh 15-min-before
  /// notifications for every prayer that is still in the future today.
  ///
  /// [prayers] maps prayer name (e.g. "Fajr") → local [DateTime] for today.
  Future<void> schedulePrayerNotifications(
    Map<String, DateTime> prayers,
  ) async {
    if (!_initialized) {
      debugPrint('[NotificationService] Not initialized — skipping scheduling');
      return;
    }

    // Cancel previously scheduled prayer notifications.
    for (int i = _baseId; i < _baseId + prayers.length + 1; i++) {
      await _plugin.cancel(i);
    }

    final now = tz.TZDateTime.now(tz.local);
    int id = _baseId;

    for (final entry in prayers.entries) {
      final prayerName = entry.key;
      final prayerTime = entry.value;

      // Convert plain DateTime to TZDateTime in device's local timezone.
      final tzPrayerTime = tz.TZDateTime.local(
        prayerTime.year,
        prayerTime.month,
        prayerTime.day,
        prayerTime.hour,
        prayerTime.minute,
      );

      // Notification fires 15 minutes before the prayer.
      final notifyAt = tzPrayerTime.subtract(const Duration(minutes: 15));

      // Skip if the notification window is already past.
      if (notifyAt.isBefore(now)) {
        id++;
        continue;
      }

      await _plugin.zonedSchedule(
        id,
        '🕌 $prayerName in 15 minutes',
        'Get ready — $prayerName starts at ${_fmt(prayerTime)}.',
        notifyAt,
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
      );

      debugPrint(
        '[NotificationService] Scheduled "$prayerName" alert at $notifyAt (id: $id)',
      );

      id++;
    }
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Format DateTime as HH:mm for notification body text.
  String _fmt(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}';
}

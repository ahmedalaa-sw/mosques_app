import 'dart:developer' as dev;
import 'dart:ui' show Color;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';

import 'adhan_prayer_service.dart';
import 'prayer_notification_config.dart';
import '../utils/location_utils.dart';
import '../utils/timezone_resolver.dart';

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

  static const prefsLat      = 'last_known_lat';
  static const prefsLng      = 'last_known_lng';
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
    await prefs.setDouble(prefsLat, lat);
    await prefs.setDouble(prefsLng, lng);
  }

  // ── Core background work ──────────────────────────────────────────────────

  static Future<bool> _rescheduleAll() async {
    await _initTimezone();

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

    final prefs = await SharedPreferences.getInstance();

    // createNotificationChannel is idempotent on Android — recreating an
    // existing channel with the same ID is a no-op. We always run this so
    // channels deleted from system settings are transparently restored.
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
    final lat = prefs.getDouble(prefsLat);
    final lng = prefs.getDouble(prefsLng);

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

    // Use cached country code so no geocoding network call is needed here.
    final countryCode = prefs.getString(LocationUtils.countryCodePrefsKey) ?? 'US';
    // Use cached timezone — falls back to country-based resolution if not cached.
    final ianaTimezone = prefs.getString(TimezoneResolver.ianaTimezonePrefsKey) ??
        TimezoneResolver.fromCountryCode(countryCode);
    final azanEnabled = prefs.getBool(_prefsAzanKey) ?? false;

    // Build prayer maps for today and tomorrow using the sync (no-network) method.
    // Use the prayer location's timezone for date calculation, NOT DateTime.now().
    final location = tz.getLocation(ianaTimezone);
    final todayCalcDate = TimezoneResolver.todayAt(ianaTimezone);
    final tomorrowCalcDate = todayCalcDate.add(const Duration(days: 1));

    Map<String, tz.TZDateTime> buildDayMap(DateTime calcDate) {
      final result = AdhanPrayerService.calculatePrayerTimesSync(
        latitude: latitude,
        longitude: longitude,
        countryCode: countryCode,
        ianaTimezone: ianaTimezone,
        date: calcDate,
      );
      // Convert UTC DateTimes from adhan_dart to wall-clock times at the
      // prayer location's timezone, then construct TZDateTime for scheduling.
      String fmt(DateTime? utc) => TimezoneResolver.formatHhMm(utc, ianaTimezone);
      tz.TZDateTime toScheduleDateTime(String hhmm) {
        final parts = hhmm.split(':');
        final h = int.tryParse(parts[0]) ?? 0;
        final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
        // Use the calculation date's year/month/day in the location timezone
        final localNow = tz.TZDateTime.now(location);
        return tz.TZDateTime(location, localNow.year, localNow.month, localNow.day, h, m);
      }
      // Re-format the raw prayer times into the location's timezone
      final fajrStr    = fmt(result.prayerTimes.fajr);
      final sunriseStr = fmt(result.prayerTimes.sunrise);
      final dhuhrStr   = fmt(result.prayerTimes.dhuhr);
      final asrStr     = fmt(result.prayerTimes.asr);
      final maghribStr = fmt(result.prayerTimes.maghrib);
      final ishaStr    = fmt(result.prayerTimes.isha);

      return {
        'Fajr'   : toScheduleDateTime(fajrStr),
        'Sunrise': toScheduleDateTime(sunriseStr),
        'Dhuhr'  : toScheduleDateTime(dhuhrStr),
        'Asr'    : toScheduleDateTime(asrStr),
        'Maghrib': toScheduleDateTime(maghribStr),
        'Isha'   : toScheduleDateTime(ishaStr),
      };
    }

    final todayMap = buildDayMap(todayCalcDate);
    // For tomorrow, shift the TZDateTime day forward by 1
    final tomorrowLocal = tz.TZDateTime.now(location).add(const Duration(days: 1));
    Map<String, tz.TZDateTime> buildTomorrowMap() {
      final result = AdhanPrayerService.calculatePrayerTimesSync(
        latitude: latitude,
        longitude: longitude,
        countryCode: countryCode,
        ianaTimezone: ianaTimezone,
        date: tomorrowCalcDate,
      );
      String fmt(DateTime? utc) => TimezoneResolver.formatHhMm(utc, ianaTimezone);
      tz.TZDateTime toScheduleDateTime(String hhmm) {
        final parts = hhmm.split(':');
        final h = int.tryParse(parts[0]) ?? 0;
        final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
        return tz.TZDateTime(location, tomorrowLocal.year, tomorrowLocal.month, tomorrowLocal.day, h, m);
      }
      return {
        'Fajr'   : toScheduleDateTime(fmt(result.prayerTimes.fajr)),
        'Sunrise': toScheduleDateTime(fmt(result.prayerTimes.sunrise)),
        'Dhuhr'  : toScheduleDateTime(fmt(result.prayerTimes.dhuhr)),
        'Asr'    : toScheduleDateTime(fmt(result.prayerTimes.asr)),
        'Maghrib': toScheduleDateTime(fmt(result.prayerTimes.maghrib)),
        'Isha'   : toScheduleDateTime(fmt(result.prayerTimes.isha)),
      };
    }

    final prayerDays = [
      todayMap,
      buildTomorrowMap(),
    ];

    // Cancel all existing notifications concurrently instead of sequentially.
    await Future.wait([
      for (int i = kPreAlertBaseId; i < kPreAlertBaseId + kMaxPrayers * kDaysToSchedule; i++)
        plugin.cancel(i),
      for (int i = kAtTimeBaseId; i < kAtTimeBaseId + kMaxPrayers * kDaysToSchedule; i++)
        plugin.cancel(i),
      for (int i = 300; i < 306; i++)
        plugin.cancel(i),
    ]);

    final now = DateTime.now();
    int scheduled = 0;

    for (int dayIndex = 0; dayIndex < prayerDays.length; dayIndex++) {
      final prayers = prayerDays[dayIndex];
      int preId = kPreAlertBaseId + (dayIndex * kMaxPrayers);
      int atId  = kAtTimeBaseId  + (dayIndex * kMaxPrayers);

      for (final entry in prayers.entries) {
        final name = entry.key;
        final time = entry.value;

        final preTime = time.subtract(const Duration(minutes: 15));
        if (!preTime.isBefore(now)) {
          await plugin.zonedSchedule(
            preId,
            '🕌 $name (${_arabic(name)}) in 15 minutes',
            'Get ready — $name starts at ${_fmt(time)}.',
            preTime,
            _preAlertDetails(name),
            androidScheduleMode: AndroidScheduleMode.alarmClock,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            payload: 'pre_alert:$name',
          );
          scheduled++;
        }

        if (!time.isBefore(now)) {
          await plugin.zonedSchedule(
            atId,
            '🕌 $name (${_arabic(name)}) prayer time',
            "It's time for $name prayer — ${_fmt(time)}.",
            time,
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

    dev.log(
      '[BackgroundReschedule] Done — $scheduled notifications, '
      'azan=${azanEnabled ? "on" : "off"}, days=${prayerDays.length}, '
      'tz=$ianaTimezone',
    );
    return true;
  }

  // ── Timezone initialisation ───────────────────────────────────────────────

  static Future<void> _initTimezone() async {
    tz.initializeTimeZones();

    // 1 — preferred
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
      return;
    } catch (e) {
      dev.log('[BackgroundReschedule] FlutterTimezone failed: $e');
    }

    // 2 — UTC-offset fallback
    try {
      final offset = DateTime.now().timeZoneOffset;
      final name   = _ianaFromOffset(offset);
      tz.setLocalLocation(tz.getLocation(name));
      dev.log('[BackgroundReschedule] Timezone fallback: $name');
      return;
    } catch (_) {}

    // 3 — last resort
    dev.log('[BackgroundReschedule] WARNING: using UTC');
    tz.setLocalLocation(tz.UTC);
  }

  static String _ianaFromOffset(Duration offset) {
    const table = <int, String>{
      -720: 'Etc/GMT+12',       -660: 'Pacific/Pago_Pago',
      -600: 'Pacific/Honolulu', -570: 'Pacific/Marquesas',
      -540: 'America/Anchorage',-480: 'America/Los_Angeles',
      -420: 'America/Denver',   -360: 'America/Chicago',
      -300: 'America/New_York', -240: 'America/Halifax',
      -210: 'America/St_Johns', -180: 'America/Sao_Paulo',
      -120: 'Atlantic/South_Georgia', -60: 'Atlantic/Azores',
          0: 'Europe/London',       60: 'Europe/Paris',
        120: 'Africa/Cairo',       180: 'Asia/Riyadh',
        210: 'Asia/Tehran',        240: 'Asia/Dubai',
        270: 'Asia/Kabul',         300: 'Asia/Karachi',
        330: 'Asia/Kolkata',       345: 'Asia/Kathmandu',
        360: 'Asia/Dhaka',         390: 'Asia/Yangon',
        420: 'Asia/Bangkok',       480: 'Asia/Shanghai',
        525: 'Australia/Eucla',    540: 'Asia/Tokyo',
        570: 'Australia/Darwin',   600: 'Australia/Sydney',
        630: 'Australia/Lord_Howe',660: 'Pacific/Noumea',
        720: 'Pacific/Auckland',   765: 'Pacific/Chatham',
        780: 'Pacific/Apia',       840: 'Pacific/Kiritimati',
    };
    final minutes = offset.inMinutes;
    if (table.containsKey(minutes)) return table[minutes]!;
    final nearest = table.keys.reduce(
      (a, b) => (a - minutes).abs() <= (b - minutes).abs() ? a : b,
    );
    return table[nearest]!;
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
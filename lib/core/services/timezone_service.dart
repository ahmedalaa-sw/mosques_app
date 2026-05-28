import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Centralized timezone initialization service.
///
/// Ensures the timezone database is initialized exactly once across the app,
/// and resolves the device's real IANA timezone name via [FlutterTimezone].
///
/// **Call [ensureInitialized] early in main() before any code that depends
/// on [tz.getLocation] or [tz.local].**
class TimezoneService {
  TimezoneService._();

  static bool _initialized = false;

  /// The device's real IANA timezone name (e.g. 'Africa/Cairo').
  /// Available after [ensureInitialized] completes.
  static String _deviceTimezone = 'UTC';

  /// Whether the timezone database has been initialized.
  static bool get isInitialized => _initialized;

  /// The device's real IANA timezone name detected via [FlutterTimezone].
  /// Falls back to UTC-offset-based guessing if the plugin fails.
  static String get deviceTimezone => _deviceTimezone;

  /// Initializes the timezone database and detects the device's real IANA
  /// timezone. Safe to call multiple times — only the first call acts.
  ///
  /// Strategy (each step tried only if the previous one fails):
  /// 1. flutter_timezone IANA name — accurate, DST-aware
  /// 2. UTC-offset-based IANA name — covers common plugin-failure cases
  /// 3. UTC — last resort
  static Future<void> ensureInitialized() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    // 1 — preferred: IANA name from flutter_timezone
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
      _deviceTimezone = name;
      _initialized = true;
      if (kDebugMode) {
        debugPrint('[TimezoneService] Initialized with device tz: $name');
      }
      return;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[TimezoneService] FlutterTimezone failed ($e) — trying offset',
        );
      }
    }

    // 2 — fallback: derive IANA name from the device's UTC offset
    try {
      final offset = DateTime.now().timeZoneOffset;
      final name = _ianaFromOffset(offset);
      tz.setLocalLocation(tz.getLocation(name));
      _deviceTimezone = name;
      _initialized = true;
      if (kDebugMode) {
        debugPrint(
          '[TimezoneService] Fallback tz: $name '
          '(offset ${offset.inMinutes} min)',
        );
      }
      return;
    } catch (_) {}

    // 3 — last resort
    if (kDebugMode) {
      debugPrint('[TimezoneService] WARNING: using UTC');
    }
    tz.setLocalLocation(tz.UTC);
    _deviceTimezone = 'UTC';
    _initialized = true;
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
      -60: 'Atlantic/Azores',
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

    final nearest = table.keys.reduce(
      (a, b) => (a - minutes).abs() <= (b - minutes).abs() ? a : b,
    );
    return table[nearest]!;
  }
}

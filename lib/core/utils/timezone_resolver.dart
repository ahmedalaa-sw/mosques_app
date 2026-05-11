import 'package:timezone/timezone.dart' as tz;

/// Resolves IANA timezone names for prayer locations and converts
/// adhan_dart UTC DateTimes to the location's local wall-clock time.
///
/// Saudi Arabia, Kuwait, Qatar, Bahrain, and the UAE use a single
/// timezone each, so country-level resolution is deterministic for
/// the most common Muslim-majority countries. For multi-zone countries
/// (US, Canada, India, Indonesia), the default major timezone is
/// returned — callers should prefer coordinate-based resolution when
/// accuracy matters.
class TimezoneResolver {
  TimezoneResolver._();

  static const ianaTimezonePrefsKey = 'cached_iana_timezone';

  /// Maps ISO-3166-1 alpha-2 country codes to their primary IANA timezone.
  /// Covers every country used by [PrayerMethodMapper] plus common
  /// Muslim-majority countries.
  static const _countryToTimezone = <String, String>{
    'SA': 'Asia/Riyadh',
    'KW': 'Asia/Kuwait',
    'AE': 'Asia/Dubai',
    'QA': 'Asia/Qatar',
    'BH': 'Asia/Bahrain',
    'EG': 'Africa/Cairo',
    'PK': 'Asia/Karachi',
    'IN': 'Asia/Kolkata',
    'BD': 'Asia/Dhaka',
    'MY': 'Asia/Kuala_Lumpur',
    'ID': 'Asia/Jakarta',
    'SG': 'Asia/Singapore',
    'TR': 'Europe/Istanbul',
    'US': 'America/New_York',
    'CA': 'America/Toronto',
    'IQ': 'Asia/Baghdad',
    'JO': 'Asia/Amman',
    'LB': 'Asia/Beirut',
    'SY': 'Asia/Damascus',
    'PS': 'Asia/Hebron',
    'OM': 'Asia/Muscat',
    'YE': 'Asia/Aden',
    'SD': 'Africa/Khartoum',
    'LY': 'Africa/Tripoli',
    'TN': 'Africa/Tunis',
    'DZ': 'Africa/Algiers',
    'MA': 'Africa/Casablanca',
    'IR': 'Asia/Tehran',
    'GB': 'Europe/London',
    'FR': 'Europe/Paris',
    'DE': 'Europe/Berlin',
    'NL': 'Europe/Amsterdam',
    'ES': 'Europe/Madrid',
    'IT': 'Europe/Rome',
    'AU': 'Australia/Sydney',
    'NZ': 'Pacific/Auckland',
  };

  /// Returns the IANA timezone name for a given country code.
  /// Falls back to [defaultTimezone] ('Asia/Riyadh' by default)
  /// for unknown or multi-zone countries.
  static String fromCountryCode(
    String code, {
    String defaultTimezone = 'Asia/Riyadh',
  }) {
    return _countryToTimezone[code.toUpperCase()] ?? defaultTimezone;
  }

  /// Converts a UTC [DateTime] produced by adhan_dart into the local
  /// wall-clock time at [ianaTimezone].
  ///
  /// Requires the timezone database to be initialized via
  /// `tz.initializeTimeZones()`.
  static DateTime utcToLocationLocal(DateTime utcTime, String ianaTimezone) {
    final location = tz.getLocation(ianaTimezone);
    return tz.TZDateTime.from(utcTime, location);
  }

  /// Returns the current date/time at [ianaTimezone] as a [TZDateTime].
  /// Useful for determining "today" in the prayer location's timezone
  /// rather than the device's timezone.
  static tz.TZDateTime nowAt(String ianaTimezone) {
    final location = tz.getLocation(ianaTimezone);
    return tz.TZDateTime.now(location);
  }

  /// Returns the "today" date in the prayer location's timezone,
  /// as a plain [DateTime] suitable for passing to adhan_dart's
  /// [PrayerTimes] constructor (which expects a local date).
  ///
  /// Using this instead of [DateTime.now] ensures we calculate
  /// prayer times for the correct calendar date at the target location.
  static DateTime todayAt(String ianaTimezone) {
    final locationNow = nowAt(ianaTimezone);
    return DateTime.utc(
      locationNow.year,
      locationNow.month,
      locationNow.day,
    );
  }

  /// Formats a UTC [DateTime] as HH:mm in the given [ianaTimezone].
  /// Returns '00:00' for null times.
  static String formatHhMm(DateTime? utcTime, String ianaTimezone) {
    if (utcTime == null) return '00:00';
    final local = utcToLocationLocal(utcTime, ianaTimezone);
    return '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  /// Attempts to find a matching IANA timezone for the given UTC offset
  /// (in minutes). Used as a last-resort fallback when geocoding and
  /// country code are unavailable.
  static String fromOffsetMinutes(int offsetMinutes) {
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

    if (table.containsKey(offsetMinutes)) return table[offsetMinutes]!;

    final nearest = table.keys.reduce(
      (a, b) => (a - offsetMinutes).abs() <= (b - offsetMinutes).abs()
          ? a
          : b,
    );
    return table[nearest]!;
  }
}
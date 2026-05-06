class PrayerNotificationConfig {
  final String callChannelId;
  final String azanChannelId;
  final String channelName;
  final String channelDescription;
  final String callSound;   // raw resource name, e.g. 'fajr_call'
  final String azanSound;   // raw resource name, e.g. 'fajr_azan'

  const PrayerNotificationConfig({
    required this.callChannelId,
    required this.azanChannelId,
    required this.channelName,
    required this.channelDescription,
    required this.callSound,
    required this.azanSound,
  });

  String channelId({required bool azanEnabled}) =>
      azanEnabled ? azanChannelId : callChannelId;

  String channelDisplayName({required bool azanEnabled}) =>
      azanEnabled ? '$channelName + Azan' : channelName;

  String sound({required bool azanEnabled}) =>
      azanEnabled ? azanSound : callSound;
}

// ── Shared constants ──────────────────────────────────────────────────────────

const kPreAlertChannelId   = 'prayer_pre_alert_v2';
const kPreAlertChannelName = 'Prayer Pre-Alert';
const kPreAlertChannelDesc = 'Notifies 15 minutes before each prayer';

/// Channels from previous architectures that must be deleted on first run
/// so Android can recreate them with the correct (new) settings.
const kLegacyChannelIds = <String>[
  'prayer_times_channel',
  'prayer_at_time_v2',
  'prayer_fajr_v2',
  'prayer_sunrise_v2',
  'prayer_dhuhr_v2',
  'prayer_asr_v2',
  'prayer_maghrib_v2',
  'prayer_isha_v2',
  'prayer_azan_v2',   // old shared azan channel
];

// ── Per-prayer configs ────────────────────────────────────────────────────────

const kPrayerConfigs = <String, PrayerNotificationConfig>{
  'Fajr': PrayerNotificationConfig(
    callChannelId: 'prayer_fajr_call_v1',
    azanChannelId: 'prayer_fajr_azan_v1',
    channelName: 'Fajr Prayer Time',
    channelDescription: 'Notification for Fajr prayer time',
    callSound: 'fajr_call',
    azanSound: 'fajr_azan',
  ),
  'Sunrise': PrayerNotificationConfig(
    callChannelId: 'prayer_sunrise_call_v1',
    azanChannelId: 'prayer_sunrise_azan_v1',
    channelName: 'Sunrise Time',
    channelDescription: 'Notification for Sunrise time',
    callSound: 'sunrise_call',
    azanSound: 'sunrise_azan',
  ),
  'Dhuhr': PrayerNotificationConfig(
    callChannelId: 'prayer_dhuhr_call_v1',
    azanChannelId: 'prayer_dhuhr_azan_v1',
    channelName: 'Dhuhr Prayer Time',
    channelDescription: 'Notification for Dhuhr prayer time',
    callSound: 'dhuhr_call',
    azanSound: 'dhuhr_azan',
  ),
  'Asr': PrayerNotificationConfig(
    callChannelId: 'prayer_asr_call_v1',
    azanChannelId: 'prayer_asr_azan_v1',
    channelName: 'Asr Prayer Time',
    channelDescription: 'Notification for Asr prayer time',
    callSound: 'asr_call',
    azanSound: 'asr_azan',
  ),
  'Maghrib': PrayerNotificationConfig(
    callChannelId: 'prayer_maghrib_call_v1',
    azanChannelId: 'prayer_maghrib_azan_v1',
    channelName: 'Maghrib Prayer Time',
    channelDescription: 'Notification for Maghrib prayer time',
    callSound: 'maghrib_call',
    azanSound: 'maghrib_azan',
  ),
  'Isha': PrayerNotificationConfig(
    callChannelId: 'prayer_isha_call_v1',
    azanChannelId: 'prayer_isha_azan_v1',
    channelName: 'Isha Prayer Time',
    channelDescription: 'Notification for Isha prayer time',
    callSound: 'isha_call',
    azanSound: 'isha_azan',
  ),
};

/// Fallback used when a prayer name doesn't match (e.g. test notifications).
const kFallbackPrayerConfig = PrayerNotificationConfig(
  callChannelId: 'prayer_fajr_call_v1',
  azanChannelId: 'prayer_fajr_azan_v1',
  channelName: 'Fajr Prayer Time',
  channelDescription: 'Notification for Fajr prayer time',
  callSound: 'fajr_call',
  azanSound: 'fajr_azan',
);

/// Notification IDs.
/// Pre-alert : 100–105
/// At-time   : 200–205
/// (Old azan IDs 300–305 are cancelled once during migration.)
const kPreAlertBaseId = 100;
const kAtTimeBaseId   = 200;
const kMaxPrayers     = 6;

/// Arabic prayer names for notification titles.
const kArabicNames = <String, String>{
  'Fajr'    : 'الفجر',
  'Sunrise' : 'الشروق',
  'Dhuhr'   : 'الظهر',
  'Asr'     : 'العصر',
  'Maghrib' : 'المغرب',
  'Isha'    : 'العشاء',
  'Test'    : 'اختبار',
};

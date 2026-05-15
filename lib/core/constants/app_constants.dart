class AppConstants {
  // SharedPreferences keys — mosque cache
  static const cachedLat = 'cached_lat';
  static const cachedLng = 'cached_lng';
  static const cachedMosques = 'cached_mosques';

  // Location
  // App-level threshold: re-fetch API only when user moves this far from the
  // position used in the last successful fetch.
  static const locationThresholdMeters = 2000;

  // OS-level stream filter: geolocator suppresses emissions until the device
  // has moved this many metres. Keeps the stream lean between 50m emissions
  // while the 250m threshold guards the actual API call.
  static const locationStreamDistanceFilterMeters = 500;

  static const defaultSearchRadiusMeters = 2000;
}
class StringsConstants {
  // ── General ──
  static const String appName = 'Al-Masjid';
  static const String loading = 'Loading...';
  static const String error = 'Something went wrong';
  static const String retry = 'Retry';
  static const String noData = 'No data available';

  // ── Mosque Details ──
  static const String mosqueDetails = 'Mosque Details';
  static const String openNow = 'Open Now';
  static const String closedNow = 'Closed Now';
  static const String statusNotFound = 'Not Found';
  static const String statusNotValid = 'Status Not Valid';
  static const String getDirections = 'Directions';
  static const String callMosque = 'Call';
  static const String website = 'Website';
  static const String shareMosque = 'Share';
  static const String addToFavorites = 'Add to Favorites';
  static const String removeFromFavorites = 'Remove from Favorites';
  static const String about = 'About';
  static const String supports = 'Supports';
  static const String amenitiesNotAvailable = 'Amenities not available';
  static const String location = 'Location';
  static const String capacity = 'Capacity';
  static const String worshippers = 'worshippers';
  static const String km = 'km';
  static const String reviews = 'reviews';
  static const String openMapsError = 'Could not open Google Maps on this device.';

  // ── Prayer Times ──
  static const String prayerTimes = 'Prayer Times';
  static const String todayPrayers = "Today's Prayers";
  static const String fajr = 'Fajr';
  static const String dhuhr = 'Dhuhr';
  static const String asr = 'Asr';
  static const String maghrib = 'Maghrib';
  static const String isha = 'Isha';
  static const String jummah = "Jumu'ah";

  // ── Mosque Search ──
  static const String searchMosques = 'Search Mosques';
  static const String nearbyMosques = 'Nearby Mosques';
  static const String searchHint = 'Search for mosques...';

  // ── Favorites ──
  static const String favorites = 'Favorites';
  static const String noFavorites = 'No saved mosques yet';

  // ── Settings ──
  static const String settings = 'Settings';
  static const String darkMode = 'Dark Mode';
  static const String lightMode = 'Light Mode';
  static const String language = 'Language';
  static const String aboutApp = 'About Al-Masjid';
  static const String contactUs = 'Contact Us';

  // ── Legacy map (kept for backward compatibility) ──
  static const Map<String, String> en = {
    'appName': 'Al-Masjid',
    'welcome': 'Find mosques near you',
    'categories': 'Categories',
    'seeAll': 'See All',
  };

  static const Map<String, String> ar = {
    'appName': 'المسجد',
    'welcome': 'ابحث عن المساجد القريبة منك',
    'categories': 'الفئات',
    'seeAll': 'عرض الكل',
  };
}

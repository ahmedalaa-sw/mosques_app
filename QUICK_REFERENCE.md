# Quick Reference Guide

## 🚀 Quick Start

### 1. Run the App
```bash
flutter pub get
flutter run
```

### 2. First Time Usage
- App automatically requests location permission on home screen load
- Grant permission when prompted
- Prayer times should load within 2-3 seconds
- If not, check internet connection and try refresh button

---

## 📋 File Structure Overview

```
lib/
├── core/
│   ├── utils/
│   │   └── geolocation_service.dart          [NEW] Location handling
│   ├── errors/
│   │   ├── failures.dart                     [UPDATED] Added LocationFailure
│   │   └── location_failures.dart            [NEW] Location-specific errors
│   └── network/
│       └── dio_helper.dart                   [Used] For API calls
│
├── features/
│   └── home/
│       ├── model/
│       │   ├── home_model.dart              [UPDATED] Added AladhanPrayerTimesModel
│       │   └── home_repo.dart               [UPDATED] Prayer times + location logic
│       └── view/
│           ├── home_screen.dart             [UPDATED] BLoC integration
│           ├── cubit/
│           │   ├── home_cubit.dart          [NEW] State management
│           │   └── home_state.dart          [NEW] State definitions
│           └── widgets/
│               ├── prayer_time_card.dart    [UPDATED] Dynamic prayer display
│               └── prayer_schedule_section.dart [UPDATED] Dynamic schedule

android/
└── app/src/main/
    └── AndroidManifest.xml                   [UPDATED] Added permissions

ios/
└── Runner/
    └── Info.plist                            [UPDATED] Added location descriptions
```

---

## 🔑 Key Code Snippets

### Initialize Cubit in Widget
```dart
late HomeCubit _homeCubit;

@override
void initState() {
  super.initState();
  _homeCubit = HomeCubit(repository: HomeRepository());
  _homeCubit.loadPrayerTimes();
}

@override
void dispose() {
  _homeCubit.close();
  super.dispose();
}
```

### Handle States in UI
```dart
BlocBuilder<HomeCubit, HomeState>(
  builder: (context, state) {
    if (state is HomeLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (state is HomeLoaded) {
      return PrayerScheduleSection(prayers: state.prayers);
    } else if (state is HomeError) {
      return ErrorWidget(message: state.message);
    }
    return SizedBox();
  },
)
```

### Get Current Location
```dart
final position = await GeolocationService.getCurrentLocation();
print('Lat: ${position.latitude}, Lng: ${position.longitude}');
```

### Fetch Prayer Times for Location
```dart
final cubit = context.read<HomeCubit>();
await cubit.loadPrayerTimesForLocation(
  latitude: 51.5074,
  longitude: -0.1278,
);
```

---

## 🐛 Common Issues & Solutions

### Issue: "Location permission is required" appears repeatedly
**Solution:**
- Check AndroidManifest.xml has correct permissions
- Check iOS Info.plist has usage descriptions
- Grant permission once and restart app
- Clear app cache if issue persists

### Issue: Prayer times show "05:00 AM" etc (defaults)
**Solution:**
- Check internet connection
- Verify Aladhan API is accessible (not blocked by firewall)
- Check DioHelper is initialized in main.dart
- Review network logs in debug console

### Issue: "Location services are disabled" message
**Solution:**
- Enable location services in device settings
- Turn on GPS
- Retry in app

### Issue: Wrong prayer times for location
**Solution:**
- Verify correct coordinates are being sent
- Check prayer calculation method (using Jafari method - most accurate)
- Cross-reference with aladhan.com website for same location
- Try different location to verify API works

---

## ✅ Verification Steps

### 1. Check Location Permission
```dart
final hasPermission = await GeolocationService.hasLocationPermission();
print('Has permission: $hasPermission');
```

### 2. Verify API Connectivity
```dart
// Test API directly in debug console
final response = await DioHelper.getData(
  endpoint: 'https://api.aladhan.com/v1/timings/1704067200',
  queryParameters: {
    'latitude': 40.7128,
    'longitude': -74.0060,
    'method': 2,
  },
);
print(response.data);
```

### 3. Check Prayer Times Parsing
```dart
final jsonData = response.data['data'];
final prayerTimes = AladhanPrayerTimesModel.fromJson(jsonData);
print('Fajr: ${prayerTimes.fajr}');
print('Dhuhr: ${prayerTimes.dhuhr}');
```

---

## 🔄 State Flow Diagram

```
[HomeScreen Init]
        ↓
[Check Permission]
    ↙         ↘
[Not Granted] [Granted]
    ↓            ↓
[Request]   [GetLocation]
    ↓            ↓
[FetchAPI] ← [Get Coords]
    ↓
[Parse Response]
    ↓
[Emit HomeLoaded]
    ↓
[Build UI with Prayers]
```

---

## 📱 UI States Map

```
HomeInitial → HomeLoading → HomeLoaded (with prayers)
                              ↑
                    [Refresh Button]

HomeInitial → HomeLoading → HomePermissionDenied (with retry)

HomeInitial → HomeLoading → HomeError (with retry)
```

---

## 🌐 API Methods Reference

### Prayer Calculation Methods
- `1`: Karachi (Islamic Society of North America)
- `2`: Jafari (Shia method, **USED**)
- `3`: Egyptian
- `4`: Makkah (University of Islamic Sciences)
- `5`: Madina
- `7`: Kuwait
- `8`: Qatar
- `9`: Singapore
- `10`: Tunisia
- `11`: Turkey
- `12`: JAKIM (Malaysia)
- `13`: ISNA
- `14`: MWL (Muslim World League)
- `15`: UOIF (French Muslim Organization)

### Islamic Schools
- `0`: Shafi (**USED**)
- `1`: Hanafi

---

## 📊 Response Data Available

From `AladhanPrayerTimesModel`:
```dart
// Prayer Times
String fajr;        // "05:22"
String sunrise;     // "06:54"
String dhuhr;       // "13:12"
String asr;         // "16:38"
String maghrib;     // "19:30"
String isha;        // "20:52"
String imsak;       // "05:12" (before Fajr)
String midnight;    // "00:22"

// Location
double latitude;    // 51.5074
double longitude;   // -0.1278

// Method Info
String methodName;  // "Jafari"
String schoolName;  // "Shafi"

// Date
DateTime date;      // DateTime object
```

---

## 🔐 Permissions Required

### Android
```xml
<!-- Required -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.INTERNET"/>

<!-- Optional for background -->
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>
```

### iOS
```xml
NSLocationWhenInUseUsageDescription
NSLocationAlwaysAndWhenInUseUsageDescription
NSLocationAlwaysUsageDescription
```

---

## 🧹 Cleanup/Teardown

### When Screen Closes
```dart
@override
void dispose() {
  _homeCubit.close();  // Important: Clean up Cubit
  super.dispose();
}
```

### When Switching Locations
```dart
// Old location data is cleared
_homeCubit.loadPrayerTimesForLocation(
  latitude: newLat,
  longitude: newLng,
);
// New state is emitted, old data replaced
```

---

## 💾 Data Persistence (For Future)

Currently, prayer times are **NOT** cached. To implement:

```dart
// 1. Use Hive (already in project)
// 2. Cache key: 'prayers_${lat}_${lng}'
// 3. Cache expiry: 24 hours
// 4. Fallback if no internet

// Example:
final box = await Hive.openBox('prayers');
box.put('prayers_51.5074_-0.1278', prayerData);
```

---

## 🚨 Error Codes Reference

| Code | Meaning | Action |
|------|---------|--------|
| 403 | Permission Denied | Request/retry permission |
| 400 | Bad Request | Check parameters |
| 500 | Server Error | Retry later |
| 503 | Service Unavailable | Location disabled |
| Network | No Internet | Check connection |

---

## 🎯 Development Tips

1. **Use Real Device**: Geolocator works better on real devices
2. **Mock for Testing**: Mock `GeolocationService` for unit tests
3. **Use Aladhan Website**: Verify times at https://aladhan.com
4. **Check Logs**: Enable debug logs to see API responses
5. **Test Permissions**: Test both granted and denied scenarios
6. **Test Offline**: Test API error handling

---

## 📞 Useful Resources

- **Aladhan API Docs**: https://aladhan.com/api
- **Geolocator Package**: https://pub.dev/packages/geolocator
- **BLoC Documentation**: https://bloclibrary.dev
- **Flutter Docs**: https://flutter.dev/docs

---

## ✨ Pro Tips

1. **Reduce API Calls**: Cache prayer times for 24 hours
2. **Improve UX**: Add countdown timer to prayer times
3. **Add Notifications**: Use flutter_local_notifications for prayer alerts
4. **Offline Support**: Cache last known prayer times using Hive
5. **Analytics**: Track which prayers are viewed most
6. **Qibla Direction**: Add compass integration for prayer direction
7. **Different Methods**: Let user select calculation method
8. **Multiple Locations**: Save favorite prayers locations

# Adhan_Dart Implementation - Quick Reference

## What Changed?

The home feature now uses **offline prayer time calculations** via `adhan_dart` instead of making API calls to Aladhan API.

| Aspect | Before (API) | After (Offline) |
|--------|-------------|-----------------|
| **Source** | Aladhan REST API | Local adhan_dart calculations |
| **Network** | Required | Only for location (geolocator) |
| **Speed** | Network latency | Instant calculation |
| **Coverage** | API limitations | Worldwide (any coordinates) |
| **Configuration** | Fixed (Jafari/Shafi) | Customizable methods & madhabs |
| **Reliability** | API availability dependent | Always works offline |

## Key Files Modified

```
lib/features/home/
├── model/
│   ├── home_model.dart           ← Now converts adhan_dart results
│   └── home_repo.dart            ← Uses AdhanPrayerService
├── view/cubit/
│   └── home_cubit.dart           ← Enhanced prayer detection
└── [widgets/ unchanged]

lib/core/services/
└── adhan_prayer_service.dart     ← NEW wrapper service
```

## Quick Start

### 1. Basic Prayer Time Calculation
```dart
// In HomeRepository or anywhere
import 'package:mosques_app/core/services/adhan_prayer_service.dart';

final prayerTimes = AdhanPrayerService.calculatePrayerTimes(
  latitude: 51.5074,  // Your latitude
  longitude: -0.1278, // Your longitude
  // date: DateTime.now(), // Optional
);

// prayerTimes now contains all prayer times for the day
print('Fajr: ${prayerTimes.fajr}');
print('Dhuhr: ${prayerTimes.dhuhr}');
print('Asr: ${prayerTimes.asr}');
```

### 2. Configure Calculation Method
```dart
// Call once at app startup
import 'package:adhan_dart/adhan_dart.dart';

AdhanPrayerService.setCalculationMethod(
  CalculationMethod.northAmerica, // For North America
);

// Or with default (Muslim World League)
AdhanPrayerService.setCalculationMethod(
  CalculationMethod.muslimWorldLeague,
);
```

### 3. Configure Madhab (School)
```dart
AdhanPrayerService.setMadhab(Madhab.shafii);   // Default
// OR
AdhanPrayerService.setMadhab(Madhab.shafi);   // 2:1 shadow for Asr
```

### 4. Get Current Configuration
```dart
final config = AdhanPrayerService.getCurrentConfig();
print(config); // PrayerConfig(method: ..., madhab: ...)
```

## State Flow (Unchanged UI)

```
User opens Home Screen
        ↓
HomeCubit.loadPrayerTimes()
        ↓
Check location permission
        ↓
Get device location (geolocator)
        ↓
AdhanPrayerService.calculatePrayerTimes()
        ↓
AladhanPrayerTimesModel.fromAdhanPrayerTimes()
        ↓
HomeLoaded state emitted
        ↓
UI renders (LoadedView, unchanged)
```

## Data Model

### Input to AdhanPrayerService
```dart
latitude: double      // e.g., 51.5074
longitude: double     // e.g., -0.1278
date: DateTime?       // Optional, defaults to today
```

### Output from Calculation
```dart
PrayerTimes {
  fajr: DateTime
  sunrise: DateTime
  dhuhr: DateTime
  asr: DateTime
  maghrib: DateTime
  isha: DateTime
  imsak: DateTime
  midnight: DateTime
}
```

### Converted to AladhanPrayerTimesModel
```dart
AladhanPrayerTimesModel {
  fajr: String         // "05:30"
  sunrise: String      // "06:45"
  dhuhr: String        // "12:30"
  asr: String          // "16:00"
  maghrib: String      // "18:45"
  isha: String         // "20:15"
  imsak: String        // "05:15"
  midnight: String     // "00:15"
  latitude: double
  longitude: double
  methodName: String   // "Muslim World League"
  schoolName: String   // "Shafi"
  date: DateTime
}
```

## Available Calculation Methods

| Method | Code | Use Case |
|--------|------|----------|
| Muslim World League | `CalculationMethod.muslimWorldLeague` | **Default**, worldwide |
| ISNA | `CalculationMethod.northAmerica` | North America |
| Egyptian Authority | `CalculationMethod.egyptian` | Egypt, Middle East |
| Umm Al-Qura | `CalculationMethod.ummAlQura` | Saudi Arabia, Gulf |
| Karachi | `CalculationMethod.karachi` | Pakistan, South Asia |
| Tehran | `CalculationMethod.tehran` | Iran, Central Asia |
| Jafari | `CalculationMethod.jafari` | Shia calculations |

## Available Madhabs

| Madhab | Code | Asr Calculation |
|--------|------|-----------------|
| Shafii | `Madhab.shafii` | **Default**, 1:1 shadow ratio |
| Hanafi | `Madhab.shafi` | 2:1 shadow ratio |

## Error Handling

```dart
// In HomeCubit
result.fold(
  (failure) {
    // Handle error
    if (failure is ServerFailure && failure.statusCode == 403) {
      emit(HomePermissionDenied(...)); // Location permission denied
    } else {
      emit(HomeError(...)); // Calculation failed
    }
  },
  (prayerTimes) {
    // Success - render prayer times
    emit(HomeLoaded(...));
  },
);
```

## Current Prayer Detection

The cubit automatically detects which prayer is currently occurring:

```dart
final currentPrayer = _getCurrentPrayerName(prayerTimes);
// Returns: "Fajr", "Dhuhr", "Asr", etc., or null if no prayer
```

Logic:
- Compares system time with prayer time windows
- Prayer window = from prayer time to next prayer time
- Last prayer (Isha) window extends to midnight

## Testing Prayer Times

### Test Case 1: London
```dart
final prayerTimes = AdhanPrayerService.calculatePrayerTimes(
  latitude: 51.5074,
  longitude: -0.1278,
  date: DateTime(2024, 5, 2), // Example date
);
```

### Test Case 2: Cairo
```dart
final prayerTimes = AdhanPrayerService.calculatePrayerTimes(
  latitude: 30.0444,
  longitude: 31.2357,
);
```

### Test Case 3: Tokyo
```dart
final prayerTimes = AdhanPrayerService.calculatePrayerTimes(
  latitude: 35.6762,
  longitude: 139.6503,
);
```

## Common Customizations

### 1. Add User Preference for Calculation Method
```dart
// In settings provider/repository
void saveCalculationMethod(CalculationMethod method) {
  AdhanPrayerService.setCalculationMethod(method);
  // Save to SharedPreferences
}

// On app start
void loadUserPreferences() {
  final saved = prefs.getString('calculation_method') ?? 'muslimWorldLeague';
  AdhanPrayerService.setCalculationMethod(_stringToMethod(saved));
}
```

### 2. Add Prayer Time Notifications
```dart
// After getting prayer times
void schedulePrayerNotifications(AladhanPrayerTimesModel times) {
  _scheduleNotification('Fajr', times.fajr);
  _scheduleNotification('Dhuhr', times.dhuhr);
  _scheduleNotification('Asr', times.asr);
  _scheduleNotification('Maghrib', times.maghrib);
  _scheduleNotification('Isha', times.isha);
}
```

### 3. Display Prayer Times for Multiple Days
```dart
// In repository
Future<List<AladhanPrayerTimesModel>> getPrayerTimesForDays({
  required double latitude,
  required double longitude,
  required int dayCount,
}) async {
  final List<AladhanPrayerTimesModel> results = [];
  for (int i = 0; i < dayCount; i++) {
    final date = DateTime.now().add(Duration(days: i));
    final prayerTimes = AdhanPrayerService.calculatePrayerTimes(
      latitude: latitude,
      longitude: longitude,
      date: date,
    );
    // Convert and add to results
  }
  return results;
}
```

## Debugging

### Enable Logging
```dart
// Add to HomeCubit or repository
print('Calculating prayer times for: $latitude, $longitude');
final prayerTimes = AdhanPrayerService.calculatePrayerTimes(
  latitude: latitude,
  longitude: longitude,
);
print('Calculated prayer times: $prayerTimes');
print('Current config: ${AdhanPrayerService.getCurrentConfig()}');
```

### Verify Prayer Times
```dart
// Check against online calculator
// https://www.timeanddate.com/prayer/
// Compare results for accuracy
```

### Check Location
```dart
// Verify location is correct
final position = await GeolocationService.getCurrentLocation();
print('Location: ${position.latitude}, ${position.longitude}');
print('Accuracy: ${position.accuracy}m');
```

## No UI Changes Required

✅ All existing UI components remain unchanged:
- HomeScreen structure
- LoadedView layout
- PrayerCountdownSection
- PrayerScheduleSection
- Prayer cards and styling

The migration is **completely transparent to the UI layer**.

## Dependencies

Required packages (already in pubspec.yaml):
- `adhan_dart: ^1.2.0` - Prayer time calculations
- `geolocator: ^14.0.2` - Location services
- `flutter_bloc: ^9.1.1` - State management
- (No more: `dio`, `pretty_dio_logger`, `dio_http_cache`)

## Rollback Plan

If needed to revert to API:

1. Restore `HomeRepository._fetchPrayerTimesFromApi()` method
2. Update `AladhanPrayerTimesModel.fromJson()` to parse API response
3. Remove `AdhanPrayerService` imports
4. Re-add `DioHelper` imports

---

**Status**: ✅ Migration Complete - Production Ready
**Last Updated**: May 2, 2026

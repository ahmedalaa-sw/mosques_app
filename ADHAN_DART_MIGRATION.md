# Adhan_Dart Migration Guide

## Overview
The home feature has been successfully migrated from the Aladhan API to the `adhan_dart` package for offline, worldwide prayer time calculations.

## Key Benefits
- **Offline Support**: Prayer times calculated locally without internet connection (location still required)
- **Worldwide Coverage**: Works for any location on Earth using longitude/latitude
- **No API Dependency**: Eliminates network requests and API rate limiting concerns
- **Same UI/UX**: User interface remains unchanged - transparent migration
- **Flexible Configuration**: Support for multiple calculation methods and madhabs (schools)

## Architecture Changes

### Removed
- **Aladhan API calls** in `HomeRepository._fetchPrayerTimesFromApi()`
- **DioHelper dependencies** for API requests in prayer times fetching
- **Network error handling** specific to API responses

### Added
- **AdhanPrayerService** (`core/services/adhan_prayer_service.dart`): Wrapper for adhan_dart calculations
- **Offline calculation** in `HomeRepository._calculatePrayerTimesOffline()`
- **Enhanced prayer detection** in `HomeCubit._getCurrentPrayerName()`

### Modified
- **AladhanPrayerTimesModel**: Changed from API parsing to adhan_dart result conversion
- **HomeRepository**: Now uses AdhanPrayerService for calculations
- **HomeCubit**: Improved current prayer detection logic with time comparison

## File Structure

```
lib/
├── core/
│   └── services/
│       └── adhan_prayer_service.dart          (NEW)
│
└── features/home/
    ├── model/
    │   ├── home_model.dart                    (MODIFIED)
    │   └── home_repo.dart                     (MODIFIED)
    └── view/
        ├── cubit/
        │   └── home_cubit.dart               (MODIFIED)
        └── widgets/
            └── [No changes - UI untouched]
```

## API Integration

### AdhanPrayerService

The service provides a clean interface to adhan_dart functionality:

```dart
// Calculate prayer times for a location
final prayerTimes = AdhanPrayerService.calculatePrayerTimes(
  latitude: 51.5074,      // London
  longitude: -0.1278,
  date: DateTime.now(),   // Optional, defaults to today
);

// Configure calculation method
AdhanPrayerService.setCalculationMethod(
  CalculationMethod.muslimWorldLeague,
);

// Configure madhab (school)
AdhanPrayerService.setMadhab(Madhab.shafii);

// Get current configuration
final config = AdhanPrayerService.getCurrentConfig();

// Get available methods and madhabs
final methods = AdhanPrayerService.getAvailableCalculationMethods();
final madhabs = AdhanPrayerService.getAvailableMadhabs();
```

### Available Calculation Methods

1. **Muslim World League** (Default)
   - Method: `CalculationMethod.muslimWorldLeague`
   - Used by: Muslim World League

2. **Islamic Society of North America (ISNA)**
   - Method: `CalculationMethod.northAmerica`
   - Used by: ISNA

3. **Egyptian General Authority of Survey**
   - Method: `CalculationMethod.egyptian`
   - Used by: Egyptian Authority

4. **Umm al-Qura, Mecca**
   - Method: `CalculationMethod.ummAlQura`
   - Used by: Umm al-Qura University

5. **University of Islamic Sciences, Karachi**
   - Method: `CalculationMethod.karachi`
   - Used by: Karachi University

6. **Institute of Geophysics, University of Tehran**
   - Method: `CalculationMethod.tehran`
   - Used by: Tehran University

7. **Jafari** (Shia method)
   - Method: `CalculationMethod.jafari`
   - Used by: Shia calculations

### Available Madhabs (Schools)

1. **Shafii** (Default)
   - Madhab: `Madhab.shafii`
   - Asr shadow ratio: 1:1

2. **Hanafi**
   - Madhab: `Madhab.hanafi`
   - Asr shadow ratio: 2:1

## Data Flow

```
HomeScreen (UI)
    ↓
HomeCubit (State Management)
    ├── loadPrayerTimes()
    │   └── repository.getPrayerTimesForCurrentLocation()
    │       ├── GeolocationService.getCurrentLocation()
    │       │   └── geolocator package
    │       └── _calculatePrayerTimesOffline()
    │           └── AdhanPrayerService.calculatePrayerTimes()
    │               └── adhan_dart package
    ├── result: Either<Failure, AladhanPrayerTimesModel>
    └── emit(HomeLoaded | HomeError | HomePermissionDenied)
        └── UI renders via BlocBuilder
```

## Current Prayer Detection

The `HomeCubit._getCurrentPrayerName()` method now properly identifies which prayer is currently occurring:

```dart
String? _getCurrentPrayerName(AladhanPrayerTimesModel prayerTimes) {
  // Compares current system time with prayer times
  // Returns prayer name if within prayer window
  // Returns null if no prayer is currently occurring
}
```

**Logic:**
1. Get current time from system
2. Define prayer time windows (start to next prayer)
3. Check if current time falls within any window
4. Return the prayer name if match found
5. Handle edge case: last prayer (Isha) extends to midnight

## Error Handling

The implementation maintains robust error handling:

```dart
// Location permission errors (403)
→ HomePermissionDenied state

// Calculation errors
→ HomeError with descriptive message

// Network errors (API removed, now irrelevant)
→ No longer applicable
```

## Testing Recommendations

### Unit Tests
```dart
test('Calculate prayer times for London', () {
  final prayerTimes = AdhanPrayerService.calculatePrayerTimes(
    latitude: 51.5074,
    longitude: -0.1278,
  );
  
  expect(prayerTimes.fajr, isNotNull);
  expect(prayerTimes.dhuhr, isNotNull);
});

test('Identify current prayer correctly', () {
  // Mock DateTime and test prayer detection logic
});
```

### Integration Tests
```dart
testWidgets('Load prayer times without API', (WidgetTester tester) async {
  // Verify HomeCubit loads prayer times offline
  // Verify UI displays correct times
  // Verify current prayer is highlighted
});

testWidgets('Handle location permission denial', (WidgetTester tester) async {
  // Verify PermissionDeniedView shows when permission denied
});
```

### Manual Testing Checklist
- [ ] App loads prayer times after granting location permission
- [ ] Prayer times match adhan_dart calculations for your location
- [ ] Current prayer is correctly highlighted
- [ ] Refresh button recalculates prayer times
- [ ] Offline functionality works (disable internet after loading)
- [ ] Different locations show correct times (use coordinates input if available)
- [ ] No API calls appear in network logs (verify offline)

## Configuration Options

### Setting Calculation Method
```dart
// In home_repo.dart or during app initialization
AdhanPrayerService.setCalculationMethod(
  CalculationMethod.northAmerica, // ISNA method
);
```

### Setting Madhab
```dart
// Affects Asr prayer calculation
AdhanPrayerService.setMadhab(Madhab.hanafi);
```

### Making Configuration User-Configurable
To allow users to customize calculation method:

```dart
// In settings/preferences screen
final availableMethods = AdhanPrayerService.getAvailableCalculationMethods();

ElevatedButton(
  onPressed: () {
    AdhanPrayerService.setCalculationMethod(selectedMethod);
    context.read<HomeCubit>().refreshPrayerTimes();
  },
  child: Text('Save Settings'),
)
```

## Migration Checklist

- [x] Remove Aladhan API endpoint calls
- [x] Add adhan_dart package to pubspec.yaml (already present)
- [x] Create AdhanPrayerService wrapper
- [x] Update AladhanPrayerTimesModel for adhan_dart conversion
- [x] Update HomeRepository to use AdhanPrayerService
- [x] Enhance HomeCubit with proper prayer detection
- [x] Maintain existing state management (Cubit/States)
- [x] Verify no UI changes required
- [x] Remove DioHelper dependency from prayer fetching
- [x] Add offline calculation logic
- [x] Update error handling for new architecture

## Performance Impact

- **Initialization**: Negligible impact (local calculation)
- **Memory**: Slight increase (adhan_dart algorithms in memory)
- **CPU**: Minimal impact (calculations are lightweight)
- **Network**: Eliminated (no API calls)
- **Battery**: Potential improvement (no network overhead)

## Backward Compatibility

⚠️ **Breaking Change**: The data source is now local calculation instead of API.

**Potential Differences:**
- Prayer times may vary slightly due to different calculation algorithms
- The calculation method can now be configured (was fixed to Jafari/Shafi via API)
- No API metadata available (method details now internal)

**Migration Path:**
Users should validate that prayer times match their preferred calculation method using the configuration options provided.

## Troubleshooting

### Prayer times don't match my location
→ Check latitude/longitude accuracy
→ Verify calculation method matches your preference
→ Try setting madhab explicitly

### Current prayer not highlighting correctly
→ Verify system time is correct
→ Check prayer time format parsing
→ Look at HomeCubit logs for prayer time windows

### Permission issues
→ Check if location permission is granted in system settings
→ Look for LocationPermissionException in logs
→ Verify GeolocationService integration

## Future Enhancements

1. **User Preferences**: Store user's preferred calculation method
2. **Multiple Dates**: Add ability to view prayer times for multiple days
3. **Timezone Handling**: Explicit timezone configuration
4. **Prayer Notifications**: Add notifications for prayer times
5. **Qibla Direction**: Integrate qibla calculation from adhan_dart
6. **Hijri Calendar**: Display Islamic calendar dates alongside prayer times

## References

- [adhan_dart Package](https://pub.dev/packages/adhan_dart)
- [Adhan JavaScript Library](https://github.com/batoulapps/Adhan)
- [Prayer Time Calculation Methods](https://en.wikipedia.org/wiki/Islamic_prayer_times#Calculated_times)

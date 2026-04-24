# Aladhan Prayer Times Integration - Configuration Guide

## Overview
This document outlines all the configuration changes and setup requirements for integrating Aladhan API with geolocation capabilities in the mosques_app Flutter project.

## Files Created

### 1. **Geolocation Service** (`lib/core/utils/geolocation_service.dart`)
Handles all location permission requests and location fetching logic.

**Key Methods:**
- `getCurrentLocation()` - Gets user's current location with permission handling
- `requestLocationPermission()` - Explicitly requests location permission
- `hasLocationPermission()` - Checks if permission is already granted
- `openLocationSettings()` - Opens app settings for manual permission enable

### 2. **Prayer Times Model** (Updated `lib/features/home/model/home_model.dart`)
Extended with `AladhanPrayerTimesModel` class that:
- Parses Aladhan API responses
- Contains all prayer times (Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha)
- Stores location metadata (latitude, longitude)
- Converts to UI-friendly `PrayerModel` list

### 3. **Prayer Times Repository** (`lib/features/home/model/home_repo.dart`)
Implements repository pattern for:
- Fetching user's geolocation
- Making Aladhan API calls
- Handling errors and permission checks
- Supporting manual location input

**Main Methods:**
- `getPrayerTimesForCurrentLocation()` - Auto-detects location and fetches prayer times
- `getPrayerTimesForLocation()` - Fetches for specific coordinates
- `hasLocationPermission()` - Check permission status
- `requestLocationPermission()` - Request permission

### 4. **Home Cubit** (Created `lib/features/home/view/cubit/home_cubit.dart`)
State management using BLoC pattern:
- `loadPrayerTimes()` - Load prayer times on screen init
- `refreshPrayerTimes()` - Manual refresh
- `loadPrayerTimesForLocation()` - Load for specific coordinates

**States:**
- `HomeInitial` - Initial state
- `HomeLoading` - Loading prayer times
- `HomeLoaded` - Successfully loaded
- `HomeError` - API/network error
- `HomePermissionDenied` - Location permission denied

### 5. **Home State Classes** (Created `lib/features/home/view/cubit/home_state.dart`)
Defines all possible states with proper equality operators.

### 6. **Updated Home Screen** (Updated `lib/features/home/view/home_screen.dart`)
- Initializes `HomeCubit` with repository
- Handles all state UI rendering
- Shows loading, success, error, and permission denied states
- Includes refresh button in AppBar

### 7. **Updated Prayer Time Card Widget** (Updated `lib/features/home/view/widgets/prayer_time_card.dart`)
- Accepts `AladhanPrayerTimesModel` data
- Dynamically calculates current prayer
- Automatically determines next prayer
- Displays dynamic sunrise/sunset times
- Converts 24-hour to 12-hour format

### 8. **Updated Prayer Schedule Widget** (Updated `lib/features/home/view/widgets/prayer_schedule_section.dart`)
- Accepts dynamic prayer list from Cubit
- Displays location coordinates
- Shows prayer method name
- Maintains fallback to static data if no dynamic data provided

---

## Platform-Specific Configuration

### Android Configuration (`android/app/src/main/AndroidManifest.xml`)

Add the following permissions:

```xml
<!-- Location Permissions -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

<!-- Required for Android 11+ when requesting background location -->
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />

<!-- Internet permission for API calls -->
<uses-permission android:name="android.permission.INTERNET" />
```

**Additional Setup for Geolocator (Android):**
The `geolocator` package requires:
- Google Play Services location library
- Already configured in `pubspec.yaml` with version `^14.0.2`

### iOS Configuration (`ios/Runner/Info.plist`)

Add location usage descriptions:

```xml
<!-- Location Permissions -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to your location to show prayer times based on your current location.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs access to your location to show prayer times based on your current location.</string>

<key>NSLocationAlwaysUsageDescription</key>
<string>This app needs access to your location to show prayer times based on your current location.</string>
```

---

## API Integration Details

### Aladhan API Endpoint
```
https://api.aladhan.com/v1/timings/{timestamp}
```

**Query Parameters:**
- `latitude` - User's latitude (double)
- `longitude` - User's longitude (double)
- `method` - Calculation method (2 = Jafari method, most accurate)
- `school` - Islamic school (0 = Shafi)
- `adjustment` - Time adjustment (0 = no adjustment)

**Response Format:**
```json
{
  "code": 200,
  "status": "OK",
  "data": {
    "timings": {
      "Fajr": "05:22",
      "Sunrise": "06:54",
      "Dhuhr": "13:12",
      "Asr": "16:38",
      "Sunset": "19:30",
      "Maghrib": "19:30",
      "Isha": "20:52",
      "Imsak": "05:12",
      "Midnight": "00:22"
    },
    "meta": {
      "latitude": 51.5074,
      "longitude": -0.1278,
      "timezone": "Europe/London",
      "method": {
        "id": 2,
        "name": "Jafari"
      },
      "school": "Shafi",
      "offset": {}
    }
  }
}
```

---

## Error Handling

The implementation handles several error scenarios:

### 1. **Location Services Disabled**
- Shows error message
- Provides option to enable in system settings
- Error: `"Location services are disabled. Please enable them."`

### 2. **Permission Denied**
- Requests permission once
- Shows permission denied UI if user refuses
- Provides "Retry" button for another attempt
- Error: `"Location permission is required to display prayer times."`

### 3. **Network/API Errors**
- Handles DioException
- Shows error message with status code
- Allows retry
- Generic error handling for unknown exceptions

### 4. **Invalid Location Data**
- Validates API response format
- Returns fallback values if parsing fails
- Logs errors for debugging

---

## Dependencies

All required dependencies are already in `pubspec.yaml`:

```yaml
dio: ^5.9.2              # HTTP client
flutter_bloc: ^9.1.1     # State management
geolocator: ^14.0.2      # Location services
flutter_screenutil: ^5.9.3 # Responsive UI
```

**No additional dependencies needed!**

---

## Usage Flow

### User Starts App
1. Home screen initializes
2. `HomeCubit.loadPrayerTimes()` is called
3. System checks location permission status

### Permission Check
- If permission already granted → Fetch location → Fetch prayer times
- If permission not granted → Request permission
- If denied → Show permission denied UI with retry button

### Data Fetch
1. `GeolocationService.getCurrentLocation()` gets lat/lng
2. `DioHelper.getData()` calls Aladhan API with coordinates
3. Response parsed to `AladhanPrayerTimesModel`
4. `HomeLoaded` state emitted with prayer data

### UI Rendering
- Prayer timer card displays current prayer with countdown
- Prayer schedule shows all 6 daily prayers with dynamic times
- Location info shows latitude/longitude for transparency
- Dynamic sunrise/sunset times displayed

---

## Testing Checklist

- [ ] App requests location permission on first launch
- [ ] Prayer times load correctly after permission granted
- [ ] Current prayer is highlighted correctly
- [ ] Next prayer countdown is accurate
- [ ] Refresh button works and reloads prayer times
- [ ] Error handling shows appropriate messages
- [ ] App handles offline scenarios gracefully
- [ ] Permission denied state shows helpful message
- [ ] All prayer times display in 12-hour format
- [ ] Location coordinates shown in prayer schedule

---

## Production Considerations

1. **Cache Strategy**: Consider caching prayer times to reduce API calls
2. **Auto-refresh**: Implement periodic updates every 24 hours
3. **Background Location**: For future features like prayer notifications
4. **Privacy**: Ensure location data is not logged or transmitted elsewhere
5. **Rate Limiting**: Aladhan API has fair usage policy
6. **Error Tracking**: Integrate crash reporting for production errors

---

## Troubleshooting

### Permission Dialog Not Showing
- Ensure AndroidManifest.xml has proper permissions
- Check iOS Info.plist has usage descriptions
- Test on actual device, not emulator for first-time permission

### Prayer Times Not Updating
- Check internet connection
- Verify API endpoint is accessible
- Check DioHelper base URL is set (currently empty, uses full URL)
- Review network logs for API failures

### Location Not Available
- Ensure location services are enabled on device
- Check app has location permission granted
- Verify device has GPS/network location available
- Test with different location if current location is unavailable

---

## Future Enhancements

1. **Prayer Notifications**: Add local notifications for prayer times
2. **Multiple Locations**: Allow users to save favorite prayer locations
3. **Qibla Direction**: Integrate compass for prayer direction
4. **Monthly Calendar**: Full month view of prayer times
5. **Mosque Finder**: Integration with mosque search feature
6. **Alarm**: Add prayer time alarms
7. **Different Calculation Methods**: Allow user to select prayer calculation method

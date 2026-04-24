# Mosques App - Codebase Analysis Report

## 1. GEOLOCATION & LOCATION USAGE

### Package Integration
- **Package**: `geolocator: ^14.0.2`
- **Location**: [pubspec.yaml](pubspec.yaml)
- **Status**: ✅ Installed but not yet utilized in code
- **Platform Support**: Multi-platform (Android, iOS, macOS, Windows, Linux, Web)

### Current Implementation
- Geolocator plugin registered in platform-specific files:
  - macOS: `macos/Flutter/GeneratedPluginRegistrant.swift`
  - Windows: `windows/flutter/generated_plugin_registrant.cc`
  - Android: `build/geolocator_android/`

### Existing Usage Patterns (in MosqueModel)
- **File**: [lib/features/mosque_search/models/mosque_model.dart](lib/features/mosque_search/models/mosque_model.dart)
- **Data Structure**:
  ```dart
  final double lat;        // Latitude
  final double lng;        // Longitude
  final double distanceMeters;  // Calculated distance
  ```
- **Distance Display**: `distanceLabel` getter formats distance (meters < 1000 | kilometers >= 1000)

### Location Constants & Strings
- **File**: Strings defined in project but actual file path needs to map from semantic search results
- **Constants Found**:
  - `AppStrings.searchHint` = 'Find a mosque near you...'
  - `AppStrings.findingLocation` = 'Finding your location…'
  - `AppStrings.locationServicesDisabled` = 'Location services are disabled. Please enable GPS.'
  - `AppStrings.locationPermissionDenied` = 'Location permission was denied.'

### Recommended Integration Points
- **Search Feature**: [lib/features/mosque_search/](lib/features/mosque_search/)
  - `viewmodels/mosque_search_viewmodel.dart` (currently empty - ideal for location logic)
  - Can use `geolocator.getCurrentPosition()` for one-time location fetch
  - Can use `geolocator.getPositionStream()` for continuous location tracking

---

## 2. PRAYER TIME MODELS & DATA STRUCTURES

### Home Feature Prayer Model
**File**: [lib/features/home/model/home_model.dart](lib/features/home/model/home_model.dart)
```dart
class PrayerModel {
  final String name;       // Prayer name (e.g., 'Dhuhr', 'Asr')
  final String time;       // Prayer time as string (e.g., '01:12 PM')
  final IconData icon;     // Visual representation
  final bool isHighlighted; // For highlighting current prayer
}
```

### Prayer Times Feature (Scaffold)
- **Location**: [lib/features/prayer_times/](lib/features/prayer_times/)
- **Structure**:
  - `models/prayer_time_model.dart` - (empty, awaiting implementation)
  - `repo/prayer_times_repo.dart` - (empty, awaiting implementation)
  - `views/prayer_times_screen.dart` - (empty, awaiting implementation)

### Prayer Schedule Display
**File**: [lib/features/home/view/widgets/prayer_schedule_section.dart](lib/features/home/view/widgets/prayer_schedule_section.dart)
- Displays 6 prayers with hardcoded times:
  1. Fajr - 05:22 AM
  2. Sunrise - 06:54 AM
  3. Dhuhr - 01:12 PM (currently highlighted)
  4. Asr - 04:38 PM
  5. Maghrib - 07:22 PM
  6. Isha - 08:44 PM

### Prayer Timer Implementation
**File**: [lib/features/home/view/widgets/prayer_time_card.dart](lib/features/home/view/widgets/prayer_time_card.dart)
- `_formatTime(Duration)` method:
  ```dart
  String _formatTime(Duration duration) {
    int minutes = duration.inMinutes;
    int seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  ```
- Displays remaining time until next prayer
- Currently hardcoded with mock data: "2 mins 45 secs"

### Recommended Prayer Time Model Structure
```dart
class PrayerTiming {
  final String name;
  final DateTime startTime;
  final DateTime endTime;
  final Duration iqamaTime;  // Congregation time offset
  final bool isJamaah;       // If congregation prayer
  final DateTime nextPrayerTime;  // For calculating countdown
}
```

---

## 3. STATE MANAGEMENT & REPOSITORY PATTERNS

### Architecture Used
- **Framework**: `flutter_bloc: ^9.1.1`
- **Pattern**: Cubit-based state management
- **Observer**: [lib/app_bloc_observer.dart](lib/app_bloc_observer.dart)

### Implemented Example: Bottom Navigation Bar
**Files**:
- [lib/features/bottom_nav_bar/cubit/bottom_nav_bar_cubit/bottom_nav_bar_cubit.dart](lib/features/bottom_nav_bar/cubit/bottom_nav_bar_cubit/bottom_nav_bar_cubit.dart)
- [lib/features/bottom_nav_bar/cubit/bottom_nav_bar_cubit/bottom_nav_bar_state.dart](lib/features/bottom_nav_bar/cubit/bottom_nav_bar_cubit/bottom_nav_bar_state.dart)

**Pattern Implementation**:
```dart
class BottomNavBarCubit extends Cubit<BottomNavBarState> {
  BottomNavBarCubit() : super(InitialBottomNavBarIndexState());
  
  int currentIndex = 0;
  List<Widget> screens = [...];
  
  void ChangeIndex(int index) {
    currentIndex = index;
    emit(ChangeBottomNavBarIndexState());
  }
}
```

**State Class**:
```dart
abstract class BottomNavBarState {}
class ChangeBottomNavBarIndexState extends BottomNavBarState {}
class InitialBottomNavBarIndexState extends BottomNavBarState {}
```

**Usage in Widget**:
```dart
BlocProvider(
  create: (context) => BottomNavBarCubit(),
  child: BlocBuilder<BottomNavBarCubit, BottomNavBarState>(
    builder: (context, state) {
      return Scaffold(
        body: context.read<BottomNavBarCubit>().screens[currentIndex],
        bottomNavigationBar: GNav(
          onTabChange: (index) {
            context.read<BottomNavBarCubit>().ChangeIndex(index);
          },
        ),
      );
    },
  ),
)
```

### Empty Repository Scaffolds
Following the same pattern but not yet implemented:
- [lib/features/home/model/home_repo.dart](lib/features/home/model/home_repo.dart) (empty)
- [lib/features/mosque_search/viewmodels/mosque_search_viewmodel.dart](lib/features/mosque_search/viewmodels/mosque_search_viewmodel.dart) (empty)
- [lib/features/prayer_times/repo/prayer_times_repo.dart](lib/features/prayer_times/repo/prayer_times_repo.dart) (empty)
- [lib/features/favorite/repo/favorite_viewmodel.dart](lib/features/favorite/repo/favorite_viewmodel.dart) (empty)

### Recommended Repository Pattern for Prayer Times
```dart
class PrayerTimesRepository {
  final Dio client;
  
  PrayerTimesRepository({required this.client});
  
  Future<List<PrayerTiming>> getPrayerTimes({
    required double latitude,
    required double longitude,
    required DateTime date,
  }) async {
    try {
      final response = await client.get(endpoint, queryParameters: {
        'lat': latitude,
        'lng': longitude,
        'date': date.toString(),
      });
      return (response.data as List)
          .map((p) => PrayerTiming.fromJson(p))
          .toList();
    } on DioException catch (e) {
      throw ServerFailure.fromDioError(e);
    }
  }
}
```

### Recommended Cubit Pattern for Prayer Times
```dart
class PrayerTimesCubit extends Cubit<PrayerTimesState> {
  final PrayerTimesRepository repository;
  
  PrayerTimesCubit({required this.repository})
      : super(PrayerTimesInitial());
  
  Future<void> fetchPrayerTimes({
    required double lat,
    required double lng,
  }) async {
    emit(PrayerTimesLoading());
    try {
      final timings = await repository.getPrayerTimes(
        latitude: lat,
        longitude: lng,
        date: DateTime.now(),
      );
      emit(PrayerTimesLoaded(timings));
    } on Failure catch (e) {
      emit(PrayerTimesError(e.errmessage));
    }
  }
}
```

---

## 4. NETWORKING & API CONSUMER PATTERN

### Network Setup
**Files**:
- [lib/core/network/dio_helper.dart](lib/core/network/dio_helper.dart)
- [lib/core/network/endpoint_constants.dart](lib/core/network/endpoint_constants.dart)
- [lib/core/network/api_consumer.dart](lib/core/network/api_consumer.dart) (interface, commented out)

### DioHelper Implementation
```dart
class DioHelper {
  static late Dio dio;
  static init() {
    dio = Dio(
      BaseOptions(
        baseUrl: EndpointConstants.baseUrl,
        receiveDataWhenStatusError: true,
        connectTimeout: const Duration(seconds: 50),
        receiveTimeout: const Duration(seconds: 50),
        headers: {"Content-Type": "application/json"},
      ),
    );
  }

  static Future<Response> getData({
    required String endpoint,
    Map<String, dynamic>? queryParameters,
  }) async {
    final res = await dio.get(endpoint, queryParameters: queryParameters);
    return res;
  }
}
```

### Google Places API Integration
**File**: [lib/core/network/endpoint_constants.dart](lib/core/network/endpoint_constants.dart)
- **Base URL**: `https://maps.googleapis.com/maps/api/place`
- **Endpoint**: `/nearbysearch/json`
- **API Key**: `AIzaSyCn2_UWt0RFlO2r83-KXR2kVuIsiukMRJ4` (exposed - consider using secure method)
- **Photo URL Function**: `placePhotoUrl(String photoReference, {int maxWidth = 400})`

### Backend Services
- **Supabase**: [lib/core/network/supabase_service.dart](lib/core/network/supabase_service.dart)
  - URL: `https://xndpsfzvotlegrtnfanf.supabase.co`
  - Public Key: `sb_publishable_2dAVgqQoQuT7iy5HcVY-XA__ygO3nwG` (exposed - should be secured)

---

## 5. DATE/TIME UTILITIES & FUNCTIONS

### Core Utilities
**File**: [lib/core/utils/app_utils.dart](lib/core/utils/app_utils.dart)

**Available Methods**:
- `isEmailValid(String email)` - Email validation
- `hasLowerCase(String password)` - Password lowercase check
- `hasUpperCase(String password)` - Password uppercase check
- `hasNumber(String password)` - Password number check
- `hasMinLength(String password)` - 8+ character minimum

### String Extension
**File**: [lib/core/extensions/string_extension.dart](lib/core/extensions/string_extension.dart)
```dart
extension TextLimit on String {
  String limit(int maxChars) {
    return length <= maxChars ? this : "${substring(0, maxChars)}...";
  }
}
// Usage: "long text".limit(20)
```

### Prayer Time Formatting
**File**: [lib/features/home/view/widgets/prayer_time_card.dart](lib/features/home/view/widgets/prayer_time_card.dart)
```dart
String _formatTime(Duration duration) {
  int minutes = duration.inMinutes;
  int seconds = duration.inSeconds.remainder(60);
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  // Output format: "MM:SS" e.g., "02:45"
}
```

### Distance Formatting
**File**: [lib/features/mosque_search/models/mosque_model.dart](lib/features/mosque_search/models/mosque_model.dart)
```dart
String get distanceLabel {
  if (distanceMeters < 1000) {
    return '${distanceMeters.toInt()} m';
  }
  return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
  // Output: "500 m" or "2.5 km"
}
```

### Recommended Date/Time Utilities to Add
```dart
class DateTimeUtils {
  /// Format time to HH:MM AM/PM
  static String formatTimeOfDay(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  /// Calculate remaining time until next prayer
  static Duration getTimeUntilPrayer(DateTime prayerTime) {
    return prayerTime.difference(DateTime.now());
  }

  /// Format Duration to human-readable string
  static String formatDuration(Duration d) {
    if (d.inMinutes < 1) return '${d.inSeconds}s';
    return '${d.inMinutes}m ${d.inSeconds.remainder(60)}s';
  }

  /// Check if current time is within prayer window
  static bool isWithinPrayerWindow(
    DateTime start,
    DateTime end,
  ) {
    final now = DateTime.now();
    return now.isAfter(start) && now.isBefore(end);
  }
}
```

### SharedPreferences Pattern
**File**: [lib/core/utils/app_shared_preferences.dart](lib/core/utils/app_shared_preferences.dart) (commented out template)
- Singleton pattern with generic data storage
- Support for String, int, double, bool, List<String>
- Model serialization with toJson/fromJson

---

## 6. ERROR HANDLING PATTERNS

### Error Hierarchy

#### Failure Classes
**File**: [lib/core/errors/failures.dart](lib/core/errors/failures.dart)
```dart
abstract class Failure {
  final String message;
  final int statusCode;
  Failure(this.message, this.statusCode);
}

class ServerFailure extends Failure {
  ServerFailure([super.message = 'Server Error', super.statusCode = 500]);
}

class CacheFailure extends Failure {
  CacheFailure([super.message = 'Cache Error', super.statusCode = 500]);
}
```

#### Exception Classes
**File**: [lib/core/errors/exceptions.dart](lib/core/errors/exceptions.dart)
```dart
abstract class Failure implements Exception {
  final String errmessage;
  Failure(this.errmessage);
}

class ServerFailure extends Failure {
  ServerFailure(super.errmessage);

  /// Converts DioException to ServerFailure
  factory ServerFailure.fromDioError(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
        return ServerFailure('connection Time Out With Api Server');
      case DioExceptionType.sendTimeout:
        return ServerFailure('Time Out with Api Server');
      case DioExceptionType.receiveTimeout:
        return ServerFailure('Time Out with Api Server');
      case DioExceptionType.badResponse:
        return ServerFailure.fromResponse(
          dioError.response?.statusCode,
          dioError.response?.data,
        );
      case DioExceptionType.cancel:
        return ServerFailure('Request to Api Server was Cancelled');
      case DioExceptionType.unknown:
        return ServerFailure('No Internet Connection');
      default:
        return ServerFailure('Opps There was an Error Please try again later');
    }
  }

  /// Handle HTTP status codes
  factory ServerFailure.fromResponse(int? statusCode, dynamic response) {
    if (statusCode == 400 || statusCode == 401 || 
        statusCode == 403 || statusCode == 422) {
      return ServerFailure(response['message'] ?? ['Bad Request']);
    } else if (statusCode == 404) {
      return ServerFailure("Not Found");
    } else if (statusCode == 500) {
      return ServerFailure("Internal Server Error");
    } else {
      return ServerFailure("Opps There was an Error Please try again later");
    }
  }
}
```

### Error Display
**File**: [lib/core/functions/snakebar_function.dart](lib/core/functions/snakebar_function.dart)
```dart
void snackBarMessage({required context, required text}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(text))
  );
}
```

### BlocObserver for Debugging
**File**: [lib/app_bloc_observer.dart](lib/app_bloc_observer.dart)
```dart
class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    print('🔍 Bloc Created: ${bloc.runtimeType}');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('🔁 Bloc Change in ${bloc.runtimeType}: $change');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('❌ Bloc Error in ${bloc.runtimeType}: $error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    print('🛑 Bloc Closed: ${bloc.runtimeType}');
    super.onClose(bloc);
  }
}
```

### Recommended Try-Catch Pattern for Features
```dart
Future<void> getPrayerTimesWithErrorHandling() async {
  emit(PrayerTimesLoading());
  try {
    final timings = await repository.getPrayerTimes(lat, lng);
    emit(PrayerTimesLoaded(timings));
  } on ServerFailure catch (e) {
    emit(PrayerTimesError(
      'Server Error: ${e.errmessage}',
      isNetworkError: e.errmessage.contains('Internet'),
    ));
  } on CacheFailure catch (e) {
    emit(PrayerTimesError('Cache Error: ${e.errmessage}'));
  } catch (e) {
    emit(PrayerTimesError('Unexpected Error: $e'));
  }
}
```

---

## 7. PROJECT STRUCTURE & CONVENTIONS

### Folder Organization
```
lib/
├── features/              # Feature-based modules
│   ├── home/             # Home feature (implemented)
│   ├── prayer_times/     # Prayer times feature (scaffold)
│   ├── mosque_search/    # Mosque search feature (scaffold)
│   ├── favorite/         # Favorites feature (scaffold)
│   ├── mosque_details/   # Mosque details (scaffold)
│   ├── more/             # More options (scaffold)
│   └── bottom_nav_bar/   # Navigation (implemented)
├── core/                  # Core utilities & services
│   ├── constants/        # Colors, strings, endpoints
│   ├── errors/           # Error handling (Failure, Exception)
│   ├── extensions/       # String extensions
│   ├── functions/        # Helper functions (SnackBar)
│   ├── network/          # Dio, Supabase, API setup
│   ├── routing/          # Navigation routes
│   ├── theme/            # App theme & text styles
│   ├── utils/            # Validation & preferences
│   └── widgets/          # Reusable widgets
├── app.dart              # Main app setup
├── main.dart             # Entry point
└── app_bloc_observer.dart # Bloc logging
```

### Naming Conventions
- **Cubits**: `{Feature}Cubit` (e.g., `BottomNavBarCubit`)
- **States**: `{Feature}State` abstract class + specific states (e.g., `ChangeBottomNavBarIndexState`)
- **Repositories**: `{Feature}Repository` (pattern established)
- **Models**: `{Feature}Model` (e.g., `PrayerModel`, `MosqueModel`)
- **Screens**: `{Feature}Screen` (e.g., `HomeScreen`)
- **Widgets**: Descriptive names (e.g., `PrayerTimerCard`, `PrayerScheduleSection`)

### Responsive Design
- **Package**: `flutter_screenutil: ^5.9.3`
- **Design Size**: 390 × 911 (mobile)
- **Usage**: `.w` for width, `.h` for height, `.sp` for font size
  ```dart
  width: 220.w,           // Width responsive
  height: 240.h,          // Height responsive
  fontSize: 48.sp,        // Font size responsive
  ```

---

## 8. DEPENDENCIES SUMMARY

```yaml
dependencies:
  flutter:
    sdk: flutter
  dio: ^5.9.2                    # HTTP client
  flutter_bloc: ^9.1.1           # State management
  flutter_screenutil: ^5.9.3     # Responsive design
  geolocator: ^14.0.2            # Location services (not yet utilized)
  google_nav_bar: ^5.0.7         # Bottom navigation UI
  hive_flutter: ^1.1.0           # Local database (partial setup)
  supabase_flutter: ^2.12.4      # Backend services
```

---

## 9. NOTES FOR DEVELOPMENT

### Security Concerns ⚠️
- Google Places API key exposed in code: `AIzaSyCn2_UWt0RFlO2r83-KXR2kVuIsiukMRJ4`
- Supabase public key exposed: `sb_publishable_2dAVgqQoQuT7iy5HcVY-XA__ygO3nwG`
- **Recommendation**: Move to environment variables or secure configuration

### Empty Implementations
- Prayer times feature (models, repo, views)
- Mosque search viewmodel
- Home repository
- All favorite/mosque details repos
- API consumer interface (commented out)

### Mock Data
- Prayer times are hardcoded in widgets
- Timer uses static Duration values
- Need integration with actual API

### Testing Setup
- No tests configured yet
- `flutter_test` in dev dependencies but no test files present

---

## 10. QUICK REFERENCE: KEY FILE LOCATIONS

| Component | File | Status |
|-----------|------|--------|
| **Bloc Observer** | [app_bloc_observer.dart](lib/app_bloc_observer.dart) | ✅ Implemented |
| **Error Handling** | [errors/exceptions.dart](lib/core/errors/exceptions.dart) | ✅ Implemented |
| **Failures** | [errors/failures.dart](lib/core/errors/failures.dart) | ✅ Implemented |
| **Dio Setup** | [network/dio_helper.dart](lib/core/network/dio_helper.dart) | ✅ Implemented |
| **Supabase** | [network/supabase_service.dart](lib/core/network/supabase_service.dart) | ✅ Implemented |
| **Bottom Nav** | [features/bottom_nav_bar/](lib/features/bottom_nav_bar/) | ✅ Implemented |
| **Home Screen** | [features/home/view/home_screen.dart](lib/features/home/view/home_screen.dart) | ✅ Implemented |
| **Prayer Times** | [features/prayer_times/](lib/features/prayer_times/) | ⏳ Scaffold only |
| **Mosque Search** | [features/mosque_search/](lib/features/mosque_search/) | ⏳ Scaffold only |
| **Routing** | [core/routing/app_router.dart](lib/core/routing/app_router.dart) | ✅ Basic setup |
| **Theme** | [core/theme/app_theme.dart](lib/core/theme/app_theme.dart) | ✅ Implemented |
| **Utils** | [core/utils/app_utils.dart](lib/core/utils/app_utils.dart) | ✅ Validation methods |


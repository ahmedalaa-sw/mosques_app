# Implementation Examples & Use Cases

## Table of Contents
1. [Basic Implementation](#basic-implementation)
2. [Advanced Configurations](#advanced-configurations)
3. [UI Integration Examples](#ui-integration-examples)
4. [Testing Examples](#testing-examples)
5. [Real-World Scenarios](#real-world-scenarios)

---

## Basic Implementation

### Example 1: Get Prayer Times for Current Location
```dart
// In HomeCubit or HomeRepository
Future<AladhanPrayerTimesModel> getPrayerTimesForCurrentLocation() async {
  try {
    // Get current device location
    final position = await GeolocationService.getCurrentLocation();
    
    // Calculate prayer times offline
    final prayerTimes = AdhanPrayerService.calculatePrayerTimes(
      latitude: position.latitude,
      longitude: position.longitude,
    );
    
    // Convert to model
    final model = AladhanPrayerTimesModel.fromAdhanPrayerTimes(
      prayerTimes: prayerTimes,
      latitude: position.latitude,
      longitude: position.longitude,
      methodName: 'Muslim World League',
      schoolName: 'Shafi',
    );
    
    return model;
  } catch (e) {
    throw Exception('Failed to get prayer times: $e');
  }
}
```

### Example 2: Get Prayer Times for a Specific City
```dart
Future<AladhanPrayerTimesModel> getPrayerTimesForCity(String cityName) async {
  // City coordinates mapping
  const cities = {
    'London': {'lat': 51.5074, 'lng': -0.1278},
    'Cairo': {'lat': 30.0444, 'lng': 31.2357},
    'Dubai': {'lat': 25.2048, 'lng': 55.2708},
    'New York': {'lat': 40.7128, 'lng': -74.0060},
    'Tokyo': {'lat': 35.6762, 'lng': 139.6503},
    'Sydney': {'lat': -33.8688, 'lng': 151.2093},
  };
  
  final coords = cities[cityName];
  if (coords == null) throw Exception('City not found');
  
  final prayerTimes = AdhanPrayerService.calculatePrayerTimes(
    latitude: coords['lat']!,
    longitude: coords['lng']!,
  );
  
  return AladhanPrayerTimesModel.fromAdhanPrayerTimes(
    prayerTimes: prayerTimes,
    latitude: coords['lat']!,
    longitude: coords['lng']!,
    methodName: 'Muslim World League',
    schoolName: 'Shafi',
  );
}
```

---

## Advanced Configurations

### Example 3: User-Configurable Calculation Methods
```dart
// In a Settings Provider or Repository
class PrayerSettingsProvider {
  static const String _calculationMethodKey = 'calculation_method';
  static const String _madhabKey = 'madhab';
  
  Future<void> setCalculationMethod(CalculationMethod method) async {
    AdhanPrayerService.setCalculationMethod(method);
    
    // Save to preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_calculationMethodKey, method.toString());
  }
  
  Future<void> setMadhab(Madhab madhab) async {
    AdhanPrayerService.setMadhab(madhab);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_madhabKey, madhab.toString());
  }
  
  Future<void> loadUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load calculation method
    final methodStr = prefs.getString(_calculationMethodKey);
    if (methodStr != null) {
      final method = _stringToCalculationMethod(methodStr);
      AdhanPrayerService.setCalculationMethod(method);
    }
    
    // Load madhab
    final madhabStr = prefs.getString(_madhabKey);
    if (madhabStr != null) {
      final madhab = _stringToMadhab(madhabStr);
      AdhanPrayerService.setMadhab(madhab);
    }
  }
  
  CalculationMethod _stringToCalculationMethod(String str) {
    return CalculationMethod.muslimWorldLeague; // Simplified
  }
  
  Madhab _stringToMadhab(String str) {
    return Madhab.shafii;
  }
}

// Usage in main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load user preferences before running app
  final settingsProvider = PrayerSettingsProvider();
  await settingsProvider.loadUserPreferences();
  
  runApp(const MyApp());
}
```

### Example 4: Region-Specific Defaults
```dart
// Auto-select calculation method based on device location
Future<void> initializeWithRegionalDefaults() async {
  try {
    final position = await GeolocationService.getCurrentLocation();
    final region = getRegionFromCoordinates(position.latitude, position.longitude);
    
    switch (region) {
      case Region.northAmerica:
        AdhanPrayerService.setCalculationMethod(CalculationMethod.northAmerica);
      case Region.middleEast:
        AdhanPrayerService.setCalculationMethod(CalculationMethod.ummAlQura);
      case Region.egypt:
        AdhanPrayerService.setCalculationMethod(CalculationMethod.egyptian);
      case Region.southAsia:
        AdhanPrayerService.setCalculationMethod(CalculationMethod.karachi);
      default:
        AdhanPrayerService.setCalculationMethod(CalculationMethod.muslimWorldLeague);
    }
  } catch (e) {
    // Fallback to default
    AdhanPrayerService.setCalculationMethod(CalculationMethod.muslimWorldLeague);
  }
}

enum Region { northAmerica, middleEast, egypt, southAsia, other }

Region getRegionFromCoordinates(double lat, double lng) {
  if (lat > 15 && lat < 50 && lng > -125 && lng < -66) {
    return Region.northAmerica;
  }
  // Add more region logic...
  return Region.other;
}
```

---

## UI Integration Examples

### Example 5: Settings Screen for Prayer Configuration
```dart
class PrayerSettingsScreen extends StatefulWidget {
  @override
  State<PrayerSettingsScreen> createState() => _PrayerSettingsScreenState();
}

class _PrayerSettingsScreenState extends State<PrayerSettingsScreen> {
  late CalculationMethod selectedMethod;
  late Madhab selectedMadhab;
  
  @override
  void initState() {
    super.initState();
    final config = AdhanPrayerService.getCurrentConfig();
    selectedMethod = config.calculationMethod;
    selectedMadhab = config.madhab;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Prayer Calculation Settings')),
      body: ListView(
        children: [
          // Calculation Method Section
          ListTile(
            title: Text('Calculation Method'),
            subtitle: Text(_getMethodName(selectedMethod)),
          ),
          ...AdhanPrayerService.getAvailableCalculationMethods().map(
            (methodInfo) => RadioListTile<CalculationMethod>(
              title: Text(methodInfo.name),
              subtitle: Text(methodInfo.description),
              value: methodInfo.method,
              groupValue: selectedMethod,
              onChanged: (method) {
                if (method != null) {
                  setState(() => selectedMethod = method);
                  AdhanPrayerService.setCalculationMethod(method);
                  // Refresh prayer times
                  context.read<HomeCubit>().refreshPrayerTimes();
                }
              },
            ),
          ),
          
          Divider(),
          
          // Madhab Section
          ListTile(
            title: Text('Prayer School (Madhab)'),
            subtitle: Text(_getMadhabName(selectedMadhab)),
          ),
          ...AdhanPrayerService.getAvailableMadhabs().map(
            (madhabInfo) => RadioListTile<Madhab>(
              title: Text(madhabInfo.name),
              subtitle: Text(madhabInfo.description),
              value: madhabInfo.madhab,
              groupValue: selectedMadhab,
              onChanged: (madhab) {
                if (madhab != null) {
                  setState(() => selectedMadhab = madhab);
                  AdhanPrayerService.setMadhab(madhab);
                  // Refresh prayer times
                  context.read<HomeCubit>().refreshPrayerTimes();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
  
  String _getMethodName(CalculationMethod method) => method.toString().split('.').last;
  String _getMadhabName(Madhab madhab) => madhab.toString().split('.').last;
}
```

### Example 6: Prayer Times Display with Current Highlight
```dart
class PrayerTimeCard extends StatelessWidget {
  final PrayerModel prayer;
  
  const PrayerTimeCard({required this.prayer});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      color: prayer.isHighlighted ? Colors.green : Colors.grey[800],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              prayer.icon,
              color: prayer.isHighlighted ? Colors.white : Colors.grey,
              size: 32,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prayer.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    prayer.time,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[300],
                    ),
                  ),
                ],
              ),
            ),
            if (prayer.isHighlighted)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Now',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

---

## Testing Examples

### Example 7: Unit Test for Prayer Time Calculation
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mosques_app/core/services/adhan_prayer_service.dart';
import 'package:mosques_app/features/home/model/home_model.dart';

void main() {
  group('AdhanPrayerService', () {
    test('Calculate prayer times for London', () {
      final prayerTimes = AdhanPrayerService.calculatePrayerTimes(
        latitude: 51.5074,
        longitude: -0.1278,
        date: DateTime(2024, 5, 2),
      );
      
      expect(prayerTimes.fajr, isNotNull);
      expect(prayerTimes.dhuhr, isNotNull);
      expect(prayerTimes.asr, isNotNull);
      expect(prayerTimes.maghrib, isNotNull);
      expect(prayerTimes.isha, isNotNull);
    });
    
    test('Prayer times are in chronological order', () {
      final prayerTimes = AdhanPrayerService.calculatePrayerTimes(
        latitude: 51.5074,
        longitude: -0.1278,
      );
      
      expect(prayerTimes.fajr.isBefore(prayerTimes.sunrise), true);
      expect(prayerTimes.sunrise.isBefore(prayerTimes.dhuhr), true);
      expect(prayerTimes.dhuhr.isBefore(prayerTimes.asr), true);
      expect(prayerTimes.asr.isBefore(prayerTimes.maghrib), true);
      expect(prayerTimes.maghrib.isBefore(prayerTimes.isha), true);
    });
    
    test('Different calculation methods produce different results', () {
      AdhanPrayerService.setCalculationMethod(CalculationMethod.muslimWorldLeague);
      final times1 = AdhanPrayerService.calculatePrayerTimes(
        latitude: 40.7128,
        longitude: -74.0060,
      );
      
      AdhanPrayerService.setCalculationMethod(CalculationMethod.northAmerica);
      final times2 = AdhanPrayerService.calculatePrayerTimes(
        latitude: 40.7128,
        longitude: -74.0060,
      );
      
      // Methods should produce different Fajr times
      expect(times1.fajr != times2.fajr, true);
    });
  });
}
```

### Example 8: Widget Test for Prayer Times Display
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mosques_app/features/home/view/home_screen.dart';

void main() {
  group('HomeScreen Prayer Times', () {
    testWidgets('Display prayer times after loading', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      // Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Verify prayer times are displayed
      expect(find.text('Fajr'), findsOneWidget);
      expect(find.text('Dhuhr'), findsOneWidget);
      expect(find.text('Asr'), findsOneWidget);
      expect(find.text('Maghrib'), findsOneWidget);
      expect(find.text('Isha'), findsOneWidget);
    });
    
    testWidgets('Highlight current prayer', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      
      // Find highlighted prayer card
      final highlightedPrayers = find.byWidgetPredicate(
        (widget) => widget is Card && 
                   (widget.color?.value ?? 0) > Colors.grey[800]!.value,
      );
      
      // Should have at most one highlighted prayer
      expect(highlightedPrayers, findsWidgets);
    });
    
    testWidgets('Refresh prayer times on button tap', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      
      // Tap refresh button
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();
      
      // Prayer times should still be visible
      expect(find.text('Fajr'), findsOneWidget);
    });
  });
}
```

---

## Real-World Scenarios

### Example 9: Offline Prayer Times with Cached Location
```dart
// Repository that caches location for offline use
class OfflineAwarePrayerRepository {
  static const String _cachedLatKey = 'cached_latitude';
  static const String _cachedLngKey = 'cached_longitude';
  
  final SharedPreferences prefs;
  
  Future<AladhanPrayerTimesModel> getPrayerTimes() async {
    try {
      // Try to get current location
      final position = await GeolocationService.getCurrentLocation();
      
      // Save for offline use
      await prefs.setDouble(_cachedLatKey, position.latitude);
      await prefs.setDouble(_cachedLngKey, position.longitude);
      
      return _calculateAndReturn(position.latitude, position.longitude);
    } catch (e) {
      // Fall back to cached location
      final cachedLat = prefs.getDouble(_cachedLatKey);
      final cachedLng = prefs.getDouble(_cachedLngKey);
      
      if (cachedLat != null && cachedLng != null) {
        return _calculateAndReturn(cachedLat, cachedLng);
      }
      
      rethrow;
    }
  }
  
  Future<AladhanPrayerTimesModel> _calculateAndReturn(
    double latitude,
    double longitude,
  ) async {
    final prayerTimes = AdhanPrayerService.calculatePrayerTimes(
      latitude: latitude,
      longitude: longitude,
    );
    
    return AladhanPrayerTimesModel.fromAdhanPrayerTimes(
      prayerTimes: prayerTimes,
      latitude: latitude,
      longitude: longitude,
      methodName: 'Muslim World League',
      schoolName: 'Shafi',
    );
  }
}
```

### Example 10: Prayer Time Notifications
```dart
// Notifier for prayer times
class PrayerNotificationService {
  static const channelId = 'prayer_times';
  static const channelName = 'Prayer Time Notifications';
  
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  
  Future<void> scheduleNotifications(AladhanPrayerTimesModel prayerTimes) async {
    final prayers = [
      ('Fajr', prayerTimes.fajr),
      ('Dhuhr', prayerTimes.dhuhr),
      ('Asr', prayerTimes.asr),
      ('Maghrib', prayerTimes.maghrib),
      ('Isha', prayerTimes.isha),
    ];
    
    for (var (name, time) in prayers) {
      final timeOfDay = TimeOfDay.fromString(time);
      final now = DateTime.now();
      final scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        timeOfDay.hour,
        timeOfDay.minute,
      );
      
      // If time has passed today, schedule for tomorrow
      final finalDate = scheduledDate.isBefore(now)
          ? scheduledDate.add(Duration(days: 1))
          : scheduledDate;
      
      await flutterLocalNotificationsPlugin.zonedSchedule(
        name.hashCode,
        'Time for $name',
        'It\\'s time for $name prayer',
        tz.TZDateTime.from(finalDate, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(channelId, channelName),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }
  
  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}

// Usage
final notificationService = PrayerNotificationService(
  flutterLocalNotificationsPlugin: FlutterLocalNotificationsPlugin(),
);

// In HomeCubit when prayer times loaded
await notificationService.scheduleNotifications(prayerTimes);
```

### Example 11: Multi-Day Prayer Calendar
```dart
// Fetch prayer times for the entire week
Future<List<AladhanPrayerTimesModel>> getWeeklyPrayerTimes(
  double latitude,
  double longitude,
) async {
  final List<AladhanPrayerTimesModel> weeklyTimes = [];
  
  for (int i = 0; i < 7; i++) {
    final date = DateTime.now().add(Duration(days: i));
    
    final prayerTimes = AdhanPrayerService.calculatePrayerTimes(
      latitude: latitude,
      longitude: longitude,
      date: date,
    );
    
    final model = AladhanPrayerTimesModel.fromAdhanPrayerTimes(
      prayerTimes: prayerTimes,
      latitude: latitude,
      longitude: longitude,
      methodName: 'Muslim World League',
      schoolName: 'Shafi',
    );
    
    weeklyTimes.add(model);
  }
  
  return weeklyTimes;
}

// UI Widget
class WeeklyPrayerCalendar extends StatelessWidget {
  final List<AladhanPrayerTimesModel> weeklyTimes;
  
  const WeeklyPrayerCalendar({required this.weeklyTimes});
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: weeklyTimes.length,
      itemBuilder: (context, index) {
        final dayTimes = weeklyTimes[index];
        final dayName = _getDayName(dayTimes.date);
        
        return ExpansionTile(
          title: Text('$dayName - ${dayTimes.date.toString().split(' ')[0]}'),
          children: [
            PrayerTimeCard(
              prayer: PrayerModel(
                name: 'Fajr',
                time: dayTimes.fajr,
                icon: Icons.wb_twilight,
              ),
            ),
            // Add other prayers...
          ],
        );
      },
    );
  }
  
  String _getDayName(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }
}
```

---

These examples demonstrate the flexibility and power of the new `adhan_dart` integration while maintaining the existing architecture and UI structure.

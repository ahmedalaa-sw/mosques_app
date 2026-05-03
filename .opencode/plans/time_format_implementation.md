# Time Format 12h/24h Implementation Plan

## Overview
Listen to phone's system time format setting (12h vs 24h) and update all time displays dynamically without app restart.

---

## Step 1: Create TimeFormatCubit + state

### `lib/core/cubit/time_format_state.dart`
```dart
class TimeFormatState {
  final bool is24Hour;
  const TimeFormatState({required this.is24Hour});
}
```

### `lib/core/cubit/time_format_cubit.dart`
```dart
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'time_format_state.dart';

class TimeFormatCubit extends Cubit<TimeFormatState> {
  TimeFormatCubit() : super(TimeFormatState(is24Hour: _currentFormat()));

  VoidCallback? _previousConfigCallback;

  static bool _currentFormat() =>
      PlatformDispatcher.instance.alwaysUse24HourFormat;

  void init() {
    _previousConfigCallback =
        PlatformDispatcher.instance.onPlatformConfigurationChanged;
    PlatformDispatcher.instance.onPlatformConfigurationChanged = () {
      _previousConfigCallback?.call();
      final newFormat = _currentFormat();
      if (newFormat != state.is24Hour) {
        emit(TimeFormatState(is24Hour: newFormat));
      }
    };
  }

  @override
  Future<void> close() {
    PlatformDispatcher.instance.onPlatformConfigurationChanged =
        _previousConfigCallback;
    return super.close();
  }
}
```

---

## Step 2: Create time format helper utility

### `lib/core/extensions/time_format_helper.dart`
```dart
class TimeFormatHelper {
  /// Converts "HH:mm" string to display format based on [use24Hour].
  static String format(String hhmm, bool use24Hour) {
    final parts = hhmm.split(':');
    if (parts.length < 2) return hhmm;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = parts[1];
    if (use24Hour) {
      return '${h.toString().padLeft(2, '0')}:$m';
    }
    final period = h < 12 ? 'AM' : 'PM';
    final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$h12:$m $period';
  }
}
```

---

## Step 3: Provide cubit at app level

### `lib/app.dart` — changes:
1. Add imports:
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/cubit/time_format_cubit.dart';
```
2. Uncomment the commented-out BlocProvider block and wrap MaterialApp:
```dart
return ScreenUtilInit(
  designSize: const Size(390, 911),
  minTextAdapt: true,
  splitScreenMode: true,
  builder: (context, child) {
    return BlocProvider(
      create: (_) => TimeFormatCubit()..init(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateRoute: appRouter.generateRoute,
        initialRoute: Routes.bottomNavScreen,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.system,
      ),
    );
  },
);
```

---

## Step 4: Update PrayerCountdownSection

### `lib/features/home/view/widgets/prayer_countdown_section.dart` — changes:
1. Add imports:
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosques_app/core/cubit/time_format_cubit.dart';
import 'package:mosques_app/core/cubit/time_format_state.dart';
import 'package:mosques_app/core/extensions/time_format_helper.dart';
```
2. Replace `_to12Hour(...)` calls in `build()`:
```dart
// Before:
time: _to12Hour(widget.prayerTimes.sunrise),
time: _to12Hour(widget.prayerTimes.maghrib),

// After:
time: TimeFormatHelper.format(
  widget.prayerTimes.sunrise,
  context.watch<TimeFormatCubit>().state.is24Hour,
),
time: TimeFormatHelper.format(
  widget.prayerTimes.maghrib,
  context.watch<TimeFormatCubit>().state.is24Hour,
),
```
3. Remove the `_to12Hour(String t)` method entirely.

---

## Step 5: Update PrayerScheduleSection

### `lib/features/home/view/widgets/prayer_schedule_section.dart` — changes:
1. Add imports:
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosques_app/core/cubit/time_format_cubit.dart';
import 'package:mosques_app/core/cubit/time_format_state.dart';
import 'package:mosques_app/core/extensions/time_format_helper.dart';
```

2. In `_PrayerRow.build()`, format `prayer.time` using the cubit:
```dart
// In _PrayerRow
@override
Widget build(BuildContext context) {
  final use24Hour = context.watch<TimeFormatCubit>().state.is24Hour;
  final formattedTime = TimeFormatHelper.format(prayer.time, use24Hour);
  final theme = prayer.isHighlighted
      ? _PrayerRowTheme.highlighted()
      : _PrayerRowTheme.normal();
  // ... rest of build, use formattedTime instead of prayer.time
```

---

## Step 6: Update PrayerTimesCard (mosque_details)

### `lib/features/mosque_details/views/widgets/prayer_times_card.dart` — changes:
1. Add imports:
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosques_app/core/cubit/time_format_cubit.dart';
import 'package:mosques_app/core/cubit/time_format_state.dart';
import 'package:mosques_app/core/extensions/time_format_helper.dart';
```

2. In `_PrayerTimeRow.build()`, format `time` using the cubit:
```dart
@override
Widget build(BuildContext context) {
  final use24Hour = context.watch<TimeFormatCubit>().state.is24Hour;
  return Row(
    children: [
      Icon(icon, size: 18.sp, color: AppColor.primaryColor.withValues(alpha: 0.7)),
      SizedBox(width: 12.w),
      Text(label, ...),
      const Spacer(),
      Text(
        TimeFormatHelper.format(time, use24Hour), // ← formatted
        style: ...,
      ),
    ],
  );
}
```

---

## Verification
After implementing all steps, run:
```bash
flutter build apk --debug
```
The build should succeed with no NDK or flutter_timezone errors, and all time displays will dynamically switch between 12h and 24h format based on the system setting.

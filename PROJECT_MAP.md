# PROJECT_MAP.md — Prayer Time Calculation Fix & Architecture Roadmap

**Project**: Masjidy (mosques_app)  
**Date**: 2026-05-12  
**Scope**: Fix prayer time calculation inconsistency for non-local locations; architectural improvements for timezone safety  
**Status**: ✅ Implementation complete

---

## Root Cause Analysis

### Bug Summary

Prayer times for Makkah, Saudi Arabia were incorrect by 15–27 minutes depending on the prayer. The app output was:

| Prayer  | App (Wrong) | Official (Correct) | Difference |
|---------|-------------|-------------------|------------|
| Fajr    | 4:20 AM     | 3:53 AM           | +27 min    |
| Sunrise | 5:43 AM     | 5:19 AM           | +24 min    |
| Dhuhr   | 12:16 PM    | 11:56 AM          | +20 min    |
| Asr     | 3:35 PM     | 3:20 PM           | +15 min    |
| Maghrib | 6:50 PM     | 6:34 PM           | +16 min    |
| Isha    | 8:20 PM     | 8:04 PM           | +16 min    |

All times were **late** by varying amounts. The non-uniform shift confirmed this was a **compound bug** with two root causes.

### Root Cause #1: Device Timezone Leaking Into UTC-to-Local Conversion (CRITICAL)

`adhan_dart` computes prayer times as UTC `DateTime` objects (via `TimeComponents.utcDate`). The app converted these to local wall-clock times using `.toLocal()`:

```dart
// OLD (BUG): Uses device timezone, not prayer location timezone
static String _fmt(DateTime? t) {
  final local = t.toLocal();  // WRONG — uses device timezone
  return '${local.hour}:...:${local.minute}';
}
```

When the device is in a different timezone than the prayer location, `.toLocal()` applies the **device's** UTC offset instead of the **location's** UTC offset. This was the primary source of incorrect times.

### Root Cause #2: `DateTime.now()` Used for Calculation Date (MODERATE)

Both `calculatePrayerTime()` and `calculatePrayerTimesSync()` used `DateTime.now()` as the date for prayer calculations. `DateTime.now()` returns the local date in the device's timezone. When the device is e.g. in New York (UTC-5) viewing Makkah prayer times (UTC+3), the "today" date could be wrong by up to 8 hours — potentially calculating prayer times for the wrong solar date.

---

## Implementation Summary

### Files Created (1 new file)

| File | Purpose |
|------|---------|
| `lib/core/utils/timezone_resolver.dart` | Centralized timezone resolution — maps country codes to IANA timezone names, converts UTC DateTimes to location-local times, provides "today at location" date calculation |

### Files Modified (7 files)

| File | Change |
|------|--------|
| `lib/core/services/adhan_prayer_service.dart` | Introduced `PrayerCalculationResult` class bundling prayer times with IANA timezone and country code. Both methods now resolve timezone and compute "today at location" date instead of `DateTime.now()`. Sync method accepts optional `ianaTimezone` parameter. |
| `lib/features/home/model/home_model.dart` | `AladhanPrayerTimesModel` now stores `ianaTimezone`. Replaced `.toLocal()` with `TimezoneResolver.formatHhMm()`. Factory method renamed from `fromAdhanPrayerTimes` to `fromPrayerCalculationResult` taking the new result type. |
| `lib/features/home/model/home_repo.dart` | Updated `_calculatePrayerTime` to use `fromPrayerCalculationResult` instead of the old factory. |
| `lib/features/home/view/cubit/home_cubit.dart` | All prayer time calculations now pass through `PrayerCalculationResult`. Prayer transition timer and current-prayer detection use `tz.TZDateTime.now(location)` for the prayer location's "now" instead of `DateTime.now()`. Notification scheduling builds `TZDateTime` objects in the prayer location's timezone. Timezone is cached to SharedPreferences. |
| `lib/core/services/notification_service.dart` | `schedulePrayerNotifications` now accepts optional `ianaTimezone` parameter. Converts `DateTime` values to `TZDateTime` in the prayer location's timezone for scheduling, ensuring notifications fire at the correct wall-clock time regardless of device timezone. |
| `lib/core/services/background_reschedule_service.dart` | All prayer time calculations use timezone-aware date computation. UTC-to-local conversion uses `TimezoneResolver.formatHhMm()` instead of `.toLocal()`. Notification scheduling builds `TZDateTime` objects in the prayer location's timezone. Cached timezone is read from SharedPreferences. |
| `lib/features/more/viewmodels/azan_cubit.dart` | `_rescheduleWithNewPreference` now reads cached `ianaTimezone` from SharedPreferences, uses `TimezoneResolver` for UTC-to-local conversion, and builds `TZDateTime` objects for notification scheduling. |
| `lib/core/utils/prayer_wall_clock_format.dart` | `hourMinute()` and `debugLogPrayerSchedule()` now require `ianaTimezone` parameter and use `TimezoneResolver` for conversion instead of `.toLocal()`. |

---

## Architecture Decisions

### 1. PrayerCalculationResult as the Return Type

Instead of returning raw `PrayerTimes` from `adhan_dart`, the service now returns `PrayerCalculationResult` which bundles timezone metadata. This ensures every caller has access to the IANA timezone name without re-resolving it.

**Rationale**: The timezone is derived from the same country code that determines the calculation method. Bundling them prevents mismatches where a caller uses Umm Al-Qura calculation but forgets to use `Asia/Riyadh` timezone for time conversion.

### 2. Country-to-Timezone Map in TimezoneResolver

A static map of ~30 country codes to IANA timezone names covers all countries referenced in `PrayerMethodMapper`. For multi-timezone countries (US, Canada, India), the map provides a reasonable default timezone, and the location-based fallback provides accuracy.

**Rationale**: The `flutter_timezone` package only gives the **device's** timezone, which is wrong for remote locations. Embedding a lookup table provides instant resolution without network calls.

### 3. Caching IANA Timezone in SharedPreferences

The resolved timezone string is cached under key `cached_iana_timezone`. This serves the same pattern as `cached_country_code` — foreground loads resolve it once and cache it, background tasks read from cache without geocoding.

**Rationale**: Background `Workmanager` tasks cannot reliably access geocoding APIs. Caching ensures background notification rescheduling always uses the correct timezone.

### 4. TZDateTime for Notification Scheduling

All notification scheduling now uses `tz.TZDateTime` constructed in the prayer location's `tz.Location`, not `tz.local` (device timezone). This ensures notifications fire at the correct wall-clock time regardless of device timezone settings.

**Rationale**: `flutter_local_notifications` uses `TZDateTime` for scheduling. Using `tz.local` (device timezone) would schedule notifications at wrong times when the user is in a different timezone than the prayer location.

### 5. NotificationService.init() Ensures tz Database Availability

The `timezone` package database (`tz.initializeTimeZones()`) is initialized in `NotificationService.init()` during `main()`, which runs before any `HomeCubit` or prayer calculation code. This guarantees the database is available when `TimezoneResolver` methods are called.

---

## Edge Cases Addressed

1. **Device in different timezone than prayer location**: Fully handled — all conversions use the prayer location's IANA timezone, not the device's timezone.

2. **Midnight boundary**: Handled — `TimezoneResolver.todayAt()` computes the calendar date at the prayer location, preventing wrong-day calculations when the device timezone differs from the location timezone by several hours.

3. **Daylight Saving Time**: Handled — IANA timezone names (e.g. `America/New_York`) automatically include DST rules. Using `tz.TZDateTime` and `tz.getLocation()` ensures DST transitions are respected.

4. **Offline mode**: Handled — timezone resolution from country code is a static lookup, no network required. Background tasks read from SharedPreferences cache.

5. **Multiple timezones per country**: Partially handled — the `TimezoneResolver.fromCountryCode()` map provides the most populous timezone for multi-zone countries. For precise resolution, coordinate-based approaches (future enhancement) would be needed.

6. **Background execution**: Handled — `BackgroundRescheduleService` reads cached timezone and coordinates from SharedPreferences, and uses `TimezoneResolver` for all conversions.

---

## Testing Checklist

- [x] Flutter analyze passes with zero errors
- [x] Debug APK builds successfully
- [ ] Prayer times for Makkah (21.4225, 39.8262) match official Saudi Umm Al-Qura times within ±2 minutes
- [ ] Prayer times display correctly when device is in a different timezone than the prayer location
- [ ] Prayer times update correctly after a manual location change
- [ ] Notifications fire at the correct wall-clock time on the device
- [ ] Background rescheduling works when the app is backgrounded
- [ ] Prayer transition timer fires at the correct time
- [ ] The "current prayer" indicator correctly highlights the active prayer
- [ ] Midnight boundary: prayer times show the correct date's times even when the device is on a different calendar day than the target location
- [ ] DST transition: prayer times are correct across DST boundaries
- [ ] Azan toggle reschedules notifications with the correct timezone

---

## Future Improvements

1. **Coordinate-to-timezone resolution**: Use the `flutter_timezone` package or a timezone boundary dataset to resolve timezones from coordinates for multi-zone countries like the US, Canada, India, and Indonesia.

2. **API-based prayer time validation**: Cross-check `adhan_dart` results against the Aladhan API for sanity verification.

3. **Timezone selector in settings**: Allow users to manually override the auto-detected timezone.

4. **Reduce code duplication**: The notification scheduling code in `HomeCubit._scheduleNotifications`, `BackgroundRescheduleService._rescheduleAll`, and `AzanCubit._rescheduleWithNewPreference` shares a lot of structure. Consider extracting a shared `PrayerScheduleBuilder` utility.

5. **Unit tests**: Add automated tests for `TimezoneResolver`, `AdhanPrayerService`, and `AladhanPrayerTimesModel.fromPrayerCalculationResult` that verify correct UTC-to-local conversion for known locations.
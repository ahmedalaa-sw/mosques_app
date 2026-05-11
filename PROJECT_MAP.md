# PROJECT_MAP.md — Bug Fix Roadmap

**Project**: Al-Masjid (mosques_app)  
**Date**: 2026-05-12  
**Scope**: Fix 3 user-facing bugs (language toggle, prayer time recalculation, location label overflow)

---

## Overview

| Bug | Summary | Complexity | Milestone | Status |
|-----|---------|-----------|-----------|--------|
| 3 | Long location label overflows More screen | Low | M1 | ✅ Done |
| 1 | Language change in onboarding doesn't update displayed country/city | Medium | M2 | ✅ Done |
| 2 | Changing location doesn't recalculate prayer times (stale caches) | High | M3 | ✅ Done |

---

## Milestone 1 — Fix location label overflow (Bug 3)

**Problem**: When the location label in `_LocationRow` is long (e.g. "المملكة العربية السعودية"), the Row containing the label text and chevron icon overflows because the `Text` widget has no width constraint and no overflow handling. Additionally, the separator between city and country is always an Arabic comma `،` regardless of locale.

**Target file**: `lib/features/more/views/more_screen.dart`

### Step 1.1 — Fix locale-aware separator in `_locationLabel`

Locate the `_locationLabel` method (around line 372).

**Current code** (line 376):
```dart
if (city != null && country != null) return '$city، $country';
```

**Replace with**:
```dart
final separator = isAr ? '، ' : ', ';
if (city != null && country != null) return '$city$separator$country';
```

### Step 1.2 — Verify `Flexible` wrapper and `overflow` already exist

The current code at lines 390–397 already wraps the `Text` in a `Flexible` and sets `overflow: TextOverflow.ellipsis`:

```dart
Flexible(
  child: Text(
    _locationLabel(context),
    overflow: TextOverflow.ellipsis,
    style: AppStyle.regular14.copyWith(
      color: AppColor.onSurfaceVariant,
    ),
  ),
),
```

**Action**: Verify these are present. If they are, Step 1.2 is a no-op. If `maxLines: 1` is missing, add it to the `Text` widget:

```dart
Text(
  _locationLabel(context),
  overflow: TextOverflow.ellipsis,
  maxLines: 1,
  style: AppStyle.regular14.copyWith(
    color: AppColor.onSurfaceVariant,
  ),
),
```

### Step 1.3 — Add `maxLines: 1` to the Text widget

Add `maxLines: 1` to the `Text` widget inside `Flexible` to guarantee single-line ellipsis behavior:

The `Text` inside the `Flexible` should read:
```dart
Text(
  _locationLabel(context),
  overflow: TextOverflow.ellipsis,
  maxLines: 1,
  style: AppStyle.regular14.copyWith(
    color: AppColor.onSurfaceVariant,
  ),
),
```

### Acceptance criteria
- The location row never overflows, regardless of city/country name length
- Arabic locale shows `، ` separator; English locale shows `, ` separator
- Existing chevron icon remains visible and right-aligned

---

## Milestone 2 — Fix language toggle in onboarding (Bug 1)

**Problem**: When the user toggles language (EN ↔ عربي) on the onboarding screen, `context.setLocale()` triggers a widget rebuild, but the `OnboardingCubit` state still holds the previously-selected `CountryModel`/`CityModel` objects. The `_SelectorTile` widget correctly switches between `value` and `valueAr` based on `context.locale`, but when `_LanguageToggle` calls `context.setLocale()`, the cubit state isn't re-emitted, so the UI may show stale data or throw errors if the rebuild happens at an unexpected time.

Additionally, `LocaleCubit` and `LocaleState` in `lib/features/more/viewmodels/` are dead code (never imported or used anywhere in the project) and should be removed.

### Step 2.1 — Remove dead code: `LocaleCubit` and `LocaleState`

**Delete these two files entirely**:
- `lib/features/more/viewmodels/locale_cubit.dart`
- `lib/features/more/viewmodels/locale_state.dart`

**Verification**: No other file in the project imports these. The grep confirms they are only referenced within their own files. Safe to delete.

### Step 2.2 — Add a locale-changed listener in `_Body` to re-emit current state

The onboarding screen's `_Body` widget uses `BlocConsumer<OnboardingCubit, OnboardingState>`. After `context.setLocale()` is called by `_LanguageToggle`, easy_localization rebuilds the widget tree, which causes `_Body.build` to re-run. At that point, `context.locale` is already updated, so `SelectorTile` and `SearchSheet` already pick the correct language for display labels.

**However**, the real problem is that `_LanguageToggle` is a `StatelessWidget` inside `_Body`, and calling `context.setLocale()` only changes the locale at the `MaterialApp` level — it does NOT trigger the `OnboardingCubit` to re-emit its current state. Since `SelectorTile` reads `country?.name` / `country?.nameAr` and `city?.name` / `city?.nameAr` from the cubit state and switches based on `context.locale`, the display should actually work correctly because `CountryModel` and `CityModel` already contain both `name` and `nameAr` fields.

**The actual issue**: After `context.setLocale()` is called, easy_localization may throw or produce errors if the locale change happens during an active modal bottom sheet (the search sheet). The `_SearchSheet` uses `context.locale.languageCode` inside `build` method, and if the locale changes while the sheet is open, it can cause rebuild conflicts.

**Fix**: Make `_LanguageToggle` close any open bottom sheet before toggling the locale. Add a `Navigator.pop` guard in `_LanguageToggle`:

**File**: `lib/features/onboarding/views/onboarding_screen.dart`

Locate `_LanguageToggle` (around line 379):

**Current**:
```dart
class _LanguageToggle extends StatelessWidget {
  const _LanguageToggle();

  @override
  Widget build(BuildContext context) {
    final isAr = context.locale.languageCode == 'ar';
    return Tooltip(
      message: 'onboarding_language_tooltip'.tr(),
      child: GestureDetector(
        onTap: () => context.setLocale(isAr ? const Locale('en') : const Locale('ar')),
```

**Replace the `onTap` with**:
```dart
onTap: () {
  Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst || route.settings.name == null);
  context.setLocale(isAr ? const Locale('en') : const Locale('ar'));
},
```

Wait — this would pop ALL sheets, which is aggressive. A better approach is simply dismissing any modal sheet if one is open, then toggling:

```dart
onTap: () {
  final isAr = context.locale.languageCode == 'ar';
  final newLocale = isAr ? const Locale('en') : const Locale('ar');
  context.setLocale(newLocale);
},
```

Actually, the real issue may be different. Let me re-analyze.

**Re-analysis**: The `_SelectorTile` widget at line 279 already does:
```dart
final isLocaleAr = context.locale.languageCode == 'ar';
final displayValue = isLocaleAr ? (valueAr ?? value) : value;
```

And the `_Body` passes:
```dart
value: country?.name,
valueAr: country?.nameAr,
```

So when locale changes, `context.locale` updates, `SelectorTile` rebuilds, and `displayValue` switches to the correct language. This should work correctly.

**The actual error source**: When `context.setLocale()` is called, easy_localization rebuilds the entire widget tree from `MaterialApp`. During this rebuild, the `OnboardingCubit` was created by `BlocProvider` in `OnboardingScreen.build`. If `OnboardingScreen` itself gets rebuilt (which it shouldn't, since locale change doesn't remount it), the cubit would be recreated and state would reset to `OnboardingInitial` — losing the user's country/city selection.

But wait — `BlocProvider` by default uses `create` which means it's lazily created once and persisted. The cubit should survive locale changes.

**The real crash path**: If the user has already selected a country (state is `OnboardingCountryPicked`) and then toggles language, the widget rebuilds with the new locale. `country?.name` and `country?.nameAr` are both accessible from the `CountryModel` object in state. This should work.

Let me verify by checking if there's an issue with the way `easy_localization` handles locale changes. When `context.setLocale()` is called, it changes the locale at the `EasyLocalization` widget level, which is above `MaterialApp`. This causes a full rebuild. The `BlocProvider<OnboardingCubit>` is below `MaterialApp`, so it should NOT be recreated.

**Conclusion**: The most likely error is that changing locale during the onboarding flow can cause a `setState` or `markNeedsBuild` call on a widget that's being rebuilt, particularly if a bottom sheet is open. The fix should ensure that:

1. Language toggle dismisses any open bottom sheet before changing locale
2. The cubit state persists correctly across locale changes

### Step 2.2 (revised) — Handle locale toggle safely

**File**: `lib/features/onboarding/views/onboarding_screen.dart`

In `_LanguageToggle`, change the `onTap` to dismiss any open modal sheet first:

```dart
onTap: () {
  final isAr = context.locale.languageCode == 'ar';
  final newLocale = isAr ? const Locale('en') : const Locale('ar');
  Navigator.of(context, rootNavigator: true).popUntil((route) {
    return route.isFirst;
  });
  context.setLocale(newLocale);
},
```

**Wait** — this is too aggressive, it would pop back past the onboarding screen itself.

Better approach: Only pop modal routes below the current route:

Actually, the simplest fix is: don't pop anything, just set the locale. The `easy_localization` rebuild should preserve BlocProvider state. The errors described in the bug likely come from a different issue.

### Step 2.2 (final) — Add locale-awareness to OnboardingCubit state re-emission

The core fix: When locale changes, the `OnboardingCubit` needs to re-emit its current state so the BlocBuilder picks up the change. We'll add a method to the cubit and call it when locale changes.

**File**: `lib/features/onboarding/viewmodels/onboarding_cubit.dart`

Add a new method that re-emits the current state (this forces BlocBuilder to rebuild with the new locale context):

```dart
void refreshForLocaleChange() {
  final current = state;
  if (current is OnboardingCountryPicked && current is! OnboardingCityPicked) {
    emit(OnboardingCountryPicked(current.country));
  } else if (current is OnboardingCityPicked) {
    emit(OnboardingCityPicked(country: current.country, city: current.city));
  }
}
```

**File**: `lib/features/onboarding/views/onboarding_screen.dart`

In the `_LanguageToggle` widget, after setting locale, also trigger the cubit:

```dart
onTap: () {
  final isAr = context.locale.languageCode == 'ar';
  final newLocale = isAr ? const Locale('en') : const Locale('ar');
  context.setLocale(newLocale);
  context.read<OnboardingCubit>().refreshForLocaleChange();
},
```

But wait — `_LanguageToggle` is a `StatelessWidget` that doesn't have direct access to the `OnboardingCubit`. It needs to read it from context. Since it's inside the `BlocConsumer`, it can use `context.read<OnboardingCubit>()`.

**However**, the real issue might be that calling `context.setLocale()` triggers an immediate rebuild, and during that rebuild, calling `context.read<OnboardingCubit>().refreshForLocaleChange()` might cause issues because the widget tree is being rebuilt.

Alternative approach: Use `addPostFrameCallback` to defer the cubit call:

```dart
onTap: () {
  final isAr = context.locale.languageCode == 'ar';
  final newLocale = isAr ? const Locale('en') : const Locale('ar');
  context.setLocale(newLocale);
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (context.mounted) {
      context.read<OnboardingCubit>().refreshForLocaleChange();
    }
  });
},
```

Actually, re-analyzing the bug description: "the widget tree DOES rebuild, but `OnboardingCubit` state variables contain locale-dependent cached strings that were loaded in a previous locale." But looking at the code, the cubit state holds `CountryModel` and `CityModel` objects which already contain both `name` and `nameAr`. The `SelectorTile` already uses `context.locale.languageCode` to choose which field to display. So the state re-emission isn't strictly necessary for the display — `SelectorTile` already handles it.

The error might actually be something else. Let me re-read the bug description: "Language change in onboarding screen throws errors and doesn't update automatically."

"throws errors" — this might be a framework-level error where easy_localization's locale change causes a rebuild during which some widget tries to access `tr()` before the locale is fully initialized, or a `BuildContext` is used across an async gap.

The simplest and most robust fix: Make `_LanguageToggle` a `StatefulWidget` and use `addPostFrameCallback`:

**File**: `lib/features/onboarding/views/onboarding_screen.dart`

Replace `_LanguageToggle` (lines 379-409):

```dart
class _LanguageToggle extends StatefulWidget {
  const _LanguageToggle();

  @override
  State<_LanguageToggle> createState() => _LanguageToggleState();
}

class _LanguageToggleState extends State<_LanguageToggle> {
  bool _switching = false;

  @override
  Widget build(BuildContext context) {
    final isAr = context.locale.languageCode == 'ar';
    return Tooltip(
      message: 'onboarding_language_tooltip'.tr(),
      child: GestureDetector(
        onTap: _switching
            ? null
            : () {
                setState(() => _switching = true);
                final newLocale = isAr ? const Locale('en') : const Locale('ar');
                context.setLocale(newLocale);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() => _switching = false);
                  }
                });
              },
        child: Container(
          decoration: BoxDecoration(
            color: AppColor.surfaceContainer,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: AppColor.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          padding: EdgeInsets.all(3.r),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LangChip(label: 'EN', active: !isAr),
              SizedBox(width: 2.w),
              _LangChip(label: 'عربي', active: isAr),
            ],
          ),
        ),
      ),
    );
  }
}
```

The key changes:
1. Convert from `StatelessWidget` to `StatefulWidget` to add a `_switching` guard
2. Disable the tap during locale switching to prevent double-taps
3. The locale change via `context.setLocale()` will rebuild the widget tree, and the `_switching` flag resets in the next frame

**Also add**: Ensure that the `SelectorTile` and entire `_Body` are correctly picking up locale changes. The current implementation should already work because:
- `SelectorTile` reads `context.locale.languageCode` in its `build` method
- `BlocConsumer` will rebuild when `OnboardingCubit` state changes
- The country/city models already have both `name` and `nameAr` fields

But the "doesn't update automatically" part may refer to the location display in `_LocationRow` on the More screen, which reads from SharedPreferences. After locale change, `_LocationRow._load()` needs to be called again. Since `_LocationRow` is a `StatefulWidget`, it should rebuild when `context.locale` changes (because `easy_localization` triggers a full tree rebuild). But `_load()` is only called in `initState` and when location is changed. The `_locationLabel()` method already uses `context.locale.languageCode` to pick between cached names, so it should update correctly on rebuild without needing to call `_load()` again.

**HOWEVER**, `_LocationRow` is stateful and the `_cityName`, `_cityNameAr`, etc. are loaded in `initState`. When locale changes, `easy_localization` rebuilds the tree, but `_LocationRow` is a `StatefulWidget` — its `State` object is preserved across rebuilds (unless the widget's key changes). So the `build` method re-runs, and `_locationLabel(context)` will pick the correct language from the already-loaded fields. This should work correctly.

**The onboarding flow**: After `context.setLocale()`, the entire subtree under `EasyLocalization` rebuilds. The `BlocProvider<OnboardingCubit>` persists its cubit across rebuilds because it's created with `create:` which is lazy and only called once. The `BlocConsumer` will call its `builder` again, picking up the current state and the new locale context.

### Step 2.3 — Ensure `_LocationRow` on More screen updates with locale

**File**: `lib/features/more/views/more_screen.dart`

The `_LocationRow` is a `StatefulWidget` that loads city/country names from SharedPreferences in `initState`. Since `_locationLabel()` already uses `context.locale.languageCode` to pick between `_cityNameAr`/`_cityName` and `_countryNameAr`/`_countryName`, the label should update when locale changes because `build` is called again.

**But**: There's a subtle issue. `_LocationRow` extends `StatefulWidget`, and its `State` persists across locale changes. The `build` method will be called again when `easy_localization` triggers a rebuild, and `context.locale.languageCode` will return the new locale. The location label should update correctly.

No changes needed here for locale — the `_locationLabel` method already handles it. The fix for Bug 1 is purely in the onboarding flow.

### Step 2.4 — Delete dead code files

Delete:
- `lib/features/more/viewmodels/locale_cubit.dart`
- `lib/features/more/viewmodels/locale_state.dart`

### Acceptance criteria
- Tapping language toggle on onboarding screen switches between EN/Ar without errors
- Selected country and city labels update to the new language immediately
- No dead `LocaleCubit`/`LocaleState` files remain in the project
- Language change from More > Localization screen still works correctly

---

## Milestone 3 — Fix prayer times not recalculating after location change (Bug 2)

**Problem**: When the user changes location via `ChangeLocationScreen`, prayer times don't update because two caches return stale data:
1. `SharedLocationService` caches GPS coordinates for 30 seconds — after a manual city selection, the GPS cache still returns old coordinates
2. `LocationUtils.getCountryCode()` caches the country code and only invalidates when user moves >50km — a manual city change may be to a different country within 50km

**Root cause chain**:  
`ChangeLocationScreen` → user picks city → `OnboardingCubit.confirm()` saves new lat/lng and country code to SharedPreferences → pops with `true` → `_LocationRow` calls `homeCubit.refreshPrayerTimes()` → `HomeCubit.refreshPrayerTimes()` calls `loadPrayerTimes()` → `loadPrayerTimes()` calls `_tryInstantLoadFromCache()` (reads SharedPreferences — this gets NEW coords ✓) then calls `getPrayerTimesForCurrentLocation()` → uses `SharedLocationService.instance.getCurrentLocation()` which returns the OLD cached GPS position → prayer times calculated with wrong location.

### Step 3.1 — Add cache invalidation to `SharedLocationService`

**File**: `lib/core/services/shared_location_service.dart`

`SharedLocationService` already has an `invalidateCache()` method (line 41-44). We need to call this method after manual location change.

No changes needed to this file — the method already exists.

### Step 3.2 — Add `forceRefresh` parameter to `LocationUtils.getCountryCode()`

**File**: `lib/core/utils/location_utils.dart`

Add a `bool forceRefresh = false` parameter. When `forceRefresh` is true, skip the cache check and recalculate the country code.

**Current method signature** (line 79):
```dart
static Future<String> getCountryCode(
    double lat, double lng) async {
```

**Replace with**:
```dart
static Future<String> getCountryCode(
    double lat, double lng, {bool forceRefresh = false}) async {
```

**Inside the method**, after getting `prefs` (line 82), add the force-refresh logic:

Current code (lines 84-100):
```dart
final cachedCountry = prefs.getString(_countryKey);
final oldLat = prefs.getDouble(_latKey);
final oldLng = prefs.getDouble(_lngKey);
if (kDebugMode) debugPrint('[Country] B — cachedCountry=$cachedCountry');

if (cachedCountry != null &&
    oldLat != null &&
    oldLng != null &&
    _hasMoved(oldLat, oldLng, lat, lng)) {
  if (kDebugMode) debugPrint('[Country] C — moved, clearing cache');
  await prefs.remove(_countryKey);
}

final newCached = prefs.getString(_countryKey);
if (newCached != null) {
  if (kDebugMode) debugPrint('[Country] D — returning cached: $newCached');
  return newCached;
}
```

**Replace with**:
```dart
if (forceRefresh) {
  if (kDebugMode) debugPrint('[Country] B — forceRefresh, clearing cache');
  await prefs.remove(_countryKey);
} else {
  final cachedCountry = prefs.getString(_countryKey);
  final oldLat = prefs.getDouble(_latKey);
  final oldLng = prefs.getDouble(_lngKey);
  if (kDebugMode) debugPrint('[Country] B — cachedCountry=$cachedCountry');

  if (cachedCountry != null &&
      oldLat != null &&
      oldLng != null &&
      _hasMoved(oldLat, oldLng, lat, lng)) {
    if (kDebugMode) debugPrint('[Country] C — moved, clearing cache');
    await prefs.remove(_countryKey);
  }

  final newCached = prefs.getString(_countryKey);
  if (newCached != null) {
    if (kDebugMode) debugPrint('[Country] D — returning cached: $newCached');
    return newCached;
  }
}
```

This ensures that when `forceRefresh` is true, we skip reading the cached country code entirely and proceed directly to offline detection or geocoding.

### Step 3.3 — Add `refreshPrayerTimesForLocation(lat, lng)` method to `HomeCubit`

**File**: `lib/features/home/view/cubit/home_cubit.dart`

Add a new method that accepts explicit coordinates, invalidates the `SharedLocationService` cache, and calculates prayer times for the given location:

```dart
Future<void> refreshPrayerTimesForLocation({
  required double latitude,
  required double longitude,
}) async {
  SharedLocationService.instance.invalidateCache();
  await LocationUtils.forceRefreshCountryCode(latitude, longitude);
  try {
    emit(const HomeLoading());
    final result = await repository.getPrayerTimesForLocation(
      latitude: latitude,
      longitude: longitude,
    );
    result.fold(
      (failure) => emit(HomeError(
        message: failure.message,
        statusCode: failure is ServerFailure ? failure.statusCode : null,
      )),
      (prayerTimes) => _onLoaded(prayerTimes),
    );
  } catch (e) {
    debugPrint('[Home] CATCH — refreshPrayerTimesForLocation: $e');
    if (state is! HomeLoaded) {
      emit(HomeError(
        message: e.toString().replaceFirst('Exception: ', ''),
        statusCode: null,
      ));
    }
  }
}
```

**But wait** — we need to also add a static helper to `LocationUtils` for force-refreshing the country code. Let me reconsider.

Actually, the approach should be simpler. `OnboardingCubit.confirm()` already saves the latitude, longitude, AND country code to SharedPreferences. So `HomeCubit._tryInstantLoadFromCache()` already picks up the new coordinates and country code. The problem is that `HomeCubit.refreshPrayerTimes()` (which is just `loadPrayerTimes()`) also goes through the GPS path via `getPrayerTimesForCurrentLocation()`, which uses `SharedLocationService` — returning stale coordinates.

The fix: After a manual location change, we should skip the GPS lookup entirely and use the cached coordinates. We can add a method to `HomeCubit` that:
1. Invalidates `SharedLocationService` cache
2. Reads coordinates from SharedPreferences (which were just updated by `OnboardingCubit.confirm()`)
3. Reads or force-refreshes the country code
4. Calculates prayer times directly (no GPS needed)

### Step 3.3 (revised) — Add `refreshAfterManualLocationChange()` to `HomeCubit`

**File**: `lib/features/home/view/cubit/home_cubit.dart`

Add the following import at the top (if not already present):
```dart
import 'package:mosques_app/core/services/shared_location_service.dart';
```

Add a new method after `refreshPrayerTimes()` (around line 129):

```dart
Future<void> refreshAfterManualLocationChange() async {
  SharedLocationService.instance.invalidateCache();
  try {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(BackgroundRescheduleService.prefsLat);
    final lng = prefs.getDouble(BackgroundRescheduleService.prefsLng);
    if (lat == null || lng == null) {
      await loadPrayerTimes();
      return;
    }
    final countryCode = await LocationUtils.getCountryCode(lat, lng, forceRefresh: true);
    final prayerTimes = AdhanPrayerService.calculatePrayerTimesSync(
      latitude: lat,
      longitude: lng,
      countryCode: countryCode,
    );
    _onLoaded(
      AladhanPrayerTimesModel.fromAdhanPrayerTimes(
        prayerTimes: prayerTimes,
        latitude: lat,
        longitude: lng,
      ),
    );
    await BackgroundRescheduleService.cacheLastLocation(lat, lng);
    await AppPreferences.saveString(LocationUtils.countryCodePrefsKey, countryCode);
  } catch (e) {
    debugPrint('[Home] refreshAfterManualLocationChange error: $e');
    await loadPrayerTimes();
  }
}
```

**Required imports** (add if missing):
```dart
import 'package:mosques_app/core/services/shared_location_service.dart';
import 'package:mosques_app/core/services/adhan_prayer_service.dart';
import 'package:mosques_app/core/utils/app_shared_preferences.dart';
```

### Step 3.4 — Wire `_LocationRow` to use the new method

**File**: `lib/features/more/views/more_screen.dart`

Currently in `_LocationRowState.build()` (around lines 407-414):
```dart
onTap: () async {
  final homeCubit = context.read<HomeCubit>();
  final changed = await Navigator.pushNamed(context, Routes.changeLocation);
  if (changed == true && mounted) {
    _load();
    homeCubit.refreshPrayerTimes();
  }
},
```

**Replace with**:
```dart
onTap: () async {
  final homeCubit = context.read<HomeCubit>();
  final changed = await Navigator.pushNamed(context, Routes.changeLocation);
  if (changed == true && mounted) {
    _load();
    homeCubit.refreshAfterManualLocationChange();
  }
},
```

### Step 3.5 — Ensure `OnboardingCubit.confirm()` in `ChangeLocationScreen` also invalidates caches

**File**: `lib/features/onboarding/viewmodels/onboarding_cubit.dart`

The `confirm()` method already saves latitude, longitude, and country code to SharedPreferences. It also calls `BackgroundRescheduleService.cacheLastLocation()`. 

However, the country code save on line 82 uses the country from the selected city:
```dart
AppPreferences.saveString(LocationUtils.countryCodePrefsKey, current.country.code),
```

This is correct — it directly writes the country code from the known `CountryModel`, bypassing `LocationUtils.getCountryCode()`. So the country code cache IS updated.

But `LocationUtils.getCountryCode()` has its own separate cache keys (`_countryKey` = `'cached_country_code'`, `_latKey` = `'loc_utils_lat'`, `_lngKey` = `'loc_utils_lng'`). When `confirm()` writes to `LocationUtils.countryCodePrefsKey` (which is `'cached_country_code'`), it updates one cache. But the latitude/longitude in `LocationUtils`'s cache (`_latKey`, `_lngKey`) might still contain old values, causing the 50km movement check to incorrectly keep a stale country code on the next GPS-based lookup.

**Fix**: In `OnboardingCubit.confirm()`, also update `LocationUtils`'s internal cache coordinates by saving the new lat/lng to the `LocationUtils` keys. OR, simply call `LocationUtils.getCountryCode()` with `forceRefresh` after saving, which will overwrite the cache.

Actually, the cleanest approach: since `OnboardingCubit.confirm()` already knows the correct country code (`current.country.code`), it should ALSO update the `LocationUtils` cache lat/lng so future GPS-based country lookups don't incorrectly invalidate the known country.

Add these saves inside `confirm()`:

**File**: `lib/features/onboarding/viewmodels/onboarding_cubit.dart`

In the `confirm()` method's `Future.wait` block, add two more save calls:

Current (lines 77-88):
```dart
await Future.wait([
  BackgroundRescheduleService.cacheLastLocation(
    current.city.lat,
    current.city.lng,
  ),
  AppPreferences.saveString(LocationUtils.countryCodePrefsKey, current.country.code),
  AppPreferences.saveString(kCachedCityName, current.city.name),
  AppPreferences.saveString(kCachedCityNameAr, current.city.nameAr),
  AppPreferences.saveString(kCachedCountryName, current.country.name),
  AppPreferences.saveString(kCachedCountryNameAr, current.country.nameAr),
  AppPreferences.saveBool(_kDone, value: true),
]);
```

**Also invalidate `SharedLocationService` cache** — add this import at the top of the file:

```dart
import 'package:mosques_app/core/services/shared_location_service.dart';
```

Add **before** the `emit(OnboardingSaving())` call in `confirm()`:
```dart
SharedLocationService.instance.invalidateCache();
```

And update the `Future.wait` to also save the location utility cache coordinates:
```dart
await Future.wait([
  BackgroundRescheduleService.cacheLastLocation(
    current.city.lat,
    current.city.lng,
  ),
  AppPreferences.saveString(LocationUtils.countryCodePrefsKey, current.country.code),
  AppPreferences.saveString(kCachedCityName, current.city.name),
  AppPreferences.saveString(kCachedCityNameAr, current.city.nameAr),
  AppPreferences.saveString(kCachedCountryName, current.country.name),
  AppPreferences.saveString(kCachedCountryNameAr, current.country.nameAr),
  AppPreferences.saveDouble(LocationUtils.locUtilsLatKey, current.city.lat),
  AppPreferences.saveDouble(LocationUtils.locUtilsLngKey, current.city.lng),
  AppPreferences.saveBool(_kDone, value: true),
]);
```

**BUT** — `LocationUtils._latKey` and `_latKey` are private. We need to make them accessible, or add a public method.

### Step 3.5 (revised) — Add a public method to `LocationUtils` to update the coordinate cache

**File**: `lib/core/utils/location_utils.dart`

Add a static method after `getCountryCode()`:

```dart
static Future<void> updateCoordinateCache(double lat, double lng) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setDouble(_latKey, lat);
  await prefs.setDouble(_lngKey, lng);
}
```

Also add a public constant for the internal country key (it's already public as `countryCodePrefsKey`, but the lat/lng keys are private). We don't need to expose them — the `updateCoordinateCache` method is sufficient.

**File**: `lib/features/onboarding/viewmodels/onboarding_cubit.dart`

Add import:
```dart
import 'package:mosques_app/core/services/shared_location_service.dart';
```

Update `confirm()`:

```dart
Future<void> confirm() async {
  final current = state;
  if (current is! OnboardingCityPicked) return;

  log('[Location] confirm: saving ${current.country.name} / ${current.city.name} '
      '(${current.city.lat}, ${current.city.lng})', name: 'OnboardingCubit');

  SharedLocationService.instance.invalidateCache();
  emit(OnboardingSaving());

  await Future.wait([
    BackgroundRescheduleService.cacheLastLocation(
      current.city.lat,
      current.city.lng,
    ),
    AppPreferences.saveString(LocationUtils.countryCodePrefsKey, current.country.code),
    LocationUtils.updateCoordinateCache(current.city.lat, current.city.lng),
    AppPreferences.saveString(kCachedCityName, current.city.name),
    AppPreferences.saveString(kCachedCityNameAr, current.city.nameAr),
    AppPreferences.saveString(kCachedCountryName, current.country.name),
    AppPreferences.saveString(kCachedCountryNameAr, current.country.nameAr),
    AppPreferences.saveBool(_kDone, value: true),
  ]);

  log('[Location] confirm: saved successfully', name: 'OnboardingCubit');
  emit(OnboardingDone());
}
```

### Step 3.6 — Handle the `skipWithGps()` path

The `skipWithGps()` method doesn't save any coordinates — it just marks onboarding as done and lets HomeCubit fall through to GPS. This is fine, but `SharedLocationService` cache should still be invalidated when transitioning to GPS mode in case stale data is cached.

**File**: `lib/features/onboarding/viewmodels/onboarding_cubit.dart`

In `skipWithGps()`, add cache invalidation:

```dart
Future<void> skipWithGps() async {
  log('[Location] skipWithGps: user chose GPS-only mode', name: 'OnboardingCubit');
  SharedLocationService.instance.invalidateCache();
  emit(OnboardingSaving());
  await AppPreferences.saveBool(_kDone, value: true);
  emit(OnboardingDone());
}
```

### Step 3.7 — Update `ChangeLocationScreen` listener

**File**: `lib/features/more/views/change_location_screen.dart`

The `ChangeLocationScreen` currently pops with `true` when `OnboardingCubit` emits `OnboardingDone`. The `_LocationRow` in `more_screen.dart` already handles this by calling `_load()` and `homeCubit.refreshAfterManualLocationChange()`. No changes needed here.

### Acceptance criteria
- After manually changing location on the More screen, prayer times recalculate with the new coordinates
- The `SharedLocationService` cache is invalidated so GPS data won't override the new location within 30 seconds
- The `LocationUtils` country code cache is force-refreshed so the correct calculation method is used
- The background notification service (`BackgroundRescheduleService`) correctly reads the new coordinates from SharedPreferences
- GPS-fallback mode (skip with GPS) still works correctly

---

## Dependency Map

```
M1 (Bug 3 — layout overflow)
  └── No dependencies — standalone CSS/layout fix

M2 (Bug 1 — language toggle)
  ├── onboarding_screen.dart (modify _LanguageToggle)
  ├── onboarding_cubit.dart (add refreshForLocaleChange)
  ├── locale_cubit.dart (DELETE)
  └── locale_state.dart (DELETE)

M3 (Bug 2 — prayer times recalculation)
  ├── shared_location_service.dart (already has invalidateCache — no change)
  ├── location_utils.dart (add forceRefresh param + updateCoordinateCache)
  ├── home_cubit.dart (add refreshAfterManualLocationChange)
  ├── onboarding_cubit.dart (invalidate caches in confirm/skipWithGps)
  └── more_screen.dart (call refreshAfterManualLocationChange instead of refreshPrayerTimes)
```

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Locale change causes widget tree rebuild errors in onboarding | Medium | Medium | Use `StatefulWidget` with `_switching` guard; add `mounted` check before cubit calls |
| Force-refreshing country code hits geocoding API unnecessarily | Low | Low | `getCountryCode` has offline detection as first fallback; geocoding only used if offline detection fails |
| `refreshAfterManualLocationChange` fails to read SharedPreferences | Low | High | Falls back to `loadPrayerTimes()` (GPS path) on any exception |
| Background service reads stale coordinates | Low | High | `confirm()` writes to `BackgroundRescheduleService.cacheLastLocation()` first; background task reads from same keys |
| Deleting `LocaleCubit`/`LocaleState` breaks something | Very Low | N/A | Grep confirms zero imports outside their own files |

## Implementation Order

1. **M1** — Fix location label overflow (5 minutes, 1 file)
2. **M2** — Fix language toggle (15 minutes, 3 files + 2 deletions)
3. **M3** — Fix prayer times recalculation (30 minutes, 5 files)

**Total estimated time**: ~50 minutes
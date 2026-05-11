# Performance Analysis Report — Al-Masjid

## Executive Summary

The app is structurally sound: MVVM+Cubit is applied correctly, background scheduling uses WorkManager properly, and location caching/deduplication is in place. However, four issues cause continuous CPU and battery drain even while the screen is idle, and one pattern causes a six-widget rebuild storm every 3 seconds on the home screen.

---

## Critical Issues

---

### CRIT-1 — `TimeFormatCubit` polls a native platform channel every 3 seconds

**Root cause**: `TimeFormatCubit.init()` starts a `Timer.periodic(Duration(seconds: 3), ...)` that invokes a method channel (`com.example.mosques_app/time_format`) on every tick.

**Affected file**: `lib/core/cubit/time_format_cubit.dart:22`

```dart
_pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
  _fetchAndEmit();
});
```

**Performance impact**:
- 20 native platform-channel round-trips per minute, 1 200 per hour, continuously while the app is in the foreground.
- Every tick that returns the same value still touches the event loop, native bridge, and conditional emit path.
- The 12 h/24 h system setting does **not** change at runtime (it requires the user to open Android Settings and actively flip a toggle while the app is running). The poll catches nothing in the 99.9 % case.
- The `WidgetsBindingObserver.didChangeAppLifecycleState` callback already fires when the app resumes from background — exactly the one moment when the setting could have changed.

**Optimization strategy**:
Remove the `Timer.periodic` entirely. Keep only:
1. The initial `_fetchAndEmit()` call in `init()`.
2. The `didChangeAppLifecycleState` re-check on `resumed`.

No behaviour change: the setting is re-read immediately at startup and on every app foreground. The only scenario the polling covered was the user flipping the setting while Al-Masjid was in the foreground, which is indistinguishable from normal behaviour (clock stays correct, format updates on next app resume).

**Risk level**: Low. `_pollTimer` field and `cancel()` call in `close()` are already present — only the creation and the periodic callback need to be removed.

**Expected gain**: Eliminates ~1 200 native round-trips / hour and the associated wake-ups.

---

### CRIT-2 — `PrayerCountdownSection` rebuilds its entire subtree every second

**Root cause**: `_PrayerCountdownSectionState._tick` calls `setState()` every second. The state rebuild path re-evaluates:
- the `_prayers` getter (allocates a new `List<_PrayerInfo>` + 5 objects),
- `_computePrayers()` (iterates the list),
- the full `Column` including `PrayerCountdownCard` (contains a `RadialGradient`, `BoxShadow`, 5 `Text` widgets with font arithmetic) and 2× `SunTimingCard`.

**Affected file**: `lib/features/home/view/widgets/prayer_countdown_section.dart:77-83`

```dart
void _tick(Timer _) {
  if (!mounted) return;
  _computePrayers();
  setState(() => _remaining = _computeRemaining());
}
```

**Performance impact**:
- 60 full subtree rebuilds per minute for a widget tree that includes gradient backgrounds and multiple `Text` widgets.
- `PrayerCountdownCard` is recreated entirely each second even though only the formatted countdown string changes.
- The `SunTimingCard` widgets are completely static but are included in the rebuild.

**Optimization strategy**:
Extract the countdown string into a minimal `_CountdownText` `StatefulWidget` that holds the 1-second timer and calls `setState` on itself. The parent `PrayerCountdownSection` becomes `StatelessWidget`. `PrayerCountdownCard` becomes a lightweight `StatelessWidget` that receives the pre-computed `circleSize` and pre-formatted string — no timer, no `setState`.

Changes required:
1. Move `Timer`, `_remaining`, `_current`, `_next` and all `_compute*` logic into a new `_CountdownText` widget.
2. `PrayerCountdownSection` → `StatelessWidget` (removes `State` class entirely).
3. The `_prayers` getter moves to a `late final` field computed once in `initState` and updated only in `didUpdateWidget`.

**Risk level**: Low. Pure UI refactor, no state management or business logic touched.

**Expected gain**: Reduces per-second rebuilds from ~20 widgets to 1 `Text` widget.

---

### CRIT-3 — `AppBlocObserver` calls `print()` unconditionally in every state transition

**Root cause**: All four overrides use bare `print()` with no `kDebugMode` guard.

**Affected file**: `lib/app_bloc_observer.dart:7,12,17,22`

```dart
print('🔁 Bloc Change in ${bloc.runtimeType}: $change');
```

**Performance impact**:
- `print()` is never a no-op — it writes to stdout in debug, profile, **and release** builds.
- `$change` string interpolation on every `onChange` call forces the `Change` object's `toString()` to execute (which formats both `currentState` and `nextState`).
- With CRIT-1 unresolved, `TimeFormatCubit` alone triggers `onChange` up to 1 200 times/hour when the format value changes (or whenever it doesn't change but close() / rebuild forces a re-check).
- In production, `BottomNavCubit`, `AzanCubit`, `ThemeCubit`, and `HomeCubit` all emit on every navigation tap, toggle, and prayer transition.

**Optimization strategy**:
Gate all logging with `kDebugMode`:

```dart
import 'package:flutter/foundation.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (kDebugMode) print('🔁 Bloc Change in ${bloc.runtimeType}: $change');
  }
  // ... same for onCreate, onError, onClose
}
```

**Risk level**: Zero. Debug-only logging change.

**Expected gain**: Eliminates string allocation and stdout writes in release builds.

---

### CRIT-4 — Six `_PrayerRow` widgets each independently `watch` `TimeFormatCubit`

**Root cause**: `_PrayerRow.build` calls `context.watch<TimeFormatCubit>()`. Because `_PrayerRow` is not extracted as a separate `BlocBuilder` scope, every `TimeFormatCubit` emission forces all 6 rows to rebuild — even when the time format did not change.

**Affected file**: `lib/features/home/view/widgets/prayer_schedule_section.dart:106`

```dart
class _PrayerRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final use24Hour = context.watch<TimeFormatCubit>().state.is24Hour;
```

**Performance impact**:
- With CRIT-1 unresolved, all 6 `_PrayerRow` + `PrayerCountdownSection` = 7 widgets rebuild every 3 seconds.
- After CRIT-1 is fixed the issue becomes latent (fires only on app resume) but the pattern is still wrong — it means any new `TimeFormatCubit` emit (e.g. if a different cubit emits on the same context) causes 6 list rows to rebuild.

**Optimization strategy**:
Lift the `watch` to the parent `PrayerScheduleSection` and pass `use24Hour` as a parameter to `_PrayerRow`.

```dart
class PrayerScheduleSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final use24Hour = context.watch<TimeFormatCubit>().state.is24Hour;
    ...
    _PrayerRow(prayer: prayers[i], use24Hour: use24Hour)
  }
}
```

One `watch` → one rebuild instead of six independent rebuilds.

**Risk level**: Zero. Pure widget refactor.

**Expected gain**: 83 % fewer `_PrayerRow` rebuilds per `TimeFormatCubit` emission.

---

## Medium Priority Issues

---

### MED-1 — `MosqueListCard` uses `Image.network` (no disk caching)

**Root cause**: `_MosqueIconBox` uses `Image.network` directly.

**Affected file**: `lib/core/widgets/mosque_list_card.dart:88`

**Performance impact**: Every time the user scrolls through mosque cards or re-opens the search screen, network images are re-fetched from the API. This wastes bandwidth and battery, and causes visible flicker.

**Optimization strategy**: Add `cached_network_image` to `pubspec.yaml` and replace `Image.network` with `CachedNetworkImage`. Use the fallback builder for loading and error states (same as current `loadingBuilder` / `errorBuilder`).

**Risk level**: Low. Package addition + widget swap.

---

### MED-2 — `_prayers` getter in `PrayerCountdownSection` allocates a new list every second

**Root cause**: `get _prayers => [...]` is called inside `_tick` (CRIT-2 covers the parent issue; this is the sub-allocation pattern).

**Affected file**: `lib/features/home/view/widgets/prayer_countdown_section.dart:33`

**Optimization strategy**: Fixed automatically by CRIT-2 (move to `late final` field in `initState`).

---

### MED-3 — Sequential `await plugin.cancel(id)` loops in notification cancellation

**Root cause**: `_cancelAll()` iterates and awaits each cancel call individually.

**Affected file**: `lib/core/services/notification_service.dart:367-379` and `lib/core/services/background_reschedule_service.dart:183-191`

```dart
for (int i = kPreAlertBaseId; i < ...; i++) {
  await _plugin.cancel(i);   // sequential — each waits for the previous
}
```

**Performance impact**: With 6 prayers × 2 days × 2 types = 24 cancel calls + 6 legacy azan IDs = up to 30 sequential platform-channel round-trips on every notification reschedule. This runs at app start (via WorkManager 1-minute delay) and on every `AzanCubit.toggleAzan()`.

**Optimization strategy**:
Use `cancelAll()` if the plugin version supports it, or batch with `Future.wait()`:

```dart
await Future.wait([
  for (int i = kPreAlertBaseId; i < kPreAlertBaseId + kMaxPrayers * kDaysToSchedule; i++)
    _plugin.cancel(i),
  for (int i = kAtTimeBaseId; i < kAtTimeBaseId + kMaxPrayers * kDaysToSchedule; i++)
    _plugin.cancel(i),
  for (int i = 300; i < 306; i++)
    _plugin.cancel(i),
]);
```

The same pattern applies in `BackgroundRescheduleService._rescheduleAll()`.

**Risk level**: Low. The plugin operations are independent.

---

### MED-4 — `PrayerScheduleSection._fallbackPrayers` is a `static final` field that calls `.tr()` at class-load time

**Root cause**:

```dart
static final List<PrayerModel> _fallbackPrayers = [
  PrayerModel(name: 'fajr'.tr(), ...),
```

`static final` is initialized once when the class is first accessed. `.tr()` reads from `EasyLocalization`'s internal store which is locale-dependent. If the class is first accessed before localization is initialized, or if the user changes language, the static list is stale.

**Affected file**: `lib/features/home/view/widgets/prayer_schedule_section.dart:15-27`

**Optimization strategy**: Change to a non-static getter or compute inside `build()` with a null-check. Since this is a fallback shown only during loading it is rarely visible, but the pattern is a latent bug for locale switching.

**Risk level**: Low.

---

### MED-5 — `BackgroundRescheduleService` creates all notification channels on every background execution

**Root cause**: `_rescheduleAll()` runs channel creation inside the background task dispatcher.

**Affected file**: `lib/core/services/background_reschedule_service.dart:82-120`

**Performance impact**: 10+ `createNotificationChannel` calls (5 prayers × 2 channels each) on every WorkManager execution (every 6 hours + every 1-minute-after-app-start). Channel creation is idempotent but each call is a platform-channel round-trip. On first run after app install the legacy channel deletion adds overhead.

**Optimization strategy**: Gate channel creation with a `SharedPreferences` flag (`channels_created_v2 = true`) so it only runs once per install/update. Channels persist across app restarts; they do not need to be re-created each background task.

**Risk level**: Low. The flag key should include a version suffix so it re-runs after any channel ID change.

---

## Low Priority Improvements

---

### LOW-1 — `debugPrint` throughout location and cubit files is not gated by `kDebugMode`

`debugPrint` is **not** automatically disabled in release builds in Flutter (unlike `dart:developer`'s `log`, which can be stripped). Files affected:

- `lib/core/services/location_service.dart` (7 `debugPrint` calls)
- `lib/core/utils/location_utils.dart` (8 `debugPrint` calls)
- `lib/features/mosque_search/viewmodels/mosque_search_cubit.dart` (5 `debugPrint` calls including one inside `_onPositionUpdate` which fires on every GPS update)
- `lib/features/mosque_search/viewmodels/mosque_search_cubit.dart` cache check (3 `debugPrint` calls with string interpolation of float coordinates)

**Optimization strategy**: Wrap with `if (kDebugMode)` or replace with `dart:developer`'s `log()` (which is a no-op in release by default via the Dart VM's developer service gating).

---

### LOW-2 — `GlassNavBar` `BackdropFilter` composites on every frame behind it

`BackdropFilter(filter: ImageFilter.blur(...))` creates a `saveLayer` on the GPU pipeline. Since `PrayerCountdownSection` triggers a 1-second repaint directly above the nav bar area (if the Scaffold body scrolls content up behind the nav), the blur composite may be re-evaluated each second.

**Fix**: Wrap `PrayerCountdownSection` in a `RepaintBoundary` (after CRIT-2 is implemented). This isolates the repaint to the countdown text region and prevents it from dirtying the nav bar's blur composite.

**Risk level**: Minimal (additive, no existing code changed).

---

### LOW-3 — `MosqueSearchCubit.stopTracking()` is defined but callers must ensure it is wired

The `stopTracking()` method exists and `_positionSubscription?.cancel()` is in `close()`. However, if the `MosqueSearchCubit` is provided at a scope that keeps it alive across tab switches, the GPS stream remains active even when the mosque search tab is not visible.

**Affected file**: `lib/features/mosque_search/viewmodels/mosque_search_cubit.dart:54`

**Fix**: Verify the `BlocProvider` scope for `MosqueSearchCubit`. If provided above the tab navigator (at app or bottom-nav level), call `stopTracking()` from the bottom-nav lifecycle when the user leaves the search tab, and `startTracking()` when they return.

---

## Proposed Refactor Plan

| # | Optimization | Files | Complexity | Risk |
|---|---|---|---|---|
| P1 | Remove `TimeFormatCubit` polling timer | `time_format_cubit.dart` | XS | Low |
| P2 | Gate `AppBlocObserver` with `kDebugMode` | `app_bloc_observer.dart` | XS | Zero |
| P3 | Lift `TimeFormatCubit` watch to `PrayerScheduleSection` | `prayer_schedule_section.dart` | XS | Zero |
| P4 | Extract `_CountdownText` widget from `PrayerCountdownSection` | `prayer_countdown_section.dart` | S | Low |
| P5 | Batch notification cancellation with `Future.wait` | `notification_service.dart`, `background_reschedule_service.dart` | S | Low |
| P6 | Gate `debugPrint` with `kDebugMode` in location files | 4 files | XS | Zero |
| P7 | Fix `_fallbackPrayers` static `.tr()` call | `prayer_schedule_section.dart` | XS | Low |
| P8 | Add channel-creation flag to `BackgroundRescheduleService` | `background_reschedule_service.dart` | S | Low |
| P9 | Add `cached_network_image` for mosque photos | `pubspec.yaml`, `mosque_list_card.dart` | S | Low |
| P10 | Wrap countdown area in `RepaintBoundary` | `loaded_view.dart` | XS | Zero |

---

## Safe Implementation Order

**Phase A — Zero-risk, no architecture change (P1, P2, P3, P6, P7, P10)**
All are 1–5 line changes with zero behavioural impact. Can be merged as a single commit.

**Phase B — Small widget refactor (P4)**
Extract `_CountdownText`. Requires new inner class, moves timer ownership. Low risk but needs visual verification that the countdown still updates correctly.

**Phase C — Async batching + background service (P5, P8)**
Modifies notification scheduling paths. Requires testing that all 12 prayer notifications still fire correctly after `Future.wait` batching.

**Phase D — Package addition (P9)**
Adds `cached_network_image` dependency. Requires: `pubspec.yaml` update, `flutter pub get`, widget swap.

---

## Expected Performance Gains

| Area | Before | After |
|---|---|---|
| Native channel calls | ~1 200/hour (polling) | ~2/hour (lifecycle only) |
| Per-second widget rebuilds | ~20 widgets | 1 `Text` widget |
| `_PrayerRow` rebuilds / `TimeFormatCubit` emit | 6 | 1 (parent only) |
| Release build logging | Active `print()` on every state change | Fully silent |
| Notification cancel latency | 30 sequential round-trips | 1 concurrent batch |
| Mosque image bandwidth | Re-fetch on every scroll | Disk-cached after first load |
| Background channel setup | Runs every 6 hours | Runs once per install |

---

## NO IMPLEMENTATION HAS BEEN PERFORMED YET.

WAITING FOR USER APPROVAL.

Please review the issues above and indicate which phases or specific items you want implemented. You can approve:
- All phases (A → D)
- Specific phases (e.g. "Phase A and B only")
- Individual items by number (e.g. "P1, P2, P3")

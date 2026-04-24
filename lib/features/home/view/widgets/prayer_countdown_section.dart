import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosques_app/core/constants/app_colors.dart';
import 'package:mosques_app/features/home/model/home_model.dart';
import 'package:mosques_app/features/home/view/widgets/prayer_countdown_card.dart';
import 'package:mosques_app/features/home/view/widgets/sun_timing_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// _PrayerInfo  — lightweight value object used only within this file.
// ─────────────────────────────────────────────────────────────────────────────
class _PrayerInfo {
  final String name;
  final String time; // 24-hour "HH:MM"
  const _PrayerInfo(this.name, this.time);
}

// ─────────────────────────────────────────────────────────────────────────────
// PrayerCountdownSection  (Task C — countdown engine)
//
// Responsibilities:
//  • Build an ordered list of prayers from AladhanPrayerTimesModel.
//  • Determine which prayer is current and which comes next using wall-clock
//    time (minute-resolution comparison).
//  • Compute the exact seconds remaining until the next prayer, wrapping
//    correctly across midnight (Isha → next-day Fajr).
//  • Drive a Timer.periodic(1 second) that calls setState on every tick.
//  • Re-sync when the parent delivers updated prayer times (didUpdateWidget).
//  • Cancel the timer in dispose() to prevent memory leaks.
//
// Output: passes three derived strings + two display strings down to the
// pure-display _PrayerCountdownCard — no logic leaks into the card.
// ─────────────────────────────────────────────────────────────────────────────
class PrayerCountdownSection extends StatefulWidget {
  final AladhanPrayerTimesModel prayerTimes;

  const PrayerCountdownSection({super.key, required this.prayerTimes});

  @override
  State<PrayerCountdownSection> createState() => _PrayerCountdownSectionState();
}

class _PrayerCountdownSectionState extends State<PrayerCountdownSection> {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  late _PrayerInfo _current;
  late _PrayerInfo _next;

  // ── Ordered prayer list built from the model ──────────────────────────────
  // Sunrise and Imsak are intentionally excluded — they are not canonical
  // salah prayers and should not appear as "current" or "next" prayers.
  List<_PrayerInfo> get _prayers => [
        _PrayerInfo('Fajr', widget.prayerTimes.fajr),
        _PrayerInfo('Dhuhr', widget.prayerTimes.dhuhr),
        _PrayerInfo('Asr', widget.prayerTimes.asr),
        _PrayerInfo('Maghrib', widget.prayerTimes.maghrib),
        _PrayerInfo('Isha', widget.prayerTimes.isha),
      ];

  // ── "HH:MM" → total minutes since midnight ───────────────────────────────
  int _toMinutes(String t) {
    final parts = t.split(':');
    if (parts.length < 2) return 0;
    return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
  }

  // ── Derive current / next prayer from wall-clock time ────────────────────
  // Algorithm: iterate prayers in order; the last prayer whose start time
  // is ≤ now is "current". The one after it is "next". If no prayer has
  // started yet (pre-Fajr window), current = Isha (previous day), next = Fajr.
  void _computePrayers() {
    final prayers = _prayers;
    final now = DateTime.now();
    final nowMin = now.hour * 60 + now.minute;

    _PrayerInfo? current;
    _PrayerInfo? next;

    for (int i = 0; i < prayers.length; i++) {
      if (nowMin >= _toMinutes(prayers[i].time)) {
        current = prayers[i];
        next = prayers[(i + 1) % prayers.length];
      }
    }

    // Pre-Fajr: no prayer has started yet today.
    _current = current ?? prayers.last;  // Isha from yesterday
    _next = next ?? prayers.first;       // today's Fajr
  }

  // ── Compute exact seconds remaining until _next prayer ───────────────────
  // Wraps across midnight: if nextSec < nowSec, the prayer is tomorrow
  // (add 86 400 seconds = one full day).
  Duration _computeRemaining() {
    final now = DateTime.now();
    final nowSec = now.hour * 3600 + now.minute * 60 + now.second;
    final nextSec = _toMinutes(_next.time) * 60;

    int diffSec = nextSec - nowSec;
    if (diffSec < 0) diffSec += 86400;
    return Duration(seconds: diffSec);
  }

  // ── Timer callback — fires every second ──────────────────────────────────
  void _tick(Timer _) {
    if (!mounted) return;
    _computePrayers();
    setState(() => _remaining = _computeRemaining());
  }

  @override
  void initState() {
    super.initState();
    _computePrayers();
    _remaining = _computeRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
  }

  // ── Re-sync without restarting the timer when prayer data refreshes ───────
  @override
  void didUpdateWidget(PrayerCountdownSection old) {
    super.didUpdateWidget(old);
    if (old.prayerTimes != widget.prayerTimes) {
      _computePrayers();
      setState(() => _remaining = _computeRemaining());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  // ── Formatters ────────────────────────────────────────────────────────────

  /// "HH:MM" (24 h) → "h:MM AM/PM" (12 h, no leading zero on hour)
  String _to12Hour(String t) {
    final parts = t.split(':');
    if (parts.length < 2) return t;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = parts[1];
    if (h == 0) return '12:$m AM';
    if (h < 12) return '$h:$m AM';
    if (h == 12) return '12:$m PM';
    return '${h - 12}:$m PM';
  }

  /// Duration → "MM:SS" when < 1 hour, "H:MM:SS" when ≥ 1 hour.
  String _formatCountdown(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── "NOW PRAYING" heading ────────────────────────────────────────────
        Text(
          'NOW PRAYING',
          style: TextStyle(
            color: AppColor.textSecondary,
            fontSize: 12.sp,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: 12.h),

        // ── Pure display card ────────────────────────────────────────────────
        PrayerCountdownCard(
          currentPrayerName: _current.name,
          nextPrayerName: _next.name,
          remaining: _remaining,
          formattedCountdown: _formatCountdown(_remaining),
        ),
        SizedBox(height: 40.h),

        // ── Sunrise / Sunset row ─────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SunTimingCard(
              label: 'SUNRISE',
              time: _to12Hour(widget.prayerTimes.sunrise),
              icon: Icons.wb_sunny,
            ),
            SunTimingCard(
              label: 'SUNSET',
              time: _to12Hour(widget.prayerTimes.maghrib),
              icon: Icons.wb_sunny_outlined,
            ),
          ],
        ),
      ],
    );
  }
}
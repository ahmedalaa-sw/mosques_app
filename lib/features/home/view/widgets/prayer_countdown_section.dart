import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosques_app/core/constants/app_colors.dart';
import 'package:mosques_app/core/cubit/time_format_cubit.dart';
import 'package:mosques_app/core/extensions/time_format_helper.dart';
import 'package:mosques_app/features/home/model/home_model.dart';
import 'package:mosques_app/features/home/view/widgets/prayer_alert_banner.dart';
import 'package:mosques_app/features/home/view/widgets/prayer_countdown_card.dart';
import 'package:mosques_app/features/home/view/widgets/sun_timing_card.dart';

class _PrayerInfo {
  final String name;
  final String time; // 24-hour "HH:MM"
  const _PrayerInfo(this.name, this.time);
}
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
  List<_PrayerInfo> get _prayers => [
        _PrayerInfo('Fajr', widget.prayerTimes.fajr),
        _PrayerInfo('Dhuhr', widget.prayerTimes.dhuhr),
        _PrayerInfo('Asr', widget.prayerTimes.asr),
        _PrayerInfo('Maghrib', widget.prayerTimes.maghrib),
        _PrayerInfo('Isha', widget.prayerTimes.isha),
      ];
  int _toMinutes(String t) {
    final parts = t.split(':');
    if (parts.length < 2) return 0;
    return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
  }

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
    _current = current ?? prayers.last;  
    _next = next ?? prayers.first;       
  }

  Duration _computeRemaining() {
    final now = DateTime.now();
    final nowSec = now.hour * 3600 + now.minute * 60 + now.second;
    final nextSec = _toMinutes(_next.time) * 60;

    int diffSec = nextSec - nowSec;
    if (diffSec < 0) diffSec += 86400;
    return Duration(seconds: diffSec);
  }
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
  String _formatCountdown(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final use24Hour = context.watch<TimeFormatCubit>().state.is24Hour;

    // Show the alert banner when ≤ 15 minutes remain until the next prayer.
    final bool showAlert =
        _remaining.inMinutes <= 15 && _remaining.inSeconds > 0;

    return Column(
      children: [
        // ── 15-minute prayer alert banner ──────────────────────────────────
        AnimatedPrayerAlertBanner(
          isVisible: showAlert,
          prayerName: _next.name,
          remaining: _remaining,
          formattedCountdown: _formatCountdown(_remaining),
        ),

        Text(
          'NOW PRAYING',
          style: TextStyle(
            color: AppColor.textSecondary,
            fontSize: 12.sp,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: 12.h),
        PrayerCountdownCard(
          currentPrayerName: _current.name,
          nextPrayerName: _next.name,
          remaining: _remaining,
          formattedCountdown: _formatCountdown(_remaining),
        ),
        SizedBox(height: 40.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SunTimingCard(
              label: 'SUNRISE',
              time: TimeFormatHelper.format(widget.prayerTimes.sunrise, use24Hour),
              icon: Icons.wb_sunny,
            ),
            SunTimingCard(
              label: 'SUNSET',
              time: TimeFormatHelper.format(widget.prayerTimes.maghrib, use24Hour),
              icon: Icons.wb_sunny_outlined,
            ),
          ],
        ),
      ],
    );
  }
}
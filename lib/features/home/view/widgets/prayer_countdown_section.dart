import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosques_app/core/constants/app_colors.dart';
import 'package:mosques_app/core/cubit/time_format_cubit.dart';
import 'package:mosques_app/core/extensions/time_format_helper.dart';
import 'package:mosques_app/features/home/model/home_model.dart';
import 'package:mosques_app/features/home/view/widgets/prayer_countdown_card.dart';
import 'package:mosques_app/features/home/view/widgets/sun_timing_card.dart';

class _PrayerInfo {
  final String name;
  final String time; // 24-hour "HH:MM"
  const _PrayerInfo(this.name, this.time);
}

/// Stateless — only rebuilds when HomeCubit emits new prayer data or when
/// the time-format preference changes (via TimeFormatCubit). The live
/// per-second countdown is isolated inside [_CountdownTimer].
class PrayerCountdownSection extends StatelessWidget {
  final AladhanPrayerTimesModel prayerTimes;

  const PrayerCountdownSection({super.key, required this.prayerTimes});

  @override
  Widget build(BuildContext context) {
    final use24Hour = context.watch<TimeFormatCubit>().state.is24Hour;
    final double circleSize = MediaQuery.of(context).size.height * 0.26;

    return Column(
      children: [
        Text(
          'now_praying'.tr(),
          style: TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            color: AppColor.textSecondary,
            fontSize: 12.sp,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: 8.h),

        // Only this inner widget calls setState every second.
        _CountdownTimer(prayerTimes: prayerTimes, circleSize: circleSize),

        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SunTimingCard(
              label: 'sunrise'.tr(),
              time: TimeFormatHelper.format(prayerTimes.sunrise, use24Hour),
              icon: Icons.wb_sunny,
            ),
            SunTimingCard(
              label: 'sunset'.tr(),
              time: TimeFormatHelper.format(prayerTimes.maghrib, use24Hour),
              icon: Icons.wb_sunny_outlined,
            ),
          ],
        ),
      ],
    );
  }
}

/// Owns the 1-second [Timer] and rebuilds only [PrayerCountdownCard].
/// The [_prayers] list is cached in [initState] and refreshed only when
/// [prayerTimes] changes, eliminating per-tick list allocation.
class _CountdownTimer extends StatefulWidget {
  final AladhanPrayerTimesModel prayerTimes;
  final double circleSize;

  const _CountdownTimer({required this.prayerTimes, required this.circleSize});

  @override
  State<_CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<_CountdownTimer> {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  late List<_PrayerInfo> _prayers;
  late _PrayerInfo _current;
  late _PrayerInfo _next;

  @override
  void initState() {
    super.initState();
    _prayers = _buildPrayers();
    _computePrayers();
    _remaining = _computeRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
  }

  @override
  void didUpdateWidget(_CountdownTimer old) {
    super.didUpdateWidget(old);
    if (old.prayerTimes != widget.prayerTimes) {
      _prayers = _buildPrayers();
      _computePrayers();
      setState(() => _remaining = _computeRemaining());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  List<_PrayerInfo> _buildPrayers() => [
    _PrayerInfo('fajr'.tr(), widget.prayerTimes.fajr),
    _PrayerInfo('dhuhr'.tr(), widget.prayerTimes.dhuhr),
    _PrayerInfo('asr'.tr(), widget.prayerTimes.asr),
    _PrayerInfo('maghrib'.tr(), widget.prayerTimes.maghrib),
    _PrayerInfo('isha'.tr(), widget.prayerTimes.isha),
  ];

  int _toMinutes(String t) {
    final parts = t.split(':');
    if (parts.length < 2) return 0;
    return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
  }

  void _computePrayers() {
    final nowMin = DateTime.now().hour * 60 + DateTime.now().minute;
    _PrayerInfo? current;
    _PrayerInfo? next;
    for (int i = 0; i < _prayers.length; i++) {
      if (nowMin >= _toMinutes(_prayers[i].time)) {
        current = _prayers[i];
        next = _prayers[(i + 1) % _prayers.length];
      }
    }
    _current = current ?? _prayers.last;
    _next = next ?? _prayers.first;
  }

  Duration _computeRemaining() {
    final now = DateTime.now();
    final nowSec = now.hour * 3600 + now.minute * 60 + now.second;
    int diffSec = _toMinutes(_next.time) * 60 - nowSec;
    if (diffSec < 0) diffSec += 86400;
    return Duration(seconds: diffSec);
  }

  void _tick(Timer _) {
    if (!mounted) return;
    _computePrayers();
    setState(() => _remaining = _computeRemaining());
  }

  String _formatCountdown(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return PrayerCountdownCard(
      currentPrayerName: _current.name,
      nextPrayerName: _next.name,
      remaining: _remaining,
      formattedCountdown: _formatCountdown(_remaining),
      circleSize: widget.circleSize,
    );
  }
}

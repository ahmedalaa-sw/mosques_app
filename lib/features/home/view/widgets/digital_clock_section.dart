import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosques_app/core/constants/app_colors.dart';

class DigitalClockSection extends StatefulWidget {
  const DigitalClockSection({super.key});

  @override
  State<DigitalClockSection> createState() => _DigitalClockSectionState();
}

class _DigitalClockSectionState extends State<DigitalClockSection> {
  Timer? _timer;

  String _formatTime(DateTime now, bool use24Hour) {
    final h = now.hour;
    final m = now.minute.toString().padLeft(2, '0');
    final s = now.second.toString().padLeft(2, '0');

    if (use24Hour) {
      final hh = h.toString().padLeft(2, '0');
      return '$hh:$m:$s';
    }

    final period = h >= 12 ? 'PM' : 'AM';
    final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$h12:$m:$s $period';
  }

  void _tick(Timer _) {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final use24Hour = MediaQuery.of(context).alwaysUse24HourFormat;
    final now = DateTime.now();
    final timeText = _formatTime(now, use24Hour);

    return Column(
      children: [
        Text(
          timeText,
          style: TextStyle(
            color: AppColor.white,
            fontSize: 48.sp,
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

import 'dart:async';
import 'dart:ui';

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

  // Store the previous callback so we can restore it on dispose.
  VoidCallback? _previousPlatformConfigCallback;

  @override
  void initState() {
    super.initState();

    // ── Live listener for 12h/24h system toggle ──────────────────────────
    // PlatformDispatcher fires this callback the moment the user flips the
    // time-format setting in the phone's System Settings — no polling needed.
    _previousPlatformConfigCallback =
        PlatformDispatcher.instance.onPlatformConfigurationChanged;

    PlatformDispatcher.instance.onPlatformConfigurationChanged = () {
      // Forward to any previously registered handler (e.g. Flutter internals).
      _previousPlatformConfigCallback?.call();
      if (mounted) setState(() {});
    };

    // ── Per-second timer to advance the clock digits ──────────────────────
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
  }

  @override
  void dispose() {
    // Restore the original callback to avoid breaking the framework.
    PlatformDispatcher.instance.onPlatformConfigurationChanged =
        _previousPlatformConfigCallback;
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  void _tick(Timer _) {
    if (mounted) setState(() {});
  }

  String _formatTime(DateTime now) {
    final use24Hour = PlatformDispatcher.instance.alwaysUse24HourFormat;
    final h = now.hour;
    final m = now.minute.toString().padLeft(2, '0');
    final s = now.second.toString().padLeft(2, '0');

    if (use24Hour) {
      return '${h.toString().padLeft(2, '0')}:$m:$s';
    }

    final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$h12:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          _formatTime(DateTime.now()),
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

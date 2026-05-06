import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosques_app/core/constants/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PrayerCountdownCard  (Task D — pure display widget)
//
// Receives all data as constructor parameters; contains zero business logic,
// zero timers, and zero Bloc references. Fully testable with hardcoded values.
//
// Parameters
// ──────────
// currentPrayerName  — e.g. "Dhuhr"
// nextPrayerName     — e.g. "Asr"
// remaining          — used to choose font size (compact for ≥ 1 hour)
// formattedCountdown — pre-formatted by PrayerCountdownSection:
//                      "MM:SS" or "H:MM:SS"
// ─────────────────────────────────────────────────────────────────────────────
class PrayerCountdownCard extends StatelessWidget {
  final String currentPrayerName;
  final String nextPrayerName;
  final Duration remaining;
  final String formattedCountdown;

  const PrayerCountdownCard({
    super.key,
    required this.currentPrayerName,
    required this.nextPrayerName,
    required this.remaining,
    required this.formattedCountdown,
  });

  @override
  Widget build(BuildContext context) {
    // Shrink the countdown font slightly when hours are present so the longer
    // string fits comfortably inside the circular container.
    final double countdownFontSize = remaining.inHours > 0 ? 30.sp : 40.sp;

    return Container(
      width: 220.w,
      height: 240.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [const Color(0xff2a4a44), AppColor.primaryColor],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff88d6c8).withOpacity(0.1),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Current prayer name ───────────────────────────────────────────
          Text(
            currentPrayerName,
            style: TextStyle(
              color: AppColor.accentTeal,
              fontSize: 36.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10.h),

          // ── ONGOING badge ─────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: AppColor.badgeGold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColor.badgeGold, width: 1),
            ),
            child: Text(
              'ongoing'.tr(),
              style: TextStyle(
                color: AppColor.badgeGold,
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
          SizedBox(height: 14.h),

          // ── "Next: X in" label ────────────────────────────────────────────
          Text(
            '${'next_prayer'.tr()}$nextPrayerName in',
            style: TextStyle(
              color: AppColor.textSecondary,
              fontSize: 13.sp,
            ),
          ),
          SizedBox(height: 6.h),

          // ── Live countdown ────────────────────────────────────────────────
          // FontFeature.tabularFigures() ensures digits are fixed-width so
          // the text does not shift horizontally as numbers change each second.
          Text(
            formattedCountdown,
            style: TextStyle(
              color: AppColor.white,
              fontSize: countdownFontSize,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
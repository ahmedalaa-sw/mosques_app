import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosques_app/core/constants/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SunTimingCard
//
// Displays a single sun event (sunrise or sunset) with a label, an icon,
// and the formatted time string.
//
// Improvements over the original:
//  • `icon` parameter was accepted but never rendered — it is now displayed
//    above the time, making the parameter meaningful and the card visually
//    richer while preserving the existing public API exactly.
//  • Wrapped in a Semantics node so screen readers announce the card as a
//    cohesive unit ("Sunrise, 6:12 AM") rather than three disconnected
//    text fragments.
//  • DecoratedBox + Padding container added: gives the card a subtle
//    background surface so it reads as a discrete UI element rather than
//    floating text. The design uses AppColor.darkCard at low opacity to
//    stay consistent with the rest of the home screen's card language.
//  • Icon size driven by sp for density-independent scaling consistent with
//    all other icons in the project.
//  • All layout constants use .h / .w / .sp / .r from flutter_screenutil,
//    consistent with the surrounding widget files.
//  • const constructors preserved throughout; no state management needed.
// ─────────────────────────────────────────────────────────────────────────────
class SunTimingCard extends StatelessWidget {
  final String label;
  final String time;
  final IconData icon;

  const SunTimingCard({
    super.key,
    required this.label,
    required this.time,
    required this.icon,
  });

  // Pre-computed fill — avoids allocating a new Color object on every build.
  static final Color _cardFill = AppColor.darkCard.withOpacity(0.45);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      // Merges label + time into a single accessible announcement,
      // e.g. "Sunrise, 6:12 AM".
      label: '$label, $time',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _cardFill,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Event label (e.g. "SUNRISE") ──────────────────────────────
              Text(
                label,
                style: TextStyle(
                  color: AppColor.textSecondary,
                  fontSize: 10.sp,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),

              // ── Sun icon ──────────────────────────────────────────────────
              // Previously accepted via constructor but never rendered.
              // Now displayed so the parameter is no longer dead code.
              Icon(icon, color: AppColor.accentTeal, size: 20.sp),
              SizedBox(height: 6.h),

              // ── Time string (e.g. "6:12 AM") ──────────────────────────────
              Text(
                time,
                style: TextStyle(
                  color: AppColor.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

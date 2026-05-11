import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosques_app/features/home/model/home_model.dart';
import 'package:mosques_app/features/home/view/widgets/prayer_countdown_section.dart';
import 'package:mosques_app/features/home/view/widgets/prayer_schedule_section.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LoadedView  (Task E — success content assembler)
//
// Shown when HomeCubit emits HomeLoaded. Composes the two main content areas:
//   1. PrayerCountdownSection — upper card with live countdown timer.
//   2. PrayerScheduleSection  — full daily prayer list.
//
// This widget contains no timer logic and no Bloc reads; it is a pure layout
// compositor that hands data to its children.
// ─────────────────────────────────────────────────────────────────────────────
class LoadedView extends StatelessWidget {
  final AladhanPrayerTimesModel prayerTimes;
  final List<PrayerModel> prayers;

  const LoadedView({
    super.key,
    required this.prayerTimes,
    required this.prayers,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            // SizedBox(height: 23.h),

            // // ── Digital clock ────────────────────────────────────────────────
            // DigitalClockSection(),

            SizedBox(height: 12.h),

            // ── Upper section: live countdown card ───────────────────────────
            // RepaintBoundary isolates the 1-second timer repaint so it does
            // not dirty the BackdropFilter blur in GlassNavBar.
            RepaintBoundary(
              child: PrayerCountdownSection(prayerTimes: prayerTimes),
            ),

            SizedBox(height: 16.h),

            // ── Lower section: full daily schedule ───────────────────────────
            PrayerScheduleSection(prayers: prayers),

            SizedBox(height: 80.h),
          ],
        ),
      ),
    );
  }
}

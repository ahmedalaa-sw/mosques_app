import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosques_app/core/constants/app_colors.dart';
import 'package:mosques_app/core/cubit/time_format_cubit.dart';
import 'package:mosques_app/core/extensions/time_format_helper.dart';
import 'package:mosques_app/features/home/model/home_model.dart';

class PrayerScheduleSection extends StatelessWidget {
  final List<PrayerModel>? prayers;

  const PrayerScheduleSection({super.key, this.prayers});

  static final List<PrayerModel> _fallbackPrayers = [
    PrayerModel(name: 'fajr'.tr(), time: '05:22 AM', icon: Icons.wb_twilight),
    PrayerModel(name: 'sunrise'.tr(), time: '06:54 AM', icon: Icons.wb_sunny),
    PrayerModel(
      name: 'dhuhr'.tr(),
      time: '01:12 PM',
      icon: Icons.wb_sunny,
      isHighlighted: true,
    ),
    PrayerModel(name: 'asr'.tr(), time: '04:38 PM', icon: Icons.wb_sunny),
    PrayerModel(name: 'maghrib'.tr(), time: '07:22 PM', icon: Icons.wb_twilight),
    PrayerModel(name: 'isha'.tr(), time: '08:44 PM', icon: Icons.nights_stay),
  ];

  @override
  Widget build(BuildContext context) {
    final effectivePrayers = prayers ?? _fallbackPrayers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(),
        SizedBox(height: 8.h),

        for (int i = 0; i < effectivePrayers.length; i++) ...[
          _PrayerRow(prayer: effectivePrayers[i]),
          if (i < effectivePrayers.length - 1) SizedBox(height: 8.h),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader();

  @override
  Widget build(BuildContext context) {
    return Text(
      'prayer_schedule'.tr(),
      style: TextStyle(
        color: AppColor.white,
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _PrayerRowTheme {
  final Color iconColor;
  final Color textColor;
  final FontWeight nameFontWeight;
  final Color backgroundColor;
  final Border? border;
  final bool showActiveDot;

  const _PrayerRowTheme({
    required this.iconColor,
    required this.textColor,
    required this.nameFontWeight,
    required this.backgroundColor,
    this.border,
    required this.showActiveDot,
  });

  factory _PrayerRowTheme.normal() => _PrayerRowTheme(
    iconColor: AppColor.textSecondary,
    textColor: AppColor.white,
    nameFontWeight: FontWeight.w500,
    backgroundColor: AppColor.primaryColor,
    showActiveDot: false,
  );

  factory _PrayerRowTheme.highlighted() => _PrayerRowTheme(
    iconColor: AppColor.accentTeal,
    textColor: AppColor.accentTeal,
    nameFontWeight: FontWeight.w600,
    backgroundColor: AppColor.darkCard,
    border: Border.all(color: AppColor.accentTeal, width: 1.5),
    showActiveDot: true,
  );
}

class _PrayerRow extends StatelessWidget {
  final PrayerModel prayer;

  const _PrayerRow({required this.prayer});

  @override
  Widget build(BuildContext context) {
    final use24Hour = context.watch<TimeFormatCubit>().state.is24Hour;
    final formattedTime = TimeFormatHelper.format(prayer.time, use24Hour);
    final theme = prayer.isHighlighted
        ? _PrayerRowTheme.highlighted()
        : _PrayerRowTheme.normal();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        border: theme.border,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Row(
          children: [
            Icon(prayer.icon, color: theme.iconColor, size: 24.sp),
            SizedBox(width: 16.w),

            Expanded(
              child: Text(
                prayer.name,
                style: TextStyle(
                  color: theme.textColor,
                  fontSize: 16.sp,
                  fontWeight: theme.nameFontWeight,
                ),
              ),
            ),

            if (theme.showActiveDot) ...[_ActiveDot(), SizedBox(width: 8.w)],

            Text(
              formattedTime,
              style: TextStyle(
                color: theme.textColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ActiveDot
//
// Small teal circle indicating the currently active prayer. Extracted so
// the parent Row reads as a clean list of siblings rather than embedding
// layout arithmetic inline.
// ─────────────────────────────────────────────────────────────────────────────
class _ActiveDot extends StatelessWidget {
  const _ActiveDot();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColor.accentTeal,
      ),
      child: SizedBox(width: 8.w, height: 8.h),
    );
  }
}


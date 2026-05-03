import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/strings_constants.dart';

class PrayerTimesCard extends StatelessWidget {
  final Map<String, String> prayerTimes;

  const PrayerTimesCard({super.key, required this.prayerTimes});

  static const List<Map<String, dynamic>> _prayerMeta = [
    {'key': 'Fajr', 'label': StringsConstants.fajr, 'icon': Icons.brightness_3_rounded},
    {'key': 'Dhuhr', 'label': StringsConstants.dhuhr, 'icon': Icons.wb_sunny_rounded},
    {'key': 'Asr', 'label': StringsConstants.asr, 'icon': Icons.wb_twilight_rounded},
    {'key': 'Maghrib', 'label': StringsConstants.maghrib, 'icon': Icons.nights_stay_rounded},
    {'key': 'Isha', 'label': StringsConstants.isha, 'icon': Icons.bedtime_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColor.primaryContainer.withValues(alpha: 0.18),
                  AppColor.surfaceVariant.withValues(alpha: 0.35),
                ],
              ),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: AppColor.primaryColor.withValues(alpha: 0.12),
              ),
            ),
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardHeader(),
                SizedBox(height: 16.h),
                ...List.generate(_prayerMeta.length, (i) {
                  final meta = _prayerMeta[i];
                  final time = prayerTimes[meta['key']] ?? '--:--';
                  final isLast = i == _prayerMeta.length - 1;
                  return Column(
                    children: [
                      _PrayerTimeRow(
                        icon: meta['icon'] as IconData,
                        label: meta['label'] as String,
                        time: time,
                      ),
                      if (!isLast)
                        Divider(
                          height: 16.h,
                          thickness: 0.5,
                          color: AppColor.outlineVariant.withValues(alpha: 0.3),
                        ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppColor.primaryColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            Icons.access_time_rounded,
            size: 18.sp,
            color: AppColor.primaryColor,
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          StringsConstants.todayPrayers,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColor.onSurface,
          ),
        ),
      ],
    );
  }
}

class _PrayerTimeRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String time;

  const _PrayerTimeRow({
    required this.icon,
    required this.label,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: AppColor.primaryColor.withValues(alpha: 0.7)),
        SizedBox(width: 12.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColor.onSurface,
          ),
        ),
        const Spacer(),
        Text(
          time,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: AppColor.primaryColor,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

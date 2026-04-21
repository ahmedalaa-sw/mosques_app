import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosques_app/core/constants/app_colors.dart';

class PrayerScheduleSection extends StatelessWidget {
  const PrayerScheduleSection({super.key});

  @override
  Widget build(BuildContext context) {
    final prayers = [
      {'name': 'Fajr', 'time': '05:22 AM', 'icon': Icons.wb_twilight},
      {'name': 'Sunrise', 'time': '06:54 AM', 'icon': Icons.wb_sunny},
      {
        'name': 'Dhuhr',
        'time': '01:12 PM',
        'icon': Icons.wb_sunny,
        'highlight': true,
      },
      {'name': 'Asr', 'time': '04:38 PM', 'icon': Icons.wb_sunny},
      {'name': 'Maghrib', 'time': '07:22 PM', 'icon': Icons.wb_twilight},
      {'name': 'Isha', 'time': '08:44 PM', 'icon': Icons.nights_stay},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Prayer Schedule',
              style: TextStyle(
                color: AppColor.onSurface,
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'Full Month',
                style: TextStyle(
                  color: AppColor.primaryColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: prayers.length,
          separatorBuilder: (_, _) => SizedBox(height: 8.h),
          itemBuilder: (context, index) {
            final prayer = prayers[index];
            final isHighlight = (prayer['highlight'] as bool?) ?? false;

            return Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: isHighlight
                    ? AppColor.surfaceContainer
                    : AppColor.surfaceContainerHigh,
                border: isHighlight
                    ? Border.all(color: AppColor.primaryColor, width: 1.5)
                    : null,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(
                    prayer['icon'] as IconData,
                    color: isHighlight
                        ? AppColor.primaryColor
                        : AppColor.onSurfaceVariant,
                    size: 24.sp,
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Text(
                      prayer['name'] as String,
                      style: TextStyle(
                        color: isHighlight
                            ? AppColor.primaryColor
                            : AppColor.onSurface,
                        fontSize: 16.sp,
                        fontWeight: isHighlight
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isHighlight)
                    Container(
                      width: 8.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColor.primaryColor,
                      ),
                    ),
                  SizedBox(width: 8.w),
                  Text(
                    prayer['time'] as String,
                    style: TextStyle(
                      color: isHighlight
                          ? AppColor.primaryColor
                          : AppColor.onSurface,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosques_app/core/constants/app_colors.dart';
import 'package:mosques_app/features/home/model/home_model.dart';

class PrayerScheduleSection extends StatelessWidget {
  final List<PrayerModel>? prayers;
  final double? latitude;
  final double? longitude;
  final String? methodName;

  const PrayerScheduleSection({
    super.key,
    this.prayers,
    this.latitude,
    this.longitude,
    this.methodName,
  });

  @override
  Widget build(BuildContext context) {
    // Use provided prayers or fallback to default
    final prayersList =
        prayers ??
        [
          PrayerModel(name: 'Fajr', time: '05:22 AM', icon: Icons.wb_twilight),
          PrayerModel(name: 'Sunrise', time: '06:54 AM', icon: Icons.wb_sunny),
          PrayerModel(
            name: 'Dhuhr',
            time: '01:12 PM',
            icon: Icons.wb_sunny,
            isHighlighted: true,
          ),
          PrayerModel(name: 'Asr', time: '04:38 PM', icon: Icons.wb_sunny),
          PrayerModel(
            name: 'Maghrib',
            time: '07:22 PM',
            icon: Icons.wb_twilight,
          ),
          PrayerModel(name: 'Isha', time: '08:44 PM', icon: Icons.nights_stay),
        ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prayer Schedule',
                  style: TextStyle(
                    color: AppColor.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (methodName != null && methodName!.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      'Method: $methodName',
                      style: TextStyle(
                        color: AppColor.textSecondary,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
              ],
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'Full Month',
                style: TextStyle(
                  color: AppColor.accentTeal,
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
          itemCount: prayersList.length,
          separatorBuilder: (context, index) => SizedBox(height: 8.h),
          itemBuilder: (context, index) {
            final prayer = prayersList[index];

            return Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: prayer.isHighlighted
                    ? AppColor.darkCard
                    : AppColor.primaryColor,
                border: prayer.isHighlighted
                    ? Border.all(color: AppColor.accentTeal, width: 1.5)
                    : null,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(
                    prayer.icon,
                    color: prayer.isHighlighted
                        ? AppColor.accentTeal
                        : AppColor.textSecondary,
                    size: 24.sp,
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Text(
                      prayer.name,
                      style: TextStyle(
                        color: prayer.isHighlighted
                            ? AppColor.accentTeal
                            : AppColor.white,
                        fontSize: 16.sp,
                        fontWeight: prayer.isHighlighted
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (prayer.isHighlighted)
                    Container(
                      width: 8.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColor.accentTeal,
                      ),
                    ),
                  SizedBox(width: 8.w),
                  Text(
                    prayer.time,
                    style: TextStyle(
                      color: prayer.isHighlighted
                          ? AppColor.accentTeal
                          : AppColor.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        // Location info if available
        if (latitude != null && longitude != null)
          Padding(
            padding: EdgeInsets.only(top: 16.h),
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColor.darkCard.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: AppColor.accentTeal,
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Lat: ${latitude!.toStringAsFixed(4)}, '
                      'Lng: ${longitude!.toStringAsFixed(4)}',
                      style: TextStyle(
                        color: AppColor.textSecondary,
                        fontSize: 11.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

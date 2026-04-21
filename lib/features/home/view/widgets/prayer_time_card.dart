import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosques_app/core/constants/app_colors.dart';
import 'sun_timing_card.dart';

class PrayerTimerCard extends StatelessWidget {
  final Duration remainingTime;

  const PrayerTimerCard({super.key, required this.remainingTime});

  String _formatTime(Duration duration) {
    int minutes = duration.inMinutes;
    int seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: Column(
        children: [
          Text(
            'NOW PRAYING',
            style: TextStyle(
              color: AppColor.onSurfaceVariant,
              fontSize: 12.sp,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            width: 300.w,
            height: 300.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [AppColor.primaryContainer, AppColor.surfaceDim],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColor.primaryColor.withValues(alpha: 0.1),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Dhuhr',
                  style: TextStyle(
                    color: AppColor.primaryColor,
                    fontSize: 48.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.secondaryColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColor.secondaryColor,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'ONGOING',
                    style: TextStyle(
                      color: AppColor.secondaryColor,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Next Prayer: Asr in',
                  style: TextStyle(
                    color: AppColor.onSurfaceVariant,
                    fontSize: 15.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: _formatTime(remainingTime),
                        style: TextStyle(
                          color: AppColor.onSurface,
                          fontSize: 56.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: '12s',
                        style: TextStyle(
                          color: AppColor.onSurfaceVariant,
                          fontSize: 18.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 40.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SunTimingCard(
                label: 'SUNRISE',
                time: '06:12 AM',
                icon: Icons.wb_sunny,
              ),
              SunTimingCard(
                label: 'SUNSET',
                time: '05:44 PM',
                icon: Icons.wb_sunny_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosques_app/core/constants/app_colors.dart';

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColor.textSecondary,
            fontSize: 10.sp,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          time,
          style: TextStyle(
            color: AppColor.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
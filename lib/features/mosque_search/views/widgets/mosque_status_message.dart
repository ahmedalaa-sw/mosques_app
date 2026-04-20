import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosques_app/core/constants/app_colors.dart';

class MosqueStatusMessage extends StatelessWidget {
  final IconData icon;
  final String label;

  const MosqueStatusMessage({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColor.onSurfaceVariant, size: 40.sp),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColor.onSurfaceVariant,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

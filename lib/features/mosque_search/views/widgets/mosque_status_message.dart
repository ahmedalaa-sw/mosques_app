import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosques_app/core/constants/app_colors.dart';

class MosqueStatusMessage extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onRetry;

  const MosqueStatusMessage({
    super.key,
    required this.icon,
    required this.label,
    this.onRetry,
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
          if (onRetry != null) ...[
            SizedBox(height: 20.h),
            TextButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh_rounded, size: 18.sp),
              label: Text('retry'.tr(), style: TextStyle(fontSize: 14.sp)),
              style: TextButton.styleFrom(
                foregroundColor: AppColor.secondaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

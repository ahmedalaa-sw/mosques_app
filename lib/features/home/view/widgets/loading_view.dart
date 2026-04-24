import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosques_app/core/constants/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LoadingView
//
// Shown for both HomeInitial and HomeLoading states.
// Stateless — no animation controller needed; CircularProgressIndicator
// manages its own animation lifecycle internally.
// ─────────────────────────────────────────────────────────────────────────────
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColor.accentTeal,
            strokeWidth: 3.w,
          ),
          SizedBox(height: 16.h),
          Text(
            'Loading prayer times...',
            style: TextStyle(
              color: AppColor.textSecondary,
              fontSize: 16.sp,
            ),
          ),
        ],
      ),
    );
  }
}
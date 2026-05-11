import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosques_app/core/constants/app_colors.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomeSkeletonView extends StatelessWidget {
  const HomeSkeletonView({super.key});

  @override
  Widget build(BuildContext context) {
    final double circleSize = MediaQuery.of(context).size.height * 0.26;

    return Skeletonizer(
      enabled: true,
      effect: const ShimmerEffect(
        baseColor: AppColor.surfaceContainerHigh,
        highlightColor: AppColor.surfaceBright,
        duration: Duration(milliseconds: 1200),
      ),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              SizedBox(height: 12.h),

              // "NOW PRAYING" label
              Center(
                child: Container(
                  width: 100.w,
                  height: 11.h,
                  decoration: BoxDecoration(
                    color: AppColor.darkCard,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
              ),
              SizedBox(height: 8.h),

              // Countdown circle
              Center(
                child: Container(
                  width: circleSize,
                  height: circleSize,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.darkCard,
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Sunrise / Sunset cards
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _SunCardSkeleton(),
                  _SunCardSkeleton(),
                ],
              ),
              SizedBox(height: 16.h),

              // Schedule section header
              Container(
                width: 140.w,
                height: 20.h,
                decoration: BoxDecoration(
                  color: AppColor.darkCard,
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
              SizedBox(height: 8.h),

              // 6 prayer rows
              for (int i = 0; i < 6; i++) ...[
                Container(
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: AppColor.darkCard,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                if (i < 5) SizedBox(height: 8.h),
              ],

              SizedBox(height: 80.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _SunCardSkeleton extends StatelessWidget {
  const _SunCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50.w,
          height: 10.h,
          decoration: BoxDecoration(
            color: AppColor.darkCard,
            borderRadius: BorderRadius.circular(5.r),
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          width: 72.w,
          height: 16.h,
          decoration: BoxDecoration(
            color: AppColor.darkCard,
            borderRadius: BorderRadius.circular(5.r),
          ),
        ),
      ],
    );
  }
}

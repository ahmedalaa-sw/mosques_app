import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/strings_constants.dart';

class MosqueAboutCard extends StatelessWidget {
  final String address;
  final String? description;

  const MosqueAboutCard({
    super.key,
    required this.address,
    this.description,
  });

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
              color: AppColor.surfaceContainerHigh.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: AppColor.outlineVariant.withValues(alpha: 0.15),
              ),
            ),
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location row
                _SectionLabel(
                  icon: Icons.location_on_rounded,
                  title: StringsConstants.location,
                ),
                SizedBox(height: 10.h),
                Text(
                  address,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColor.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                if (description != null) ...[
                  SizedBox(height: 20.h),
                  Divider(
                    height: 1,
                    color: AppColor.outlineVariant.withValues(alpha: 0.25),
                  ),
                  SizedBox(height: 20.h),
                  _SectionLabel(
                    icon: Icons.info_outline_rounded,
                    title: StringsConstants.about,
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    description!,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColor.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionLabel({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: AppColor.primaryColor),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColor.onSurface,
          ),
        ),
      ],
    );
  }
}

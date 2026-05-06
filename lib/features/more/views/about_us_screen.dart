import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mosques_app/core/constants/app_colors.dart';
import 'package:mosques_app/core/constants/app_style.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.surfaceDim,
      appBar: AppBar(
        title: Text('about_app'.tr(), style: AppStyle.semiBold18),
        backgroundColor: AppColor.appBarColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColor.primaryColor1, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            Center(
              child: Icon(Icons.mosque, color: AppColor.primaryColor1, size: 64.sp),
            ),
            SizedBox(height: 24.h),
            Center(
              child: Text(
                'app_title'.tr(),
                style: TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColor.onSurface,
                  letterSpacing: -1,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Center(
              child: Text(
                'version'.tr(),
                style: AppStyle.regular14,
              ),
            ),
            SizedBox(height: 32.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppColor.surfaceContainer,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColor.outlineVariant.withValues(alpha: 0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('about'.tr(), style: AppStyle.bold18),
                  SizedBox(height: 12.h),
                  Text(
                    'about_description'.tr(),
                    style: AppStyle.regular14.copyWith(height: 1.7),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
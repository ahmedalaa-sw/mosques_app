import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mosques_app/core/constants/app_colors.dart';
import 'package:mosques_app/core/constants/app_style.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.surfaceDim,
      appBar: AppBar(
        title: Text('contact_us'.tr(), style: AppStyle.semiBold18),
        backgroundColor: AppColor.appBarColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColor.primaryColor1, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'get_in_touch'.tr(),
              style: TextStyle(
                color: AppColor.secondaryColor,
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
              ),
            ),
            SizedBox(height: 16.h),
            _ContactCard(
              icon: Icons.email_outlined,
              title: 'email_label'.tr(),
              subtitle: 'email_address'.tr(),
            ),
            SizedBox(height: 12.h),
            _ContactCard(
              icon: Icons.language,
              title: 'website_label'.tr(),
              subtitle: 'website_url'.tr(),
            ),
            SizedBox(height: 12.h),
            _ContactCard(
              icon: Icons.feedback_outlined,
              title: 'feedback_label'.tr(),
              subtitle: 'feedback_subtitle'.tr(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.surfaceContainer,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColor.outlineVariant.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColor.primaryColor1, size: 24.sp),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppStyle.medium16.copyWith(color: AppColor.onSurface)),
                SizedBox(height: 2.h),
                Text(subtitle, style: AppStyle.regular14),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColor.outlineVariant, size: 20.sp),
        ],
      ),
    );
  }
}
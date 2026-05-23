import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mosques_app/core/constants/app_colors.dart';
import 'package:mosques_app/core/constants/app_style.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.of(context, rootNavigator: true).pop();
      },
      child: Scaffold(
        backgroundColor: AppColor.surfaceDim,
        appBar: AppBar(
          title: Text('privacy_policy'.tr(), style: AppStyle.semiBold18),
          backgroundColor: AppColor.appBarColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: AppColor.primaryColor1,
              size: 20.sp,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Icon
              Center(
                child: Icon(
                  Icons.privacy_tip_outlined,
                  color: AppColor.primaryColor1,
                  size: 64.sp,
                ),
              ),
              SizedBox(height: 24.h),

              // Main Title
              Center(
                child: Text(
                  'privacy_policy'.tr(),
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

              // Last Updated
              Center(
                child: Text(
                  'privacy_last_updated'.tr(),
                  style: AppStyle.regular12.copyWith(
                    color: AppColor.onSurfaceVariant,
                  ),
                ),
              ),
              SizedBox(height: 32.h),

              // Privacy Policy Content
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: AppColor.surfaceContainer,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: AppColor.outlineVariant.withValues(alpha: 0.15),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Introduction
                    _PolicySection(
                      title: 'privacy_intro_title'.tr(),
                      content: 'privacy_intro_content'.tr(),
                    ),
                    SizedBox(height: 24.h),

                    // Data Collection
                    _PolicySection(
                      title: 'privacy_data_collection_title'.tr(),
                      content: 'privacy_data_collection_content'.tr(),
                      bulletPoints: [
                        'privacy_bullet_location'.tr(),
                        'privacy_bullet_preferences'.tr(),
                        'privacy_bullet_favorites'.tr(),
                      ],
                    ),
                    SizedBox(height: 24.h),

                    // Data Usage
                    _PolicySection(
                      title: 'privacy_data_usage_title'.tr(),
                      content: 'privacy_data_usage_content'.tr(),
                      bulletPoints: [
                        'privacy_bullet_prayer_times'.tr(),
                        'privacy_bullet_mosques'.tr(),
                        'privacy_bullet_notifications'.tr(),
                      ],
                    ),
                    SizedBox(height: 24.h),

                    // Data Security
                    _PolicySection(
                      title: 'privacy_data_security_title'.tr(),
                      content: 'privacy_data_security_content'.tr(),
                    ),
                    SizedBox(height: 24.h),

                    // Third Party Services
                    _PolicySection(
                      title: 'privacy_third_party_title'.tr(),
                      content: 'privacy_third_party_content'.tr(),
                      bulletPoints: [
                        'privacy_bullet_google_places'.tr(),
                        'privacy_bullet_google_maps'.tr(),
                      ],
                    ),
                    SizedBox(height: 24.h),

                    // User Rights
                    _PolicySection(
                      title: 'privacy_user_rights_title'.tr(),
                      content: 'privacy_user_rights_content'.tr(),
                    ),
                    SizedBox(height: 24.h),

                    // Contact
                    _PolicySection(
                      title: 'privacy_contact_title'.tr(),
                      content: 'privacy_contact_content'.tr(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),

              // Acceptance Notice
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColor.primaryContainer.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColor.primaryColor1.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  'privacy_acceptance'.tr(),
                  style: AppStyle.regular12.copyWith(
                    color: AppColor.onSurfaceVariant,
                    height: 1.6,
                  ),
                ),
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String content;
  final List<String>? bulletPoints;

  const _PolicySection({
    required this.title,
    required this.content,
    this.bulletPoints,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppStyle.bold18.copyWith(color: AppColor.primaryColor1),
        ),
        SizedBox(height: 12.h),
        Text(
          content,
          style: AppStyle.regular14.copyWith(
            color: AppColor.onSurface,
            height: 1.7,
          ),
        ),
        if (bulletPoints != null && bulletPoints!.isNotEmpty) ...[
          SizedBox(height: 16.h),
          ...bulletPoints!.map((point) => _BulletPoint(text: point)),
        ],
      ],
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;

  const _BulletPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 4.h, right: 12.w, left: 4.w),
            child: Container(
              width: 6.w,
              height: 6.h,
              decoration: BoxDecoration(
                color: AppColor.primaryColor1,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: AppStyle.regular14.copyWith(
                color: AppColor.onSurface,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:mosques_app/core/constants/app_colors.dart';
import 'package:mosques_app/core/constants/app_style.dart';

class SupportCenterScreen extends StatelessWidget {
  const SupportCenterScreen({super.key});

  Future<void> _launchEmail(String email, {String? subject}) async {
    try {
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: email,
        queryParameters: {if (subject != null) 'subject': subject},
      );
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        debugPrint('Could not launch email');
      }
    } catch (e) {
      debugPrint('Error launching email: $e');
    }
  }

  Future<String> _getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return 'v${packageInfo.version}';
    } catch (e) {
      return 'v1.0.0';
    }
  }

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
          title: Text('support_center'.tr(), style: AppStyle.semiBold18),
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
                  Icons.support_agent,
                  color: AppColor.primaryColor1,
                  size: 64.sp,
                ),
              ),
              SizedBox(height: 24.h),

              // Main Title
              Center(
                child: Text(
                  'support_center'.tr(),
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

              // Subtitle
              Center(
                child: Text(
                  'support_subtitle'.tr(),
                  textAlign: TextAlign.center,
                  style: AppStyle.regular14.copyWith(
                    color: AppColor.onSurfaceVariant,
                    height: 1.6,
                  ),
                ),
              ),
              SizedBox(height: 32.h),

              // Contact Information Section
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
                    Text(
                      'support_contact_title'.tr(),
                      style: AppStyle.bold18.copyWith(
                        color: AppColor.primaryColor1,
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Support Email
                    _EmailTile(
                      icon: Icons.support,
                      label: 'support_email_label'.tr(),
                      email: 'ahmedalaa10204@gmail.com',
                      description: 'support_email_desc'.tr(),
                      onTap: () async {
                        final version = await _getAppVersion();
                        _launchEmail(
                          'ahmedalaa10204@gmail.com',
                          subject: 'Mosques App Support - $version',
                        );
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Developer Email
                    _EmailTile(
                      icon: Icons.code,
                      label: 'dev_email_label'.tr(),
                      email: 'tarekmohammedgg@gmail.com',
                      description: 'dev_email_desc'.tr(),
                      onTap: () async {
                        final version = await _getAppVersion();
                        _launchEmail(
                          'tarekmohammedgg@gmail.com',
                          subject: 'Bug Report - Mosques App $version',
                        );
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Feedback Email
                    _EmailTile(
                      icon: Icons.feedback,
                      label: 'feedback_email_label'.tr(),
                      email: 'elkassas380@gmail.com',
                      description: 'feedback_email_desc'.tr(),
                      onTap: () async {
                        final version = await _getAppVersion();
                        _launchEmail(
                          'elkassas380@gmail.com',
                          subject: 'Feedback - Mosques App $version',
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // How to Report Bugs
              _InfoCard(
                icon: Icons.bug_report,
                title: 'support_report_bugs_title'.tr(),
                content: 'support_report_bugs_content'.tr(),
              ),
              SizedBox(height: 16.h),

              // How to Suggest Features
              _InfoCard(
                icon: Icons.lightbulb,
                title: 'support_suggest_features_title'.tr(),
                content: 'support_suggest_features_content'.tr(),
              ),
              SizedBox(height: 16.h),

              // Response Time
              _InfoCard(
                icon: Icons.schedule,
                title: 'support_response_time_title'.tr(),
                content: 'support_response_time_content'.tr(),
              ),
              SizedBox(height: 32.h),

              // Thank You Message
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
                  'support_thank_you'.tr(),
                  textAlign: TextAlign.center,
                  style: AppStyle.regular12.copyWith(
                    color: AppColor.onSurfaceVariant,
                    height: 1.6,
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Response Time

              // Thank You Message
            ],
          ),
        ),
      ),
    );
  }
}

class _EmailTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final String email;
  final String description;
  final VoidCallback onTap;

  const _EmailTile({
    required this.icon,
    required this.label,
    required this.email,
    required this.description,
    required this.onTap,
  });

  @override
  State<_EmailTile> createState() => _EmailTileState();
}

class _EmailTileState extends State<_EmailTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        splashColor: AppColor.primaryColor1.withValues(alpha: 0.1),
        highlightColor: AppColor.primaryColor1.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: _isPressed
                ? AppColor.surfaceContainerHigh.withValues(alpha: 0.5)
                : AppColor.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColor.outlineVariant.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor1.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      widget.icon,
                      color: AppColor.primaryColor1,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.label,
                          style: AppStyle.semiBold14.copyWith(
                            color: AppColor.onSurface,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          widget.email,
                          style: AppStyle.regular12.copyWith(
                            color: AppColor.primaryColor1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_outward,
                    color: AppColor.primaryColor1,
                    size: 18.sp,
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                widget.description,
                style: AppStyle.regular12.copyWith(
                  color: AppColor.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.surfaceContainer,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColor.outlineVariant.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColor.accentTeal, size: 24.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  style: AppStyle.bold16.copyWith(color: AppColor.onSurface),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            content,
            style: AppStyle.regular14.copyWith(
              color: AppColor.onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

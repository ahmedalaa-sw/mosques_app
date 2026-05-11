import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mosques_app/core/constants/app_colors.dart';
import 'package:mosques_app/core/constants/app_style.dart';
import 'package:mosques_app/core/routing/routes.dart';

class LocalizationScreen extends StatelessWidget {
  const LocalizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.surfaceDim,
      appBar: AppBar(
        title: Text('language'.tr(), style: AppStyle.semiBold18),
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
              'select_language'.tr(),
              style: TextStyle(
                color: AppColor.secondaryColor,
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              decoration: BoxDecoration(
                color: AppColor.surfaceContainer,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColor.outlineVariant.withValues(alpha: 0.15)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Column(
                  children: [
                    _LanguageOption(
                      nativeName: 'English',
                      code: 'en',
                      isSelected: context.locale.languageCode == 'en',
                      onTap: () {
                        context.setLocale(const Locale('en'));
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          Routes.bottomNavScreen,
                          (route) => false,
                        );
                      },
                    ),
                    _DividerLine(),
                    _LanguageOption(
                      nativeName: 'العربية',
                      code: 'ar',
                      isSelected: context.locale.languageCode == 'ar',
                      onTap: () {
                        context.setLocale(const Locale('ar'));
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          Routes.bottomNavScreen,
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String nativeName;
  final String code;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.nativeName,
    required this.code,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          color: isSelected ? AppColor.primaryContainer.withValues(alpha: 0.3) : Colors.transparent,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  nativeName,
                  style: AppStyle.medium16.copyWith(
                    color: isSelected ? AppColor.primaryColor1 : AppColor.onSurface,
                  ),
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: AppColor.primaryColor1, size: 22.sp),
            ],
          ),
        ),
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(height: 1, color: AppColor.outlineVariant.withValues(alpha: 0.15)),
    );
  }
}
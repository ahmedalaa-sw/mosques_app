import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mosques_app/core/constants/app_colors.dart';
import 'package:mosques_app/core/constants/app_style.dart';
import 'package:mosques_app/features/more/viewmodels/theme_cubit.dart';
import 'package:mosques_app/features/more/viewmodels/theme_state.dart';

class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.surfaceDim,
      appBar: AppBar(
        title: Text('theme_mode'.tr(), style: AppStyle.semiBold18),
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
              'appearance'.tr(),
              style: TextStyle(
                color: AppColor.secondaryColor,
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
              ),
            ),
            SizedBox(height: 16.h),
            BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, state) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppColor.surfaceContainer,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColor.outlineVariant.withValues(alpha: 0.15)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Column(
                      children: [
                        _ThemeOption(
                          icon: Icons.dark_mode,
                          title: 'dark_mode'.tr(),
                          isSelected: state.isDark,
                          onTap: () {
                            if (!state.isDark) context.read<ThemeCubit>().toggleTheme();
                          },
                        ),
                        _ThemeDivider(),
                        _ThemeOption(
                          icon: Icons.light_mode,
                          title: 'light_mode'.tr(),
                          isSelected: !state.isDark,
                          onTap: () {
                            if (state.isDark) context.read<ThemeCubit>().toggleTheme();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.title,
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
              Icon(icon, color: AppColor.primaryColor1, size: 24.sp),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(title, style: AppStyle.medium16.copyWith(
                  color: isSelected ? AppColor.primaryColor1 : AppColor.onSurface,
                )),
              ),
              if (isSelected) Icon(Icons.check_circle, color: AppColor.primaryColor1, size: 22.sp),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(height: 1, color: AppColor.outlineVariant.withValues(alpha: 0.15)),
    );
  }
}
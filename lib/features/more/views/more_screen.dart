import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:mosques_app/core/constants/app_colors.dart';
import 'package:mosques_app/core/constants/app_style.dart';
import 'package:mosques_app/core/routing/routes.dart';
import 'package:mosques_app/core/utils/app_shared_preferences.dart';
import 'package:mosques_app/features/more/viewmodels/azan_cubit.dart';
import 'package:mosques_app/features/more/viewmodels/azan_state.dart';
import 'package:mosques_app/features/home/view/cubit/home_cubit.dart';
import 'package:mosques_app/features/onboarding/viewmodels/onboarding_cubit.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.surfaceDim,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'app_title'.tr(),
          style: TextStyle(
            color: AppColor.primaryColor1,
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            fontFamily: 'IBMPlexSansArabic',
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColor.appBarColor.withValues(alpha: 0.8),
        elevation: 0,
        scrolledUnderElevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: AppColor.appBarColor.withValues(alpha: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.06),
                    blurRadius: 40,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.3),
            radius: 1.2,
            colors: [Color(0xFF192120), AppColor.surfaceDim],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 120.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _HeaderSection(),
                SizedBox(height: 32.h),
                _PreferencesGroup(),
                SizedBox(height: 24.h),
                _HelpInfoGroup(),
                SizedBox(height: 16.h),
                SizedBox(height: 32.h),
                _VersionFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 8.h),
        Text(
          'settings_and_more'.tr(),
          style: TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            fontSize: 32.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.5,
            color: AppColor.onSurface,
            height: 1.1,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'settings_subtitle'.tr(),
          textAlign: TextAlign.center,
          style: AppStyle.regular14.copyWith(height: 1.5),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Text(
        title,
        style: TextStyle(
          color: AppColor.secondaryColor,
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 2.0,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.surfaceContainer,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColor.outlineVariant.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Column(children: children),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.icon,
    required this.title,
    this.iconColor = AppColor.primaryColor1,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColor.surfaceContainerHigh.withValues(alpha: 0.3),
        highlightColor: AppColor.surfaceContainerHigh.withValues(alpha: 0.3),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 24.sp),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  title,
                  style: AppStyle.medium16.copyWith(color: AppColor.onSurface),
                ),
              ),
              trailing,
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
      child: Container(
        height: 1,
        color: AppColor.outlineVariant.withValues(alpha: 0.15),
      ),
    );
  }
}

class _PreferencesGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(title: 'preferences'.tr()),
        SizedBox(height: 12.h),
        _SectionCard(
          children: [
            _LanguageRow(),
            _DividerLine(),
            // _ThemeToggleRow(),
            _DividerLine(),
            _AzanToggleRow(),
            _DividerLine(),
            _LocationRow(),
          ],
        ),
      ],
    );
  }
}

class _LanguageRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final langName = context.locale.languageCode == 'ar'
        ? 'arabic'.tr()
        : 'english'.tr();
    return _SettingsRow(
      icon: Icons.translate,
      title: 'language'.tr(),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            langName,
            style: AppStyle.regular14.copyWith(
              color: AppColor.onSurfaceVariant,
            ),
          ),
          SizedBox(width: 4.w),
          Icon(
            Icons.chevron_right,
            color: AppColor.outlineVariant,
            size: 20.sp,
          ),
        ],
      ),
      onTap: () => Navigator.of(
        context,
        rootNavigator: true,
      ).pushNamed(Routes.localization),
    );
  }
}

// class _ThemeToggleRow extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
//       child: Row(
//         children: [
//           Icon(Icons.dark_mode, color: AppColor.primaryColor1, size: 24.sp),
//           SizedBox(width: 16.w),
//           Expanded(
//             child: Text(
//               'theme_mode'.tr(),
//               style: AppStyle.medium16.copyWith(color: AppColor.onSurface),
//             ),
//           ),
//           BlocBuilder<ThemeCubit, ThemeState>(
//             builder: (context, state) {
//               return _ThemeSwitch(
//                 value: state.isDark,
//                 onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _ThemeSwitch extends StatelessWidget {
//   final bool value;
//   final ValueChanged<bool> onChanged;

//   const _ThemeSwitch({required this.value, required this.onChanged});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => onChanged(!value),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 250),
//         curve: Curves.easeInOut,
//         width: 48.w,
//         height: 24.h,
//         decoration: BoxDecoration(
//           color: value ? AppColor.primaryContainer : AppColor.outlineVariant,
//           borderRadius: BorderRadius.circular(12.r),
//         ),
//         child: AnimatedAlign(
//           duration: const Duration(milliseconds: 250),
//           curve: Curves.easeInOut,
//           alignment: value ? Alignment.centerRight : Alignment.centerLeft,
//           child: Container(
//             width: 16.w,
//             height: 16.h,
//             margin: EdgeInsets.symmetric(horizontal: 4.w),
//             decoration: BoxDecoration(
//               color: AppColor.primaryColor1,
//               shape: BoxShape.circle,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

class _LocationRow extends StatefulWidget {
  @override
  State<_LocationRow> createState() => _LocationRowState();
}

class _LocationRowState extends State<_LocationRow> {
  String? _cityName;
  String? _cityNameAr;
  String? _countryName;
  String? _countryNameAr;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cityEn = await AppPreferences.getString(
      OnboardingCubit.kCachedCityName,
    );
    final cityAr = await AppPreferences.getString(
      OnboardingCubit.kCachedCityNameAr,
    );
    final countryEn = await AppPreferences.getString(
      OnboardingCubit.kCachedCountryName,
    );
    final countryAr = await AppPreferences.getString(
      OnboardingCubit.kCachedCountryNameAr,
    );
    if (mounted) {
      setState(() {
        _cityName = cityEn;
        _cityNameAr = cityAr;
        _countryName = countryEn;
        _countryNameAr = countryAr;
      });
    }
  }

  String _locationLabel(BuildContext context) {
    final isAr = context.locale.languageCode == 'ar';
    final city = isAr ? (_cityNameAr ?? _cityName) : _cityName;
    final country = isAr ? (_countryNameAr ?? _countryName) : _countryName;
    final separator = isAr ? '، ' : ', ';
    if (city != null && country != null) return '$city$separator$country';
    if (city != null) return city;
    return 'prayer_location_auto'.tr();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final homeCubit = context.read<HomeCubit>();
          final changed = await Navigator.of(
            context,
            rootNavigator: true,
          ).pushNamed(Routes.changeLocation);
          if (changed == true && mounted) {
            _load();
            homeCubit.refreshAfterManualLocationChange();
          }
        },
        splashColor: AppColor.surfaceContainerHigh.withValues(alpha: 0.3),
        highlightColor: AppColor.surfaceContainerHigh.withValues(alpha: 0.3),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: AppColor.primaryColor1,
                size: 24.sp,
              ),
              SizedBox(width: 16.w),
              Text(
                'prayer_location'.tr(),
                style: AppStyle.medium16.copyWith(color: AppColor.onSurface),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  _locationLabel(context),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.end,
                  style: AppStyle.regular14.copyWith(
                    color: AppColor.onSurfaceVariant,
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Icon(
                Icons.chevron_right,
                color: AppColor.outlineVariant,
                size: 20.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HelpInfoGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(title: 'help_and_info'.tr()),
        SizedBox(height: 12.h),
        _SectionCard(
          children: [
            _SettingsRow(
              icon: Icons.help_center_outlined,
              title: 'support_center'.tr(),
              iconColor: AppColor.accentTeal,
              trailing: Icon(
                Icons.open_in_new,
                color: AppColor.outlineVariant,
                size: 20.sp,
              ),
              onTap: () => Navigator.of(
                context,
                rootNavigator: true,
              ).pushNamed(Routes.supportCenter),
            ),
            _DividerLine(),
            _SettingsRow(
              icon: Icons.info_outline,
              title: 'about_app'.tr(),
              iconColor: AppColor.accentTeal,
              trailing: Icon(
                Icons.chevron_right,
                color: AppColor.outlineVariant,
                size: 20.sp,
              ),
              onTap: () => Navigator.of(
                context,
                rootNavigator: true,
              ).pushNamed(Routes.aboutUs),
            ),
            _DividerLine(),
            _SettingsRow(
              icon: Icons.policy_outlined,
              title: 'privacy_policy'.tr(),
              iconColor: AppColor.accentTeal,
              trailing: Icon(
                Icons.chevron_right,
                color: AppColor.outlineVariant,
                size: 20.sp,
              ),
              onTap: () => Navigator.of(
                context,
                rootNavigator: true,
              ).pushNamed(Routes.privacyPolicy),
            ),
          ],
        ),
      ],
    );
  }
}

class _VersionFooter extends StatefulWidget {
  @override
  State<_VersionFooter> createState() => _VersionFooterState();
}

class _VersionFooterState extends State<_VersionFooter> {
  String _versionString = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _versionString = 'v${packageInfo.version}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          _versionString.isEmpty ? 'version'.tr() : _versionString,
          style: TextStyle(
            color: AppColor.onSurfaceVariant.withValues(alpha: 0.6),
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            letterSpacing: 2.5,
          ),
        ),
        SizedBox(height: 4.h),
        // Text(
        //   'tagline'.tr(),
        //   style: TextStyle(
        //     color: AppColor.onSurfaceVariant.withValues(alpha: 0.3),
        //     fontSize: 10.sp,
        //   ),
        // ),
      ],
    );
  }
}

class _AzanToggleRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        children: [
          Icon(
            Icons.notifications_active,
            color: AppColor.primaryColor1,
            size: 24.sp,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              'azan_sound'.tr(),
              style: AppStyle.medium16.copyWith(color: AppColor.onSurface),
            ),
          ),
          BlocBuilder<AzanCubit, AzanState>(
            builder: (context, state) {
              return _AzanSwitch(
                value: state.isAzanEnabled,
                onChanged: (_) => context.read<AzanCubit>().toggleAzan(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AzanSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _AzanSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 48.w,
        height: 24.h,
        decoration: BoxDecoration(
          color: value ? AppColor.primaryContainer : AppColor.outlineVariant,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 16.w,
            height: 16.h,
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            decoration: BoxDecoration(
              color: AppColor.primaryColor1,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/strings_constants.dart';
import '../../../../core/functions/snakebar_function.dart';
import '../../models/mosque_detail_model.dart';

class MosqueActionButtons extends StatelessWidget {
  final MosqueDetailModel mosque;

  const MosqueActionButtons({super.key, required this.mosque});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          // Primary CTA: Directions (gold gradient)
          Expanded(
            flex: 3,
            child: _PrimaryActionButton(
              icon: Icons.directions_rounded,
              label: StringsConstants.getDirections,
              onTap: () => _openDirections(context),
            ),
          ),
          SizedBox(width: 10.w),
          if (mosque.phoneNumber != null) ...[
            Expanded(
              flex: 2,
              child: _SecondaryActionButton(
                icon: Icons.call_rounded,
                label: StringsConstants.callMosque,
                onTap: () {
                  // TODO: launch tel: URL
                },
              ),
            ),
            SizedBox(width: 10.w),
          ],
          if (mosque.website != null)
            Expanded(
              flex: 2,
              child: _SecondaryActionButton(
                icon: Icons.language_rounded,
                label: StringsConstants.website,
                onTap: () {
                  // TODO: launch website URL
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openDirections(BuildContext context) async {
    final googleMapsUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${mosque.latitude},${mosque.longitude}',
    );
    final nativeGoogleMapsUri = Theme.of(context).platform == TargetPlatform.iOS
        ? Uri.parse(
            'comgooglemaps://?daddr=${mosque.latitude},${mosque.longitude}&directionsmode=driving',
          )
        : Uri.parse('google.navigation:q=${mosque.latitude},${mosque.longitude}');

    final launchedNative = await launchUrl(
      nativeGoogleMapsUri,
      mode: LaunchMode.externalApplication,
    );
    if (launchedNative) {
      return;
    }

    final launchedWeb = await launchUrl(
      googleMapsUri,
      mode: LaunchMode.externalApplication,
    );
    if (launchedWeb) {
      return;
    }

    if (context.mounted) {
      snackBarMessage(
        context: context,
        text: StringsConstants.openMapsError,
      );
    }
  }
}

class _PrimaryActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PrimaryActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50.h,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColor.primaryContainer, AppColor.primaryColor],
          ),
          borderRadius: BorderRadius.circular(50.r),
          boxShadow: [
            BoxShadow(
              color: AppColor.primaryColor.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18.sp, color: AppColor.onPrimary),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColor.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class _SecondaryActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SecondaryActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 50.h,
            decoration: BoxDecoration(
              color: AppColor.surfaceContainerHighest.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(50.r),
              border: Border.all(
                color: AppColor.outlineVariant.withValues(alpha: 0.25),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18.sp, color: AppColor.primaryColor),
                SizedBox(height: 2.h),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColor.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

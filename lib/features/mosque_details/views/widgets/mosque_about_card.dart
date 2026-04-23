import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/strings_constants.dart';

class MosqueAboutCard extends StatelessWidget {
  final List<String> amenities;
  final String address;
  final String? description;

  const MosqueAboutCard({
    super.key,
    required this.amenities,
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
                _SectionLabel(
                  icon: Icons.accessibility_new_rounded,
                  title: StringsConstants.supports,
                ),
                SizedBox(height: 10.h),
                if (amenities.isNotEmpty)
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: amenities
                        .map((amenity) => _AmenityChip(label: amenity))
                        .toList(),
                  )
                else
                  _AmenitiesUnavailableCard(),
                SizedBox(height: 20.h),
                Divider(
                  height: 1,
                  color: AppColor.outlineVariant.withValues(alpha: 0.25),
                ),
                SizedBox(height: 20.h),
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

class _AmenitiesUnavailableCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColor.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColor.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18.sp,
            color: AppColor.onSurfaceVariant,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              StringsConstants.amenitiesNotAvailable,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppColor.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmenityChip extends StatelessWidget {
  final String label;

  const _AmenityChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColor.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColor.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_amenityIcon(label), size: 16.sp, color: AppColor.primaryColor),
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColor.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  IconData _amenityIcon(String amenity) {
    switch (amenity.toLowerCase()) {
      case 'accessible':
        return Icons.accessible_rounded;
      case 'parking':
        return Icons.local_parking_rounded;
      case 'prayer room':
        return Icons.mosque_rounded;
      case 'wudu':
        return Icons.water_drop_rounded;
      default:
        return Icons.check_circle_outline_rounded;
    }
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

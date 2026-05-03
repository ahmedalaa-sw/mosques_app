import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/strings_constants.dart';
import '../../models/mosque_detail_model.dart';

class MosqueInfoSection extends StatelessWidget {
  final MosqueDetailModel mosque;

  const MosqueInfoSection({super.key, required this.mosque});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.h),
          _StatusAndRatingRow(mosque: mosque),
          SizedBox(height: 14.h),
          _StatChipsRow(mosque: mosque),
        ],
      ),
    );
  }
}

class _StatusAndRatingRow extends StatelessWidget {
  final MosqueDetailModel mosque;
  const _StatusAndRatingRow({required this.mosque});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Open / Closed badge
        _GlassBadge(
          label: mosque.statusLabel,
          color: _statusColor(),
        ),
        if (mosque.rating > 0) ...[
          SizedBox(width: 10.w),
          Icon(
            Icons.star_rounded,
            size: 16.sp,
            color: AppColor.secondaryColor,
          ),
          SizedBox(width: 4.w),
          Text(
            mosque.rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColor.onSurface,
            ),
          ),
        ],
      ],
    );
  }

  Color _statusColor() {
    if (mosque.isOpenNow == true) return AppColor.primaryColor1;
    if (mosque.isOpenNow == false) return AppColor.errorColor;
    if (mosque.statusLabel == StringsConstants.statusNotValid) {
      return AppColor.secondaryColor;
    }
    return AppColor.onSurfaceVariant;
  }
}

class _StatChipsRow extends StatelessWidget {
  final MosqueDetailModel mosque;
  const _StatChipsRow({required this.mosque});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatChip(
          icon: Icons.location_on_rounded,
          label:
              '${mosque.distanceKm.toStringAsFixed(1)} ${StringsConstants.km}',
        ),
        SizedBox(width: 10.w),
        if (mosque.capacity != null) ...[
          _StatChip(
            icon: Icons.people_rounded,
            label:
                '${_formatCapacity(mosque.capacity!)} ${StringsConstants.worshippers}',
          ),
        ],
      ],
    );
  }

  String _formatCapacity(int capacity) => capacity >= 1000
      ? '${(capacity / 1000).toStringAsFixed(1)}k'
      : '$capacity';
}

class _GlassBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _GlassBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(50.r),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6.w,
                height: 6.w,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColor.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(50.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: AppColor.primaryColor),
          SizedBox(width: 5.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppColor.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

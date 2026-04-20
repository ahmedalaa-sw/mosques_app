import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosques_app/core/constants/app_colors.dart';
import 'package:mosques_app/features/mosque_search/models/mosque_model.dart';

class MosqueCard extends StatelessWidget {
  final MosqueModel mosque;

  const MosqueCard({super.key, required this.mosque});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColor.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MosqueIconBox(),
          SizedBox(width: 12.w),
          Expanded(child: _MosqueInfo(mosque: mosque)),
          SizedBox(width: 8.w),
          _RatingBadge(rating: mosque.rating),
        ],
      ),
    );
  }
}

class _MosqueIconBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76.w,
      height: 76.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.primaryContainer,
            AppColor.surfaceContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Icon(
        Icons.mosque_rounded,
        color: AppColor.primaryColor,
        size: 36.sp,
      ),
    );
  }
}

class _MosqueInfo extends StatelessWidget {
  final MosqueModel mosque;

  const _MosqueInfo({required this.mosque});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 2.h),
        Text(
          mosque.name,
          style: TextStyle(
            color: AppColor.onSurface,
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            height: 1.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 6.h),
        Row(
          children: [
            Icon(
              Icons.near_me_rounded,
              color: AppColor.onSurfaceVariant,
              size: 13.sp,
            ),
            SizedBox(width: 4.w),
            Text(
              mosque.distanceLabel,
              style: TextStyle(
                color: AppColor.onSurfaceVariant,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        _StatusRow(mosque: mosque),
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  final MosqueModel mosque;

  const _StatusRow({required this.mosque});

  @override
  Widget build(BuildContext context) {
    final badges = <Widget>[];

    if (mosque.isOpen) {
      badges.add(_Chip(label: 'OPEN', color: AppColor.primaryColor));
    }

    for (final amenity in mosque.amenities) {
      badges.add(SizedBox(width: 6.w));
      badges.add(
        _Chip(label: amenity.toUpperCase(), color: AppColor.onSurfaceVariant),
      );
    }

    if (badges.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6.w,
      runSpacing: 4.h,
      children: badges,
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.6), width: 1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final double rating;

  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, color: AppColor.secondaryColor, size: 14.sp),
        SizedBox(width: 2.w),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            color: AppColor.secondaryColor,
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

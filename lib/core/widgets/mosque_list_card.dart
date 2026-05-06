import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosques_app/core/constants/app_colors.dart';

class MosqueListCard extends StatelessWidget {
  final String name;
  final String distanceLabel;
  final String statusLabel;
  final Color statusColor;
  final List<String> amenities;
  final String? imageUrl;
  final VoidCallback onTap;
  final Widget? trailing;

  const MosqueListCard({
    super.key,
    required this.name,
    required this.distanceLabel,
    required this.statusLabel,
    required this.statusColor,
    required this.amenities,
    required this.onTap,
    this.imageUrl,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Ink(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColor.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MosqueIconBox(imageUrl: imageUrl),
              SizedBox(width: 12.w),
              Expanded(
                child: _MosqueInfo(
                  name: name,
                  distanceLabel: distanceLabel,
                  statusLabel: statusLabel,
                  statusColor: statusColor,
                  amenities: amenities,
                ),
              ),
              if (trailing != null) ...[
                SizedBox(width: 8.w),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MosqueIconBox extends StatelessWidget {
  final String? imageUrl;

  const _MosqueIconBox({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        width: 76.w,
        height: 76.w,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColor.primaryContainer, AppColor.surfaceContainer],
          ),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: imageUrl != null
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) =>
                    progress == null ? child : _fallbackIcon(),
                errorBuilder: (context, error, stackTrace) => _fallbackIcon(),
              )
            : _fallbackIcon(),
      ),
    );
  }

  Widget _fallbackIcon() => Center(
    child: Icon(
      Icons.mosque_rounded,
      color: AppColor.primaryColor,
      size: 36.sp,
    ),
  );
}

class _MosqueInfo extends StatelessWidget {
  final String name;
  final String distanceLabel;
  final String statusLabel;
  final Color statusColor;
  final List<String> amenities;

  const _MosqueInfo({
    required this.name,
    required this.distanceLabel,
    required this.statusLabel,
    required this.statusColor,
    required this.amenities,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 2.h),
        Text(
          name,
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
              distanceLabel,
              style: TextStyle(
                color: AppColor.onSurfaceVariant,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        _StatusRow(
          statusLabel: statusLabel,
          statusColor: statusColor,
          amenities: amenities,
        ),
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String statusLabel;
  final Color statusColor;
  final List<String> amenities;

  const _StatusRow({
    required this.statusLabel,
    required this.statusColor,
    required this.amenities,
  });

  @override
  Widget build(BuildContext context) {
    final badges = <Widget>[
      _Chip(label: statusLabel.tr(), color: statusColor),
    ];

    for (final amenity in amenities) {
      badges.add(
        _Chip(label: amenity.tr(), color: AppColor.onSurfaceVariant),
      );
    }

    return Wrap(spacing: 6.w, runSpacing: 4.h, children: badges);
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

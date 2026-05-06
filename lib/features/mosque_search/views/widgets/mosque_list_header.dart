import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosques_app/core/constants/app_colors.dart';

class MosqueListHeader extends StatelessWidget {
  final int count;

  const MosqueListHeader({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'nearby_sanctuaries'.tr(),
          style: TextStyle(
            color: AppColor.onSurface,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          'found_count'.tr(args: ['$count']),
          style: TextStyle(
            color: AppColor.onSurfaceVariant,
            fontSize: 13.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

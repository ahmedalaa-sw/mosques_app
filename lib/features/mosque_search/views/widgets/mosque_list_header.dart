import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosques_app/core/constants/app_colors.dart';
import 'package:mosques_app/core/constants/app_strings.dart';

class MosqueListHeader extends StatelessWidget {
  final int count;

  const MosqueListHeader({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppStrings.nearbySanctuaries,
          style: TextStyle(
            color: AppColor.onSurface,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          '$count found',
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

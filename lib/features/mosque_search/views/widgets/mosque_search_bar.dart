import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosques_app/core/constants/app_colors.dart';
import 'package:mosques_app/core/constants/app_strings.dart';

class MosqueSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const MosqueSearchBar({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52.h,
      decoration: BoxDecoration(
        color: AppColor.surfaceContainer,
        borderRadius: BorderRadius.circular(28.r),
      ),
      child: TextField(
        onChanged: onChanged,
        style: TextStyle(
          color: AppColor.onSurface,
          fontSize: 14.sp,
        ),
        decoration: InputDecoration(
          hintText: AppStrings.searchHint,
          hintStyle: TextStyle(
            color: AppColor.onSurfaceVariant,
            fontSize: 14.sp,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColor.secondaryColor,
            size: 20.sp,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14.h),
        ),
      ),
    );
  }
}

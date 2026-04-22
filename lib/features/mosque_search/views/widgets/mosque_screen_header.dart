import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosques_app/core/constants/app_colors.dart';
import 'package:mosques_app/core/constants/app_strings.dart';

class MosqueScreenHeader extends StatelessWidget {
  const MosqueScreenHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      AppStrings.appTitle,
      style: TextStyle(
        color: AppColor.primaryColor,
        fontSize: 22.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosques_app/core/constants/app_colors.dart';
import 'package:mosques_app/core/theme/textstyles.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
  });

  final String text;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        fixedSize: Size(358.w, 56.h),
        backgroundColor: AppColor.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyles.f16w400.copyWith(color: Colors.white),
      ),
    );

    //   this or the previous one  but I prefer the one I made sorry :)  
    // return Center(
    //   child: SizedBox(
    //     width: double.infinity,
    //     child: TextButton(
    //         style: ButtonStyle(
    //           backgroundColor: WidgetStateProperty.all(AppColor.primaryColor),
    //           shape: WidgetStateProperty.all(RoundedRectangleBorder(
    //             borderRadius: BorderRadius.circular(14.r),
    //           )),
    //         ),
    //         onPressed: onPressed,
    //         child: Text(
    //           text,
    //           style: TextStyles.f16w400.copyWith(color: Colors.white),
    //           textAlign: TextAlign.center,
    //         )),
    //   ),
    // );
  }
}

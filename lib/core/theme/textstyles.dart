import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TextStyles {
  static TextStyle Title = TextStyle(
    fontSize: 30.sp,
    fontWeight: FontWeight.w700,
    color: Colors.black,
  );

  static TextStyle SubTitle = TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
  static TextStyle f20bold = TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.bold,
  );

  static TextStyle f16w400 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.grey,
  );

  static TextStyle f25bold = TextStyle(
    fontSize: 25.sp,
    fontWeight: FontWeight.bold,
  );

  static TextStyle f20w400 = TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w400,
  );

  static TextStyle f20boldBlack(BuildContext context) => TextStyle(
      fontSize: 20.sp,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black);

  static TextStyle f25boldBlack(BuildContext context) => TextStyle(
        fontSize: 25.sp,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
      );

  static TextStyle captionText = TextStyle(fontSize: 16.sp);

  static TextStyle f30bold = TextStyle(
    fontSize: 30.sp,
    fontWeight: FontWeight.bold,
  );

  static TextStyle f16bold = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
  );
}

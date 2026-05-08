import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

class AppStyle {
  static const _font = 'IBMPlexSansArabic';

  // ── Bold (w700) ──
  static TextStyle bold32 = TextStyle(fontFamily: _font, fontSize: 32.sp, fontWeight: FontWeight.w700, color: AppColor.onSurface);
  static TextStyle bold24 = TextStyle(fontFamily: _font, fontSize: 24.sp, fontWeight: FontWeight.w700, color: AppColor.onSurface);
  static TextStyle bold20 = TextStyle(fontFamily: _font, fontSize: 20.sp, fontWeight: FontWeight.w700, color: AppColor.onSurface);
  static TextStyle bold18 = TextStyle(fontFamily: _font, fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppColor.onSurface);
  static TextStyle bold16 = TextStyle(fontFamily: _font, fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColor.onSurface);

  // ── SemiBold (w600) ──
  static TextStyle semiBold20 = TextStyle(fontFamily: _font, fontSize: 20.sp, fontWeight: FontWeight.w600, color: AppColor.onSurface);
  static TextStyle semiBold18 = TextStyle(fontFamily: _font, fontSize: 18.sp, fontWeight: FontWeight.w600, color: AppColor.onSurface);
  static TextStyle semiBold16 = TextStyle(fontFamily: _font, fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColor.onSurface);
  static TextStyle semiBold14 = TextStyle(fontFamily: _font, fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColor.onSurface);

  // ── Medium (w500) ──
  static TextStyle medium16 = TextStyle(fontFamily: _font, fontSize: 16.sp, fontWeight: FontWeight.w500, color: AppColor.onSurface);
  static TextStyle medium14 = TextStyle(fontFamily: _font, fontSize: 14.sp, fontWeight: FontWeight.w500, color: AppColor.onSurface);
  static TextStyle medium12 = TextStyle(fontFamily: _font, fontSize: 12.sp, fontWeight: FontWeight.w500, color: AppColor.onSurface);

  // ── Regular (w400) ──
  static TextStyle regular16 = TextStyle(fontFamily: _font, fontSize: 16.sp, fontWeight: FontWeight.w400, color: AppColor.onSurface);
  static TextStyle regular14 = TextStyle(fontFamily: _font, fontSize: 14.sp, fontWeight: FontWeight.w400, color: AppColor.onSurfaceVariant);
  static TextStyle regular12 = TextStyle(fontFamily: _font, fontSize: 12.sp, fontWeight: FontWeight.w400, color: AppColor.onSurfaceVariant);
}
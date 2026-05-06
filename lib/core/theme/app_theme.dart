import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColor.primaryColor1,
    scaffoldBackgroundColor: const Color(0xFFF5F7F6),
    fontFamily: 'Nunito',
    colorScheme: const ColorScheme.light(
      primary: AppColor.primaryColor1,
      onPrimary: AppColor.onPrimary,
      secondary: AppColor.secondaryColor,
      surface: Color(0xFFF5F7F6),
      onSurface: Color(0xFF1A1A1A),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF5F7F6),
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Color(0xFF1A1A1A)),
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColor.primaryColor1,
    scaffoldBackgroundColor: AppColor.surfaceDim,
    fontFamily: 'Nunito',
    colorScheme: const ColorScheme.dark(
      primary: AppColor.primaryColor1,
      onPrimary: AppColor.onPrimary,
      secondary: AppColor.secondaryColor,
      surface: AppColor.surface,
      onSurface: AppColor.onSurface,
      surfaceContainerHighest: AppColor.surfaceContainerHighest,
      surfaceContainerHigh: AppColor.surfaceContainerHigh,
      surfaceContainer: AppColor.surfaceContainer,
      surfaceContainerLow: AppColor.surfaceContainerLow,
      outline: AppColor.outline,
      outlineVariant: AppColor.outlineVariant,
      error: AppColor.errorColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColor.appBarColor,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColor.primaryColor1),
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColor.onSurface),
    ),
    cardTheme: CardThemeData(
      color: AppColor.surfaceContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
    ),
  );
}
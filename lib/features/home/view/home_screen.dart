import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosques_app/core/constants/app_colors.dart';
import 'package:mosques_app/core/constants/app_strings.dart';
import 'package:mosques_app/features/home/view/widgets/prayer_schedule_section.dart';
import 'package:mosques_app/features/home/view/widgets/prayer_time_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Duration _remainingTime;

  @override
  void initState() {
    super.initState();
    _remainingTime = const Duration(minutes: 2, seconds: 45);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.surfaceDim,
      appBar: AppBar(
        title: const Text(
          AppStrings.appTitle,
          style: TextStyle(
            color: AppColor.primaryColor,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColor.surface,
        elevation: 0,
        toolbarHeight: 50.h,
        foregroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              SizedBox(height: 20.h),
              PrayerTimerCard(remainingTime: _remainingTime),
              SizedBox(height: 30.h),
              const PrayerScheduleSection(),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}

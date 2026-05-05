import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosques_app/core/constants/app_colors.dart';
import 'package:mosques_app/core/services/notification_service.dart';
import 'package:mosques_app/features/home/model/home_repo.dart';
import 'package:mosques_app/features/home/view/cubit/home_cubit.dart';
import 'package:mosques_app/features/home/view/widgets/home_prayer_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(repository: HomeRepository())..loadPrayerTimes(),
      child: Scaffold(
        backgroundColor: AppColor.primaryColor,
        appBar: const _HomeAppBar(),
        body: const HomePrayerView(),
      ),
    );
  }
}

class _HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _HomeAppBar();

  @override
  Size get preferredSize => Size.fromHeight(50.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(
        'Al-Masjid',
        style: TextStyle(
          color: AppColor.appBarTextColor,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      backgroundColor: AppColor.appBarColor,
      elevation: 0,
      toolbarHeight: 50.h,
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 8.w),
          child: Center(
            child: GestureDetector(
              onTap: () => NotificationService.instance.showTestNotification(),
              child: Icon(
                Icons.notifications_active_outlined,
                color: AppColor.appBarTextColor,
                size: 22.sp,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 16.w),
          child: Center(
            child: GestureDetector(
              onTap: () => context.read<HomeCubit>().refreshPrayerTimes(),
              child: Icon(
                Icons.refresh,
                color: AppColor.appBarTextColor,
                size: 24.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

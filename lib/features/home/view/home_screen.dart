import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosques_app/core/constants/app_colors.dart';
import 'package:mosques_app/features/home/model/home_repo.dart';
import 'package:mosques_app/features/home/view/cubit/home_cubit.dart';
import 'package:mosques_app/features/home/view/cubit/home_state.dart';
import 'package:mosques_app/features/home/view/widgets/prayer_schedule_section.dart';
import 'package:mosques_app/features/home/view/widgets/prayer_time_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeCubit _homeCubit;

  @override
  void initState() {
    super.initState();
    // Initialize the cubit with repository
    _homeCubit = HomeCubit(repository: HomeRepository());
    // Load prayer times when screen initializes
    _homeCubit.loadPrayerTimes();
  }

  @override
  void dispose() {
    _homeCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _homeCubit,
      child: Scaffold(
        backgroundColor: AppColor.primaryColor,
        appBar: AppBar(
          title: const Text(
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
            // Refresh button
            Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    _homeCubit.refreshPrayerTimes();
                  },
                  child: Icon(
                    Icons.refresh,
                    color: AppColor.appBarTextColor,
                    size: 24.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            return _buildBody(context, state);
          },
        ),
      ),
    );
  }

  /// Build the body based on state
  Widget _buildBody(BuildContext context, HomeState state) {
    if (state is HomeLoading) {
      return _buildLoadingState();
    } else if (state is HomeLoaded) {
      return _buildLoadedState(context, state);
    } else if (state is HomePermissionDenied) {
      return _buildPermissionDeniedState(context, state);
    } else if (state is HomeError) {
      return _buildErrorState(context, state);
    }
    return _buildLoadingState();
  }

  /// Loading state UI
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColor.accentTeal,
            strokeWidth: 3.w,
          ),
          SizedBox(height: 16.h),
          Text(
            'Loading prayer times...',
            style: TextStyle(color: AppColor.textSecondary, fontSize: 16.sp),
          ),
        ],
      ),
    );
  }

  /// Loaded state UI - Display prayer times
  Widget _buildLoadedState(BuildContext context, HomeLoaded state) {
    // Calculate remaining time to next prayer (simplified)
    final remainingTime = const Duration(minutes: 2, seconds: 30);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            SizedBox(height: 23.h),
            PrayerTimerCard(
              remainingTime: remainingTime,
              prayerTimes: state.prayerTimes,
            ),
            SizedBox(height: 35.h),
            PrayerScheduleSection(
              prayers: state.prayers,
              latitude: state.prayerTimes.latitude,
              longitude: state.prayerTimes.longitude,
              methodName: state.prayerTimes.methodName,
            ),
            SizedBox(height: 23.h),
          ],
        ),
      ),
    );
  }

  /// Permission denied state UI
  Widget _buildPermissionDeniedState(
    BuildContext context,
    HomePermissionDenied state,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 64.sp,
              color: AppColor.textSecondary,
            ),
            SizedBox(height: 24.h),
            Text(
              'Location Permission Required',
              style: TextStyle(
                color: AppColor.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              state.message,
              style: TextStyle(color: AppColor.textSecondary, fontSize: 14.sp),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            ElevatedButton(
              onPressed: () {
                _homeCubit.loadPrayerTimes();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.accentTeal,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
              ),
              child: Text(
                'Retry',
                style: TextStyle(
                  color: AppColor.black,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Error state UI
  Widget _buildErrorState(BuildContext context, HomeError state) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
            SizedBox(height: 24.h),
            Text(
              'Failed to Load Prayer Times',
              style: TextStyle(
                color: AppColor.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              state.message,
              style: TextStyle(color: AppColor.textSecondary, fontSize: 14.sp),
              textAlign: TextAlign.center,
            ),
            if (state.statusCode != null)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Text(
                  'Error code: ${state.statusCode}',
                  style: TextStyle(color: Colors.redAccent, fontSize: 12.sp),
                ),
              ),
            SizedBox(height: 32.h),
            ElevatedButton(
              onPressed: () {
                _homeCubit.refreshPrayerTimes();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.accentTeal,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
              ),
              child: Text(
                'Retry',
                style: TextStyle(
                  color: AppColor.black,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

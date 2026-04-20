import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:mosques_app/core/constants/app_colors.dart';
import 'package:mosques_app/features/bottom_nav_bar/cubit/bottom_nav_bar_cubit/bottom_nav_bar_cubit.dart';
import 'package:mosques_app/features/bottom_nav_bar/cubit/bottom_nav_bar_cubit/bottom_nav_bar_state.dart';

class BottomNavBarScreen extends StatelessWidget {
  const BottomNavBarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BottomNavBarCubit(),
      child: BlocBuilder<BottomNavBarCubit, BottomNavBarState>(
        builder: (context, state) {
          return Scaffold(
            body: context
                .read<BottomNavBarCubit>()
                .screens[context.read<BottomNavBarCubit>().currentIndex],

            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: AppColor.mainNavColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 20,
                    color: Colors.black.withOpacity(0.1),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 15.w,
                    vertical: 8.h,
                  ),
                  child: GNav(
                    selectedIndex: context
                        .read<BottomNavBarCubit>()
                        .currentIndex,

                    onTabChange: (index) {
                      context.read<BottomNavBarCubit>().ChangeIndex(index);
                    },

                    tabBackgroundColor: Colors.white.withOpacity(0.2),

                    activeColor: Colors.white,

                    color: Colors.white.withOpacity(0.6),

                    gap: 8.w,

                    padding: EdgeInsets.all(16.r),

                    duration: const Duration(milliseconds: 400),

                    curve: Curves.easeOutCubic,

                    tabs: const [
                      GButton(icon: Icons.home, text: 'Home'),
                      GButton(icon: Icons.search, text: 'Search'),
                      GButton(icon: Icons.favorite, text: 'Favorites'),
                      GButton(icon: Icons.more_horiz, text: 'More'),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

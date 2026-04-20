import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosques_app/core/constants/app_colors.dart';
import 'package:mosques_app/features/bottom_nav/viewmodels/bottom_nav_cubit.dart';
import 'package:mosques_app/features/bottom_nav/viewmodels/bottom_nav_states.dart';
import 'package:mosques_app/features/favorite/views/favorite_screen.dart';
import 'package:mosques_app/features/more/views/more_screen.dart';
import 'package:mosques_app/features/mosque_search/viewmodels/mosque_search_cubit.dart';
import 'package:mosques_app/features/mosque_search/views/mosque_search_screen.dart';
import 'package:mosques_app/features/prayer_times/views/prayer_times_screen.dart';

class BottomNavScreen extends StatelessWidget {
  const BottomNavScreen({super.key});

  static const List<Widget> _screens = [
    PrayerTimesScreen(),
    MosqueSearchScreen(),
    FavoriteScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => BottomNavCubit()),
        BlocProvider(create: (_) => MosqueSearchCubit()..loadMosques()),
      ],
      child: BlocBuilder<BottomNavCubit, BottomNavState>(
        builder: (context, state) {
          final cubit = context.read<BottomNavCubit>();
          return Scaffold(
            backgroundColor: AppColor.surfaceDim,
            extendBody: true,
            floatingActionButton: cubit.currentIndex == 1
                ? _MapFab()
                : null,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.endFloat,
            body: IndexedStack(
              index: cubit.currentIndex,
              children: _screens,
            ),
            bottomNavigationBar: _GlassNavBar(
              currentIndex: cubit.currentIndex,
              onTap: cubit.changeTab,
            ),
          );
        },
      ),
    );
  }
}

class _GlassNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _GlassNavBar({required this.currentIndex, required this.onTap});

  static const _items = [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.search_rounded, label: 'Search'),
    _NavItem(icon: Icons.favorite_rounded, label: 'Favorites'),
    _NavItem(icon: Icons.more_horiz_rounded, label: 'More'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 68.h,
            decoration: BoxDecoration(
              color: AppColor.surfaceContainer.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(28.r),
              border: Border.all(
                color: AppColor.outlineVariant.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                _items.length,
                (i) => _NavItemWidget(
                  item: _items[i],
                  isActive: currentIndex == i,
                  onTap: () => onTap(i),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemWidget extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItemWidget({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive
              ? AppColor.primaryColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                item.icon,
                key: ValueKey(isActive),
                size: 24.sp,
                color: isActive
                    ? AppColor.primaryColor
                    : AppColor.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 2.h),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight:
                    isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? AppColor.primaryColor
                    : AppColor.onSurfaceVariant,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => context.read<MosqueSearchCubit>().loadMosques(),
      backgroundColor: AppColor.secondaryColor,
      shape: const CircleBorder(),
      elevation: 0,
      child: Icon(
        Icons.my_location_rounded,
        color: AppColor.onSecondary,
        size: 22.sp,
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

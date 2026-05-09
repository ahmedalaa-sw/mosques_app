import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosques_app/core/constants/app_colors.dart';
import 'package:mosques_app/features/bottom_nav/viewmodels/bottom_nav_cubit.dart';
import 'package:mosques_app/features/bottom_nav/viewmodels/bottom_nav_states.dart';
import 'package:mosques_app/features/bottom_nav/views/widgets/glass_nav_bar.dart';
import 'package:mosques_app/features/bottom_nav/views/widgets/test_notification_fab.dart';
import 'package:mosques_app/features/favorite/viewmodels/favorite_cubit.dart';
import 'package:mosques_app/features/favorite/views/favorite_screen.dart';
import 'package:mosques_app/features/home/view/home_screen.dart';
import 'package:mosques_app/features/more/views/more_screen.dart';
import 'package:mosques_app/features/mosque_search/viewmodels/mosque_search_cubit.dart';
import 'package:mosques_app/features/mosque_search/views/mosque_search_screen.dart';

class BottomNavScreen extends StatelessWidget {
  const BottomNavScreen({super.key});

  static const List<Widget> _screens = [
    HomeScreen(),
    MosqueSearchScreen(),
    FavoriteScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => BottomNavCubit()),
        BlocProvider(create: (_) => MosqueSearchCubit()),
        BlocProvider(create: (_) => FavoriteCubit()..loadFavorites()),
      ],
      child: BlocListener<BottomNavCubit, BottomNavState>(
        listener: (context, state) {
          if (state is BottomNavChanged && state.index == 1) {
            context.read<MosqueSearchCubit>().startTracking();
          }
        },
        child: BlocBuilder<BottomNavCubit, BottomNavState>(
          builder: (context, state) {
            final cubit = context.read<BottomNavCubit>();
            return Scaffold(
              backgroundColor: AppColor.surfaceDim,
              extendBody: true,
              floatingActionButton: cubit.currentIndex == 0
                  ? const TestNotificationFab()
                  : null,
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.endFloat,
              body:
                  IndexedStack(index: cubit.currentIndex, children: _screens),
              bottomNavigationBar: GlassNavBar(
                currentIndex: cubit.currentIndex,
                onTap: cubit.changeTab,
              ),
            );
          },
        ),
      ),
    );
  }
}

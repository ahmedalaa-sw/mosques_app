import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosques_app/features/bottom_nav_bar/cubit/bottom_nav_bar_cubit/bottom_nav_bar_state.dart';
import 'package:mosques_app/features/home/view/home_screen.dart';

class BottomNavBarCubit extends Cubit<BottomNavBarState> {
  BottomNavBarCubit() : super(InitialBottomNavBarIndexState());

  int currentIndex = 0;

  List<Widget> screens = [
    HomeScreen(),

    //  SearchScreen(),
    // FavoritesScreen(),
    // MoreScreen(),
  ];

  void ChangeIndex(int index) {
    currentIndex = index;
    emit(ChangeBottomNavBarIndexState());
  }
}

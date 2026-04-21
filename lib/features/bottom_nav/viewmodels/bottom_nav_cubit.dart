import 'package:flutter_bloc/flutter_bloc.dart';
import 'bottom_nav_states.dart';

class BottomNavCubit extends Cubit<BottomNavState> {
  BottomNavCubit() : super(BottomNavInitial());

  int currentIndex = 0;

  void changeTab(int index) {
    currentIndex = index;
    emit(BottomNavChanged(index));
  }
}

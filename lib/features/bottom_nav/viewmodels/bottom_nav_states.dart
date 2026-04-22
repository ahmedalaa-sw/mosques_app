abstract class BottomNavState {}

class BottomNavInitial extends BottomNavState {}

class BottomNavChanged extends BottomNavState {
  final int index;
  BottomNavChanged(this.index);
}

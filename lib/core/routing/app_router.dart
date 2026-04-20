import 'package:flutter/material.dart';
import 'package:mosques_app/core/routing/routes.dart';
import 'package:mosques_app/features/bottom_nav_bar/screens/bottom_nav_bar_screen.dart';
import 'package:mosques_app/features/home/view/home_screen.dart';

class AppRouter {
  Route generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.homeScreen:
        return _createRoute(HomeScreen());
      case Routes.searchScreen:
      // return _createRoute(SearchScreen());
      case Routes.favScreen:
      // return _createRoute(FavScreen());

      case Routes.more:
      // return _createRoute(MoreScreen());

      case Routes.bottomNavScreen:
      return _createRoute(BottomNavBarScreen());
      case Routes.mosqueDetails:
      // return _createRoute(MosqueDetailsScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }

  PageRouteBuilder _createRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../routing/routes.dart';

class AppRouter {
  Route generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.signupScreen:
      // return _createRoute(SignUpScreen());
      case Routes.signinscreen:
      // return _createRoute(SignInScreen());
      case Routes.homeScreen:
      // return _createRoute(HomeScreen());

      case Routes.bottomNavScreen:
      // return _createRoute(BottomNavBarScreen());

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

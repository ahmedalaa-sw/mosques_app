import 'package:flutter/material.dart';
import '../routing/routes.dart';
import '../../features/mosque_details/views/mosque_details_screen.dart';
import '../../features/mosque_details/viewmodels/mosque_details_cubit.dart';
import '../../features/mosque_details/repo/mosque_details_repo.dart';

class AppRouter {
  Route generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.signupScreen:
      // return _createRoute(SignUpScreen());
      case Routes.signinScreen:
      // return _createRoute(SignInScreen());
      case Routes.homeScreen:
      // return _createRoute(HomeScreen());
      case Routes.bottomNavScreen:
      // return _createRoute(BottomNavBarScreen());
      case Routes.mosqueSearchScreen:
      // return _createRoute(MosqueSearchScreen());
      case Routes.prayerTimesScreen:
      // return _createRoute(PrayerTimesScreen());
      case Routes.favScreen:
      // return _createRoute(FavoriteScreen());

      case Routes.mosqueDetailsScreen:
        final mosqueId = settings.arguments as String? ?? '';
        return _createRoute(
          MosqueDetailsScreen(
            cubit: MosqueDetailsCubit(MosqueDetailsRepo())..loadMosqueDetails(mosqueId),
          ),
        );

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

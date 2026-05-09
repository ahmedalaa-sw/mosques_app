import 'package:flutter/material.dart';
import 'package:mosques_app/core/routing/routes.dart';
import 'package:mosques_app/features/bottom_nav/views/bottom_nav_screen.dart';
import 'package:mosques_app/features/home/view/home_screen.dart';
import 'package:mosques_app/features/onboarding/views/onboarding_screen.dart';
import 'package:mosques_app/features/more/views/about_us_screen.dart';
import 'package:mosques_app/features/more/views/change_location_screen.dart';
import 'package:mosques_app/features/more/views/contact_us_screen.dart';
import 'package:mosques_app/features/more/views/localization_screen.dart';
import 'package:mosques_app/features/more/views/theme_screen.dart';
import 'package:mosques_app/features/mosque_details/repo/mosque_details_repo.dart';
import 'package:mosques_app/features/mosque_details/viewmodels/mosque_details_cubit.dart';
import 'package:mosques_app/features/mosque_details/views/mosque_details_screen.dart';
import 'package:mosques_app/features/mosque_search/models/mosque_model.dart';

class AppRouter {
  Route generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.onboarding:
        return _createRoute(const OnboardingScreen());
      case Routes.homeScreen:
        return _createRoute(const HomeScreen());
      case Routes.searchScreen:
      // return _createRoute(SearchScreen());
      case Routes.favScreen:
      // return _createRoute(FavScreen());
      case Routes.more:
      // return _createRoute(MoreScreen());
      case Routes.aboutUs:
        return _createRoute(const AboutUsScreen());
      case Routes.localization:
        return _createRoute(const LocalizationScreen());
      case Routes.themeMode:
        return _createRoute(const ThemeScreen());
      case Routes.contactUs:
        return _createRoute(const ContactUsScreen());
      case Routes.changeLocation:
        return _createRoute(const ChangeLocationScreen());
      case Routes.mosqueDetails:
        final args = settings.arguments;
        final preview = args is MosqueModel ? args : null;
        final mosqueId = args is MosqueModel ? args.id : args as String? ?? '';
        return _createRoute(
          MosqueDetailsScreen(
            cubit: MosqueDetailsCubit(MosqueDetailsRepo())
              ..loadMosqueDetails(mosqueId, preview: preview),
          ),
        );
      case Routes.bottomNavScreen:
        return _createRoute(const BottomNavScreen());
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
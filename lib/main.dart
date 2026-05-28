import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:workmanager/workmanager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'core/services/background_reschedule_service.dart';
import 'core/services/timezone_service.dart';
import 'core/network/dio_helper.dart';
import 'core/routing/app_router.dart';
import 'core/routing/routes.dart';
import 'core/services/notification_service.dart';
import 'features/onboarding/viewmodels/onboarding_cubit.dart';
import 'app.dart';
import 'app_bloc_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize timezone database FIRST — must happen before any service
  // that uses tz.getLocation() or prayer time calculations.
  await TimezoneService.ensureInitialized();

  // Initialize localization
  await EasyLocalization.ensureInitialized();

  // Initialize background tasks
  await Workmanager().initialize(rescheduleCallbackDispatcher);
  await BackgroundRescheduleService.registerTasks();

  // Initialize local storage
  await Hive.initFlutter();

  // Setup global services
  Bloc.observer = AppBlocObserver();
  DioHelper.init();
  await NotificationService.instance.init();

  // Log timezone info
  log("Date time now : ${DateTime.now()}");
  log("Device timezone: ${TimezoneService.deviceTimezone}");
  log("UTC offset: ${DateTime.now().timeZoneOffset}");

  // Determine initial route based on onboarding status
  final onboardingDone = await OnboardingCubit.isOnboardingDone();
  final initialRoute = onboardingDone
      ? Routes.bottomNavScreen
      : Routes.onboarding;

  // Launch application
  runApp(MyApp(appRouter: AppRouter(), initialRoute: initialRoute));
}

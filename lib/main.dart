import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:workmanager/workmanager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'core/services/background_reschedule_service.dart';
import 'core/network/dio_helper.dart';
import 'core/routing/app_router.dart';
import 'core/routing/routes.dart';
import 'core/services/notification_service.dart';
import 'features/onboarding/viewmodels/onboarding_cubit.dart';
import 'app.dart';
import 'app_bloc_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Workmanager().initialize(rescheduleCallbackDispatcher);
  await BackgroundRescheduleService.registerTasks();

  await Hive.initFlutter();
  Bloc.observer = AppBlocObserver();
  DioHelper.init();
  await NotificationService.instance.init();
  log("Date time now : ${DateTime.now()}");
  log(DateTime.now().timeZoneName);
  log(DateTime.now().timeZoneOffset.toString());

  final onboardingDone = await OnboardingCubit.isOnboardingDone();
  final initialRoute =
      onboardingDone ? Routes.bottomNavScreen : Routes.onboarding;

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      child: MyApp(appRouter: AppRouter(), initialRoute: initialRoute),
    ),
  );
}
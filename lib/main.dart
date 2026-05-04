import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'core/network/dio_helper.dart';
import 'core/routing/app_router.dart';
import 'core/services/notification_service.dart';
import 'app.dart';
import 'app_bloc_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Bloc.observer = AppBlocObserver();
  DioHelper.init();
  await NotificationService.instance.init();
  log("Date time now : ${DateTime.now()}");
  log(DateTime.now().timeZoneName);
  log(DateTime.now().timeZoneOffset.toString());
  runApp(MyApp(appRouter: AppRouter()));
}

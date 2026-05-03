import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
// import 'package:mosques_app/core/network/supabase_service.dart';
import 'core/network/dio_helper.dart';
import 'core/routing/app_router.dart';
import 'core/services/notification_service.dart';
import 'app.dart';
import 'app_bloc_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  // Hive.registerAdapter(MosquesModelAdapter());

  // await Hive.openBox<MosquesModel>('favoritesBox');
  // await SupabaseService.init();
  Bloc.observer = AppBlocObserver();
  DioHelper.init();

  // Initialize local notifications (requests permission on Android 13+).
  await NotificationService.instance.init();

  runApp(MyApp(appRouter: AppRouter()));
}

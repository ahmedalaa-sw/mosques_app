import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  static const _key = 'theme_mode';

  ThemeCubit() : super(ThemeState.initial()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_key) ?? true;
    emit(ThemeState(
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      isDark: isDark,
    ));
  }

  Future<void> toggleTheme() async {
    final newIsDark = !state.isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, newIsDark);
    emit(ThemeState(
      themeMode: newIsDark ? ThemeMode.dark : ThemeMode.light,
      isDark: newIsDark,
    ));
  }
}
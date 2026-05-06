import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'locale_state.dart';

class LocaleCubit extends Cubit<LocaleState> {
  static const _key = 'app_locale';

  LocaleCubit() : super(LocaleState.initial()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key) ?? 'en';
    final isArabic = code == 'ar';
    emit(LocaleState(
      locale: Locale(code),
      isArabic: isArabic,
    ));
  }

  Future<void> changeLocale(String code) async {
    final isArabic = code == 'ar';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, code);
    emit(LocaleState(
      locale: Locale(code),
      isArabic: isArabic,
    ));
  }

  Future<void> toggleLocale() async {
    final newCode = state.isArabic ? 'en' : 'ar';
    await changeLocale(newCode);
  }
}
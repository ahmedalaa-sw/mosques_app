import 'package:flutter/material.dart';

class ThemeState {
  final ThemeMode themeMode;
  final bool isDark;

  const ThemeState({required this.themeMode, this.isDark = true});

  factory ThemeState.initial() => const ThemeState(themeMode: ThemeMode.dark, isDark: true);

  ThemeState copyWith({ThemeMode? themeMode, bool? isDark}) =>
      ThemeState(themeMode: themeMode ?? this.themeMode, isDark: isDark ?? this.isDark);
}
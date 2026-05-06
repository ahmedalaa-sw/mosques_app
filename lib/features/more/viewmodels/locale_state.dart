import 'package:flutter/material.dart';

class LocaleState {
  final Locale locale;
  final bool isArabic;

  const LocaleState({required this.locale, this.isArabic = false});

  factory LocaleState.initial() => const LocaleState(locale: Locale('en'), isArabic: false);

  LocaleState copyWith({Locale? locale, bool? isArabic}) =>
      LocaleState(locale: locale ?? this.locale, isArabic: isArabic ?? this.isArabic);
}
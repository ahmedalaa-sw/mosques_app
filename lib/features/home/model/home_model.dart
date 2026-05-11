import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mosques_app/core/services/adhan_prayer_service.dart';
import 'package:mosques_app/core/utils/timezone_resolver.dart';

class PrayerModel {
  final String name;
  final String time;
  final IconData icon;
  final bool isHighlighted;

  PrayerModel({
    required this.name,
    required this.time,
    required this.icon,
    this.isHighlighted = false,
  });
}

/// Prayer times model produced by offline adhan_dart calculations.
/// All time strings are converted from UTC to the prayer location's local
/// timezone using [TimezoneResolver], NOT the device's timezone.
class AladhanPrayerTimesModel {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final double latitude;
  final double longitude;
  final DateTime date;
  final String methodName;
  // IANA timezone name for the prayer location (e.g. 'Asia/Riyadh').
  // Stored so notification scheduling and prayer-transition logic can
  // convert times without re-resolving the timezone.
  final String ianaTimezone;

  AladhanPrayerTimesModel({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.latitude,
    required this.longitude,
    required this.date,
    required this.ianaTimezone,
    this.methodName = AdhanPrayerService.defaultMethodName,
  });

  factory AladhanPrayerTimesModel.fromPrayerCalculationResult({
    required PrayerCalculationResult result,
    required double latitude,
    required double longitude,
    String? methodName,
  }) {
    final tz = result.ianaTimezone;
    final finalMethodName = methodName ?? AdhanPrayerService.defaultMethodName;
    return AladhanPrayerTimesModel(
      fajr: TimezoneResolver.formatHhMm(result.prayerTimes.fajr, tz),
      sunrise: TimezoneResolver.formatHhMm(result.prayerTimes.sunrise, tz),
      dhuhr: TimezoneResolver.formatHhMm(result.prayerTimes.dhuhr, tz),
      asr: TimezoneResolver.formatHhMm(result.prayerTimes.asr, tz),
      maghrib: TimezoneResolver.formatHhMm(result.prayerTimes.maghrib, tz),
      isha: TimezoneResolver.formatHhMm(result.prayerTimes.isha, tz),
      latitude: latitude,
      longitude: longitude,
      date: TimezoneResolver.nowAt(tz),
      ianaTimezone: tz,
      methodName: finalMethodName,
    );
  }

  List<PrayerModel> toHousePrayerModels(String? currentPrayer) => [
    PrayerModel(
      name: 'fajr'.tr(),
      time: fajr,
      icon: Icons.wb_twilight,
      isHighlighted: currentPrayer == 'fajr'.tr(),
    ),
    PrayerModel(
      name: 'sunrise'.tr(),
      time: sunrise,
      icon: Icons.wb_sunny,
      isHighlighted: currentPrayer == 'sunrise'.tr(),
    ),
    PrayerModel(
      name: 'dhuhr'.tr(),
      time: dhuhr,
      icon: Icons.wb_sunny,
      isHighlighted: currentPrayer == 'dhuhr'.tr(),
    ),
    PrayerModel(
      name: 'asr'.tr(),
      time: asr,
      icon: Icons.wb_sunny,
      isHighlighted: currentPrayer == 'asr'.tr(),
    ),
    PrayerModel(
      name: 'maghrib'.tr(),
      time: maghrib,
      icon: Icons.wb_twilight,
      isHighlighted: currentPrayer == 'maghrib'.tr(),
    ),
    PrayerModel(
      name: 'isha'.tr(),
      time: isha,
      icon: Icons.nights_stay,
      isHighlighted: currentPrayer == 'isha'.tr(),
    ),
  ];

  @override
  String toString() =>
      'AladhanPrayerTimesModel(fajr: $fajr, dhuhr: $dhuhr, asr: $asr, '
      'maghrib: $maghrib, isha: $isha, method: $methodName, '
      'lat: $latitude, lng: $longitude, tz: $ianaTimezone)';
}
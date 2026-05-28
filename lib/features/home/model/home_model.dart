import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mosques_app/core/services/adhan_prayer_service.dart';
import 'package:mosques_app/features/home/model/prayer_method_mapper.dart';
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
  final double altitude;
  final DateTime date;
  final String countryCode;
  final String methodName;
  final String ianaTimezone;
  final String source;

  AladhanPrayerTimesModel({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.date,
    required this.countryCode,
    required this.methodName,
    required this.ianaTimezone,
    this.source = 'local',
  });

  factory AladhanPrayerTimesModel.fromPrayerCalculationResult({
    required PrayerCalculationResult result,
    required double latitude,
    required double longitude,
    required String countryCode,
    double altitude = 0,
    String source = 'local',
  }) {
    final tzName = result.ianaTimezone;
    final localDate = TimezoneResolver.nowAt(tzName);
    return AladhanPrayerTimesModel(
      fajr: TimezoneResolver.formatHhMm(result.prayerTimes.fajr, tzName),
      sunrise: TimezoneResolver.formatHhMm(result.prayerTimes.sunrise, tzName),
      dhuhr: TimezoneResolver.formatHhMm(result.prayerTimes.dhuhr, tzName),
      asr: TimezoneResolver.formatHhMm(result.prayerTimes.asr, tzName),
      maghrib: TimezoneResolver.formatHhMm(result.prayerTimes.maghrib, tzName),
      isha: TimezoneResolver.formatHhMm(result.prayerTimes.isha, tzName),
      latitude: latitude,
      longitude: longitude,
      altitude: altitude,
      date: DateTime.utc(localDate.year, localDate.month, localDate.day),
      countryCode: countryCode.toUpperCase(),
      methodName: PrayerMethodMapper.methodNameForCountry(countryCode),
      ianaTimezone: tzName,
      source: source,
    );
  }

  factory AladhanPrayerTimesModel.fromApiResponse({
    required double latitude,
    required double longitude,
    required double altitude,
    required DateTime date,
    required String ianaTimezone,
    required String countryCode,
    required String methodName,
    required String source,
    required Map<String, String> timings,
  }) {
    return AladhanPrayerTimesModel(
      fajr: _stripTimeString(timings['Fajr']),
      sunrise: _stripTimeString(timings['Sunrise']),
      dhuhr: _stripTimeString(timings['Dhuhr']),
      asr: _stripTimeString(timings['Asr']),
      maghrib: _stripTimeString(timings['Maghrib']),
      isha: _stripTimeString(timings['Isha']),
      latitude: latitude,
      longitude: longitude,
      altitude: altitude,
      date: DateTime.utc(date.year, date.month, date.day),
      countryCode: countryCode.toUpperCase(),
      methodName: methodName,
      ianaTimezone: ianaTimezone,
      source: source,
    );
  }

  Map<String, dynamic> toJson() => {
    'fajr': fajr,
    'sunrise': sunrise,
    'dhuhr': dhuhr,
    'asr': asr,
    'maghrib': maghrib,
    'isha': isha,
    'latitude': latitude,
    'longitude': longitude,
    'altitude': altitude,
    'date': date.toIso8601String(),
    'countryCode': countryCode,
    'methodName': methodName,
    'ianaTimezone': ianaTimezone,
    'source': source,
  };

  factory AladhanPrayerTimesModel.fromJson(Map<String, dynamic> json) {
    return AladhanPrayerTimesModel(
      fajr: json['fajr'] as String,
      sunrise: json['sunrise'] as String,
      dhuhr: json['dhuhr'] as String,
      asr: json['asr'] as String,
      maghrib: json['maghrib'] as String,
      isha: json['isha'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      altitude: (json['altitude'] as num?)?.toDouble() ?? 0.0,
      date: DateTime.parse(json['date'] as String).toUtc(),
      countryCode: (json['countryCode'] as String).toUpperCase(),
      methodName: json['methodName'] as String,
      ianaTimezone: json['ianaTimezone'] as String,
      source: json['source'] as String,
    );
  }

  static String _stripTimeString(String? raw) {
    if (raw == null) return '00:00';
    return raw.split(' ').first.trim();
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

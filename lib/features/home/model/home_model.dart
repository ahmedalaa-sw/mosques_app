import 'package:flutter/material.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:mosques_app/core/services/adhan_prayer_service.dart';
import 'package:mosques_app/core/utils/prayer_wall_clock_format.dart';

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
    this.methodName = AdhanPrayerService.defaultMethodName,
  });

  factory AladhanPrayerTimesModel.fromAdhanPrayerTimes({
    required PrayerTimes prayerTimes,
    required double latitude,
    required double longitude,
    String? methodName,
  }) {
    // adhan builds each prayer with DateTime.utc through TimeComponents.utcDate.
    // These are genuine UTC timelines (isUtc == true); project with toLocal().
    return AladhanPrayerTimesModel(
      fajr: PrayerWallClockFormat.hourMinute(prayerTimes.fajr),
      sunrise: PrayerWallClockFormat.hourMinute(prayerTimes.sunrise),
      dhuhr: PrayerWallClockFormat.hourMinute(prayerTimes.dhuhr),
      asr: PrayerWallClockFormat.hourMinute(prayerTimes.asr),
      maghrib: PrayerWallClockFormat.hourMinute(prayerTimes.maghrib),
      isha: PrayerWallClockFormat.hourMinute(prayerTimes.isha),
      latitude: latitude,
      longitude: longitude,
      date: DateTime.now(),
      methodName: methodName ?? AdhanPrayerService.defaultMethodName,
    );
  }

  List<PrayerModel> toHousePrayerModels(String? currentPrayer) => [
        PrayerModel(
          name: 'Fajr',
          time: fajr,
          icon: Icons.wb_twilight,
          isHighlighted: currentPrayer == 'Fajr',
        ),
        PrayerModel(
          name: 'Sunrise',
          time: sunrise,
          icon: Icons.wb_sunny,
          isHighlighted: currentPrayer == 'Sunrise',
        ),
        PrayerModel(
          name: 'Dhuhr',
          time: dhuhr,
          icon: Icons.wb_sunny,
          isHighlighted: currentPrayer == 'Dhuhr',
        ),
        PrayerModel(
          name: 'Asr',
          time: asr,
          icon: Icons.wb_sunny,
          isHighlighted: currentPrayer == 'Asr',
        ),
        PrayerModel(
          name: 'Maghrib',
          time: maghrib,
          icon: Icons.wb_twilight,
          isHighlighted: currentPrayer == 'Maghrib',
        ),
        PrayerModel(
          name: 'Isha',
          time: isha,
          icon: Icons.nights_stay,
          isHighlighted: currentPrayer == 'Isha',
        ),
      ];

  @override
  String toString() =>
      'AladhanPrayerTimesModel(fajr: $fajr, dhuhr: $dhuhr, asr: $asr, '
      'maghrib: $maghrib, isha: $isha, method: $methodName, '
      'lat: $latitude, lng: $longitude)';
}
import 'package:flutter/material.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:mosques_app/core/services/adhan_prayer_service.dart';

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
    // Pre-compute the device's UTC offset once for all prayers.
    // adhan_dart returns DateTime values that are UTC but may be flagged
    // as isUtc=false (plain DateTime with UTC hour/minute values).
    // Calling .toLocal() on a non-UTC-flagged DateTime is a NO-OP in Dart,
    // so we manually add the device's timezone offset instead.
    // This is the only approach that works reliably regardless of how
    // adhan_dart internally flags its returned DateTimes.
    final offset = DateTime.now().timeZoneOffset;

    return AladhanPrayerTimesModel(
      fajr: _fmt(prayerTimes.fajr, offset),
      sunrise: _fmt(prayerTimes.sunrise, offset),
      dhuhr: _fmt(prayerTimes.dhuhr, offset),
      asr: _fmt(prayerTimes.asr, offset),
      maghrib: _fmt(prayerTimes.maghrib, offset),
      isha: _fmt(prayerTimes.isha, offset),
      latitude: latitude,
      longitude: longitude,
      date: DateTime.now(),
      methodName: methodName ?? AdhanPrayerService.defaultMethodName,
    );
  }

  // ── FIX 2: add timezone offset manually instead of calling .toLocal() ─────
  // adhan_dart docs: "prayer times will be DateTime instances in UTC values."
  // However, the returned DateTimes are NOT always flagged as isUtc=true,
  // which makes Dart's .toLocal() treat them as already-local (NO-OP).
  // Adding the offset Duration directly gives us the correct local time
  // regardless of how the library flags the returned DateTime.
  static String _fmt(DateTime? t, Duration offset) {
    if (t == null) return '00:00';
    final local = t.add(offset);
    return '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
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
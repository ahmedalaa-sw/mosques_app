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

/// Prayer times model produced by offline adhan_dart calculations.
/// Works worldwide — no network dependency.
class AladhanPrayerTimesModel {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  // final String imsak;
  // final String midnight;
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
    // required this.imsak,
    // required this.midnight,
    required this.latitude,
    required this.longitude,
    required this.date,
    this.methodName = AdhanPrayerService.defaultMethodName,
  });

  factory AladhanPrayerTimesModel.fromAdhanPrayerTimes({
    required PrayerTimes prayerTimes,
    required double latitude,
    required double longitude,
    String methodName = AdhanPrayerService.defaultMethodName,
  }) {
    return AladhanPrayerTimesModel(
      // ── KEY FIX ────────────────────────────────────────────────────────────
      // adhan_dart returns all times as UTC DateTimes.
      // _fmt() calls .toLocal() on each one before extracting hour/minute.
      // Without this the displayed times are in UTC which is wrong for
      // anyone not in the UTC+0 timezone (e.g. Kuwait is UTC+3, so every
      // prayer would show 3 hours too early without this conversion).
      // ───────────────────────────────────────────────────────────────────────
      fajr: _fmt(prayerTimes.fajr),
      sunrise: _fmt(prayerTimes.sunrise),
      dhuhr: _fmt(prayerTimes.dhuhr),
      asr: _fmt(prayerTimes.asr),
      maghrib: _fmt(prayerTimes.maghrib),
      isha: _fmt(prayerTimes.isha),
      // imsak: _fmt(prayerTimes.imsak),
      // midnight: _fmt(prayerTimes.midnight),
      latitude: latitude,
      longitude: longitude,
      date: DateTime.now(),
      methodName: methodName,
    );
  }

  /// Converts UTC DateTime from adhan_dart to local time, then formats as HH:mm.
  static String _fmt(DateTime? t) {
    if (t == null) return '00:00';
    // .toLocal() is the critical call — adhan_dart gives UTC, we need local.
    final local = t.toLocal();
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

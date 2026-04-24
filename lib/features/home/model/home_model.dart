import 'package:flutter/material.dart';

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

/// Comprehensive model for Aladhan API prayer times response
class AladhanPrayerTimesModel {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String imsak;
  final String midnight;
  final double latitude;
  final double longitude;
  final String methodName;
  final String schoolName;
  final DateTime date;

  AladhanPrayerTimesModel({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.imsak,
    required this.midnight,
    required this.latitude,
    required this.longitude,
    required this.methodName,
    required this.schoolName,
    required this.date,
  });

  /// Factory constructor to parse from Aladhan API response
  factory AladhanPrayerTimesModel.fromJson(Map<String, dynamic> json) {
    try {
      final timings = json['timings'] as Map<String, dynamic>? ?? {};
      final meta = json['meta'] as Map<String, dynamic>? ?? {};
      final method = meta['method'] as Map<String, dynamic>? ?? {};

      // Parse date
      final dateData = json['date'] as Map<String, dynamic>? ?? {};
      final gregorian = dateData['gregorian'] as Map<String, dynamic>? ?? {};
      final dateStr = gregorian['date'] as String? ?? '';
      
      DateTime parsedDate;
      try {
        final parts = dateStr.split('-');
        if (parts.length == 3) {
          parsedDate = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        } else {
          parsedDate = DateTime.now();
        }
      } catch (_) {
        parsedDate = DateTime.now();
      }

      return AladhanPrayerTimesModel(
        fajr: (timings['Fajr'] as String?)?.split(' ').first.trim() ?? '05:00',
        sunrise: (timings['Sunrise'] as String?)?.split(' ').first.trim() ?? '06:30',
        dhuhr: (timings['Dhuhr'] as String?)?.split(' ').first.trim() ?? '12:30',
        asr: (timings['Asr'] as String?)?.split(' ').first.trim() ?? '16:00',
        maghrib: (timings['Maghrib'] as String?)?.split(' ').first.trim() ?? '18:45',
        isha: (timings['Isha'] as String?)?.split(' ').first.trim() ?? '20:00',
        imsak: (timings['Imsak'] as String?)?.split(' ').first.trim() ?? '04:45',
        midnight: (timings['Midnight'] as String?)?.split(' ').first.trim() ?? '00:15',
        latitude: (meta['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (meta['longitude'] as num?)?.toDouble() ?? 0.0,
        methodName: method['name'] as String? ?? 'Unknown',
        schoolName: 'Shafi',
        date: parsedDate,
      );
    } catch (e) {
      throw Exception('Error parsing prayer times: $e');
    }
  }

  /// Convert to simple PrayerModel list for UI
  List<PrayerModel> toHousePrayerModels(String? currentPrayer) {
    return [
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
  }

  @override
  String toString() =>
      'AladhanPrayerTimesModel(fajr: $fajr, dhuhr: $dhuhr, asr: $asr, '
      'maghrib: $maghrib, isha: $isha, lat: $latitude, lng: $longitude)';
}

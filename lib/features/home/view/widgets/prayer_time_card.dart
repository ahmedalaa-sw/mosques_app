import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosques_app/core/constants/app_colors.dart';
import 'package:mosques_app/features/home/model/home_model.dart';
import 'sun_timing_card.dart';

class PrayerTimerCard extends StatelessWidget {
  final Duration remainingTime;
  final AladhanPrayerTimesModel? prayerTimes;

  const PrayerTimerCard({
    super.key,
    required this.remainingTime,
    this.prayerTimes,
  });

  String _formatTime(Duration duration) {
    int minutes = duration.inMinutes;
    int seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Parse time string "HH:MM" to Duration since midnight
  Duration _parseTimeString(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length != 2) return Duration.zero;
      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);
      return Duration(hours: hours, minutes: minutes);
    } catch (_) {
      return Duration.zero;
    }
  }

  /// Get the next prayer from current time
  Map<String, String> _getNextPrayer() {
    if (prayerTimes == null) {
      return {'name': 'Dhuhr', 'time': '01:12 PM'};
    }

    final now = DateTime.now();
    final currentTime = Duration(hours: now.hour, minutes: now.minute);

    // Prayer order with their times
    final prayers = [
      {'name': 'Fajr', 'time': prayerTimes!.fajr},
      {'name': 'Dhuhr', 'time': prayerTimes!.dhuhr},
      {'name': 'Asr', 'time': prayerTimes!.asr},
      {'name': 'Maghrib', 'time': prayerTimes!.maghrib},
      {'name': 'Isha', 'time': prayerTimes!.isha},
    ];

    // Find next prayer
    for (final prayer in prayers) {
      final prayerTime = _parseTimeString(prayer['time']!);
      if (prayerTime > currentTime) {
        return prayer;
      }
    }

    // If all prayers have passed, next prayer is Fajr tomorrow
    return {'name': 'Fajr', 'time': prayerTimes!.fajr};
  }

  /// Get current prayer being performed
  String _getCurrentPrayer() {
    if (prayerTimes == null) {
      return 'Dhuhr';
    }

    final now = DateTime.now();
    final currentTime = Duration(hours: now.hour, minutes: now.minute);

    // Define prayer time ranges
    final prayerRanges = [
      {'name': 'Fajr', 'start': prayerTimes!.fajr, 'end': prayerTimes!.sunrise},
      {'name': 'Dhuhr', 'start': prayerTimes!.dhuhr, 'end': prayerTimes!.asr},
      {'name': 'Asr', 'start': prayerTimes!.asr, 'end': prayerTimes!.maghrib},
      {
        'name': 'Maghrib',
        'start': prayerTimes!.maghrib,
        'end': prayerTimes!.isha,
      },
      {'name': 'Isha', 'start': prayerTimes!.isha, 'end': '23:59'},
    ];

    for (final range in prayerRanges) {
      final startTime = _parseTimeString(range['start']!);
      final endTime = _parseTimeString(range['end']!);

      // Handle midnight crossing (e.g., 23:00 to 01:00)
      if (startTime > endTime) {
        if (currentTime >= startTime || currentTime < endTime) {
          return range['name']!;
        }
      } else {
        if (currentTime >= startTime && currentTime < endTime) {
          return range['name']!;
        }
      }
    }

    return 'Fajr';
  }

  String _convertTo12Hour(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length != 2) return timeStr;

      final hour = int.parse(parts[0]);
      final minute = parts[1];

      if (hour == 0) {
        return '12:$minute AM';
      } else if (hour < 12) {
        return '$hour:$minute AM';
      } else if (hour == 12) {
        return '12:$minute PM';
      } else {
        return '${hour - 12}:$minute PM';
      }
    } catch (_) {
      return timeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPrayer = _getCurrentPrayer();
    final nextPrayer = _getNextPrayer();

    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: Column(
        children: [
          // Now Praying Label
          Text(
            'NOW PRAYING',
            style: TextStyle(
              color: AppColor.textSecondary,
              fontSize: 12.sp,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 12.h),

          // Circular Timer Container
          Container(
            width: 220.w,
            height: 240.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [const Color(0xff2a4a44), AppColor.primaryColor],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xff88d6c8).withOpacity(0.1),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Prayer Name
                Text(
                  currentPrayer,
                  style: TextStyle(
                    color: AppColor.accentTeal,
                    fontSize: 48.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12.h),

                // ONGOING Badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.badgeGold.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColor.badgeGold, width: 1),
                  ),
                  child: Text(
                    'ONGOING',
                    style: TextStyle(
                      color: AppColor.badgeGold,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // Next Prayer
                Text(
                  'Next Prayer: ${nextPrayer['name']} in',
                  style: TextStyle(
                    color: AppColor.textSecondary,
                    fontSize: 15.sp,
                  ),
                ),
                SizedBox(height: 8.h),

                // Timer
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: _formatTime(remainingTime),
                        style: TextStyle(
                          color: AppColor.white,
                          fontSize: 56.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: '12s',
                        style: TextStyle(
                          color: AppColor.textSecondary,
                          fontSize: 18.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 40.h),

          // Sunrise and Sunset
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SunTimingCard(
                label: 'SUNRISE',
                time: _convertTo12Hour(prayerTimes?.sunrise ?? '06:12 AM'),
                icon: Icons.wb_sunny,
              ),
              SunTimingCard(
                label: 'SUNSET',
                time: _convertTo12Hour(prayerTimes?.maghrib ?? '05:44 PM'),
                icon: Icons.wb_sunny_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

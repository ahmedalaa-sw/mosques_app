import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mosques_app/core/constants/app_colors.dart';

class PrayerCountdownCard extends StatelessWidget {
  final String currentPrayerName;
  final String nextPrayerName;
  final Duration remaining;
  final String formattedCountdown;
  // Diameter of the circle in logical pixels — computed by the parent
  // from MediaQuery so it scales with every screen size.
  final double circleSize;

  const PrayerCountdownCard({
    super.key,
    required this.currentPrayerName,
    required this.nextPrayerName,
    required this.remaining,
    required this.formattedCountdown,
    required this.circleSize,
  });

  @override
  Widget build(BuildContext context) {
    // All sizes derived from circleSize so the card stays proportional
    // regardless of which device it renders on.
    final nameFont      = circleSize * 0.155;
    final badgeFont     = circleSize * 0.050;
    final nextFont      = circleSize * 0.062;
    final countFont     = circleSize * (remaining.inHours > 0 ? 0.132 : 0.165);

    return Container(
      width: circleSize,
      height: circleSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [const Color(0xff2a4a44), AppColor.primaryColor],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff88d6c8).withValues(alpha: 0.1),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            currentPrayerName,
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              color: AppColor.accentTeal,
              fontSize: nameFont,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: circleSize * 0.033),

          Container(
            padding: EdgeInsets.symmetric(
              horizontal: circleSize * 0.044,
              vertical: circleSize * 0.016,
            ),
            decoration: BoxDecoration(
              color: AppColor.badgeGold.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(circleSize * 0.066),
              border: Border.all(color: AppColor.badgeGold, width: 1),
            ),
            child: Text(
              'ongoing'.tr(),
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                color: AppColor.badgeGold,
                fontSize: badgeFont,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
          SizedBox(height: circleSize * 0.044),

          Text(
            '${'next_prayer'.tr()}$nextPrayerName',
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              color: AppColor.textSecondary,
              fontSize: nextFont,
            ),
          ),
          SizedBox(height: circleSize * 0.022),

          // FontFeature.tabularFigures() keeps digits fixed-width so the
          // text doesn't shift horizontally as numbers change each second.
          Text(
            formattedCountdown,
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              color: AppColor.white,
              fontSize: countFont,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

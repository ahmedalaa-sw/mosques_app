import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosques_app/core/constants/app_colors.dart';

/// An animated banner that appears when the next prayer is ≤ 15 minutes away.
///
/// Features:
/// - Slide-in animation from top
/// - Subtle pulsing glow effect
/// - Glassmorphism background
/// - Mosque icon with prayer name and countdown
class PrayerAlertBanner extends StatefulWidget {
  final String prayerName;
  final Duration remaining;
  final String formattedCountdown;

  const PrayerAlertBanner({
    super.key,
    required this.prayerName,
    required this.remaining,
    required this.formattedCountdown,
  });

  @override
  State<PrayerAlertBanner> createState() => _PrayerAlertBannerState();
}

class _PrayerAlertBannerState extends State<PrayerAlertBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Pulsing glow animation — repeats indefinitely.
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _arabicPrayerName(String name) {
    const map = {
      'Fajr': 'الفجر',
      'Sunrise': 'الشروق',
      'Dhuhr': 'الظهر',
      'Asr': 'العصر',
      'Maghrib': 'المغرب',
      'Isha': 'العشاء',
    };
    return map[name] ?? name;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColor.badgeGold.withValues(
                alpha: _pulseAnimation.value,
              ),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColor.badgeGold.withValues(
                  alpha: _pulseAnimation.value * 0.3,
                ),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 14.h,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xff1a2624).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    // ── Mosque icon with gold circle ──
                    Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColor.badgeGold.withValues(alpha: 0.3),
                            AppColor.badgeGold.withValues(alpha: 0.1),
                          ],
                        ),
                        border: Border.all(
                          color: AppColor.badgeGold.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.mosque_rounded,
                        color: AppColor.badgeGold,
                        size: 22.sp,
                      ),
                    ),

                    SizedBox(width: 12.w),

                    // ── Text content ──
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Text(
                                '🕌 ${widget.prayerName}',
                                style: TextStyle(
                                  color: AppColor.badgeGold,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                _arabicPrayerName(widget.prayerName),
                                style: TextStyle(
                                  color: AppColor.badgeGold.withValues(
                                    alpha: 0.7,
                                  ),
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Prayer starts in ${widget.formattedCountdown}',
                            style: TextStyle(
                              color: AppColor.white.withValues(alpha: 0.85),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Countdown badge ──
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.badgeGold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: AppColor.badgeGold.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        widget.formattedCountdown,
                        style: TextStyle(
                          color: AppColor.badgeGold,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Wraps [PrayerAlertBanner] with a smooth slide-in/slide-out transition.
///
/// When [isVisible] transitions from false → true the banner slides down.
/// When [isVisible] transitions from true → false the banner slides up and
/// collapses so it takes zero vertical space.
class AnimatedPrayerAlertBanner extends StatelessWidget {
  final bool isVisible;
  final String prayerName;
  final Duration remaining;
  final String formattedCountdown;

  const AnimatedPrayerAlertBanner({
    super.key,
    required this.isVisible,
    required this.prayerName,
    required this.remaining,
    required this.formattedCountdown,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: isVisible
          ? Padding(
              key: const ValueKey('alert_visible'),
              padding: EdgeInsets.only(bottom: 16.h),
              child: PrayerAlertBanner(
                prayerName: prayerName,
                remaining: remaining,
                formattedCountdown: formattedCountdown,
              ),
            )
          : const SizedBox.shrink(key: ValueKey('alert_hidden')),
    );
  }
}

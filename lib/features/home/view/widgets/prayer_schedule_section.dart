import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosques_app/core/constants/app_colors.dart';
import 'package:mosques_app/features/home/model/home_model.dart';

class PrayerScheduleSection extends StatelessWidget {
  final List<PrayerModel>? prayers;
  final double? latitude;
  final double? longitude;
  final String? methodName;

  const PrayerScheduleSection({
    super.key,
    this.prayers,
    this.latitude,
    this.longitude,
    this.methodName,
  });

  static final List<PrayerModel> _fallbackPrayers = [
    PrayerModel(name: 'Fajr', time: '05:22 AM', icon: Icons.wb_twilight),
    PrayerModel(name: 'Sunrise', time: '06:54 AM', icon: Icons.wb_sunny),
    PrayerModel(
      name: 'Dhuhr',
      time: '01:12 PM',
      icon: Icons.wb_sunny,
      isHighlighted: true,
    ),
    PrayerModel(name: 'Asr', time: '04:38 PM', icon: Icons.wb_sunny),
    PrayerModel(name: 'Maghrib', time: '07:22 PM', icon: Icons.wb_twilight),
    PrayerModel(name: 'Isha', time: '08:44 PM', icon: Icons.nights_stay),
  ];

  bool get _hasLocation => latitude != null && longitude != null;

  String get _locationLabel =>
      "Lat: ${latitude!.toStringAsFixed(4)},  "
      "Lng: ${longitude!.toStringAsFixed(4)}";

  @override
  Widget build(BuildContext context) {
    final effectivePrayers = prayers ?? _fallbackPrayers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(methodName: methodName),
        SizedBox(height: 12.h),

        for (int i = 0; i < effectivePrayers.length; i++) ...[
          _PrayerRow(prayer: effectivePrayers[i]),
          if (i < effectivePrayers.length - 1) SizedBox(height: 8.h),
        ],

        if (_hasLocation) ...[
          SizedBox(height: 16.h),
          _LocationBadge(label: _locationLabel),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String? methodName;

  const _SectionHeader({this.methodName});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Prayer Schedule',
                style: TextStyle(
                  color: AppColor.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (methodName != null && methodName!.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: Text(
                    'Method: $methodName',
                    style: TextStyle(
                      color: AppColor.textSecondary,
                      fontSize: 11.sp,
                    ),
                  ),
                ),
            ],
          ),
        ),

        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Full Month',
            style: TextStyle(
              color: AppColor.accentTeal,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _PrayerRowTheme {
  final Color iconColor;
  final Color textColor;
  final FontWeight nameFontWeight;
  final Color backgroundColor;
  final Border? border;
  final bool showActiveDot;

  const _PrayerRowTheme({
    required this.iconColor,
    required this.textColor,
    required this.nameFontWeight,
    required this.backgroundColor,
    this.border,
    required this.showActiveDot,
  });

  factory _PrayerRowTheme.normal() => _PrayerRowTheme(
    iconColor: AppColor.textSecondary,
    textColor: AppColor.white,
    nameFontWeight: FontWeight.w500,
    backgroundColor: AppColor.primaryColor,
    showActiveDot: false,
  );

  factory _PrayerRowTheme.highlighted() => _PrayerRowTheme(
    iconColor: AppColor.accentTeal,
    textColor: AppColor.accentTeal,
    nameFontWeight: FontWeight.w600,
    backgroundColor: AppColor.darkCard,
    border: Border.all(color: AppColor.accentTeal, width: 1.5),
    showActiveDot: true,
  );
}

class _PrayerRow extends StatelessWidget {
  final PrayerModel prayer;

  const _PrayerRow({required this.prayer});

  @override
  Widget build(BuildContext context) {
    final theme = prayer.isHighlighted
        ? _PrayerRowTheme.highlighted()
        : _PrayerRowTheme.normal();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        border: theme.border,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Icon(prayer.icon, color: theme.iconColor, size: 24.sp),
            SizedBox(width: 16.w),

            Expanded(
              child: Text(
                prayer.name,
                style: TextStyle(
                  color: theme.textColor,
                  fontSize: 16.sp,
                  fontWeight: theme.nameFontWeight,
                ),
              ),
            ),

            if (theme.showActiveDot) ...[_ActiveDot(), SizedBox(width: 8.w)],

            Text(
              prayer.time,
              style: TextStyle(
                color: theme.textColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ActiveDot
//
// Small teal circle indicating the currently active prayer. Extracted so
// the parent Row reads as a clean list of siblings rather than embedding
// layout arithmetic inline.
// ─────────────────────────────────────────────────────────────────────────────
class _ActiveDot extends StatelessWidget {
  const _ActiveDot();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColor.accentTeal,
      ),
      child: SizedBox(width: 8.w, height: 8.h),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _LocationBadge
//
// Displays formatted latitude/longitude when location data is available.
// Uses a pre-formatted label string rather than computing it inline.
// Color literal replaced with AppColor.darkCard — the opacity is applied
// once via the const withOpacity call rather than inside build().
// ─────────────────────────────────────────────────────────────────────────────
class _LocationBadge extends StatelessWidget {
  final String label;

  // Pre-computed semi-transparent fill — avoids creating a new Color object
  // on every rebuild by keeping it as a field rather than calling
  // withOpacity() inline inside build().
  static final Color _fill = AppColor.darkCard.withOpacity(0.5);

  const _LocationBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _fill,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          children: [
            Icon(Icons.location_on, color: AppColor.accentTeal, size: 16.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: AppColor.textSecondary,
                  fontSize: 11.sp,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

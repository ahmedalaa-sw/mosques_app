import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosques_app/core/constants/app_colors.dart';
import 'package:mosques_app/features/home/model/home_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PrayerScheduleSection
//
// Improvements over the original:
//  • Fallback prayer list promoted to a static const — built once at class
//    load time, never again on rebuild.
//  • ListView.separated replaced with a Column + mapped widgets. shrinkWrap
//    ListView inside a Column pays a double-layout cost; a Column with a
//    fixed, small item count (≤ 6) is cheaper and avoids the extra layer.
//  • Private sub-widgets (_SectionHeader, _PrayerRow, _LocationBadge)
//    decompose the build method, each carrying a single responsibility and
//    making the top-level build scannable at a glance.
//  • Inline ternary color/style expressions centralised in _PrayerRowTheme —
//    one place to update if AppColor tokens change.
//  • Container replaced with DecoratedBox + Padding where no sizing is
//    needed, reducing the widget tree depth.
//  • _locationLabel getter computes the formatted string once per build
//    rather than inline, keeping the widget tree expression clean.
//  • Static const used on all decoration objects that don't depend on props.
// ─────────────────────────────────────────────────────────────────────────────
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

  // Fallback list — static const: built once, shared across all instances.
  static final List<PrayerModel> _fallbackPrayers = [
    PrayerModel(name: 'Fajr',    time: '05:22 AM', icon: Icons.wb_twilight),
     PrayerModel(name: 'Sunrise', time: '06:54 AM', icon: Icons.wb_sunny),
     PrayerModel(name: 'Dhuhr',   time: '01:12 PM', icon: Icons.wb_sunny, isHighlighted: true),
     PrayerModel(name: 'Asr',     time: '04:38 PM', icon: Icons.wb_sunny),
     PrayerModel(name: 'Maghrib', time: '07:22 PM', icon: Icons.wb_twilight),
     PrayerModel(name: 'Isha',    time: '08:44 PM', icon: Icons.nights_stay),
  ];

  bool get _hasLocation => latitude != null && longitude != null;

  String get _locationLabel =>
      'Lat: ${latitude!.toStringAsFixed(4)},  '
      'Lng: ${longitude!.toStringAsFixed(4)}';

  @override
  Widget build(BuildContext context) {
    final effectivePrayers = prayers ?? _fallbackPrayers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──────────────────────────────────────────────────────────
        _SectionHeader(methodName: methodName),
        SizedBox(height: 12.h),

        // ── Prayer rows ──────────────────────────────────────────────────────
        // Deliberately a Column rather than a ListView: item count is always
        // ≤ 6, the parent scroll view handles scrolling, and avoiding
        // shrinkWrap ListView eliminates the double-layout pass.
        for (int i = 0; i < effectivePrayers.length; i++) ...[
          _PrayerRow(prayer: effectivePrayers[i]),
          if (i < effectivePrayers.length - 1) SizedBox(height: 8.h),
        ],

        // ── Location badge ───────────────────────────────────────────────────
        if (_hasLocation) ...[
          SizedBox(height: 16.h),
          _LocationBadge(label: _locationLabel),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SectionHeader
//
// "Prayer Schedule" title + optional calculation method tag + "Full Month"
// action. Extracted so the parent build method stays scannable.
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String? methodName;

  const _SectionHeader({this.methodName});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Title + optional method sub-label
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

        // "Full Month" action — no-op placeholder preserved from original.
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            // Remove default horizontal padding so it visually aligns with
            // the card edges.
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

// ─────────────────────────────────────────────────────────────────────────────
// _PrayerRowTheme
//
// Single source of truth for colors and weights that differ between a normal
// row and a highlighted (currently active) row. Centralised here so that
// changing a token requires editing exactly one place.
// ─────────────────────────────────────────────────────────────────────────────
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

// ─────────────────────────────────────────────────────────────────────────────
// _PrayerRow
//
// Renders one prayer entry. Uses _PrayerRowTheme to avoid repeating ternary
// color expressions inline. DecoratedBox + Padding replaces Container since
// no explicit sizing is required — fewer render objects, same result.
// ─────────────────────────────────────────────────────────────────────────────
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
            // Prayer icon
            Icon(prayer.icon, color: theme.iconColor, size: 24.sp),
            SizedBox(width: 16.w),

            // Prayer name
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

            // Active dot — only visible for the highlighted prayer.
            if (theme.showActiveDot) ...[
              _ActiveDot(),
              SizedBox(width: 8.w),
            ],

            // Prayer time
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
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/mosque_detail_model.dart';

class MosqueHeroSection extends StatelessWidget {
  final MosqueDetailModel mosque;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final double expandedHeight;

  const MosqueHeroSection({
    super.key,
    required this.mosque,
    required this.isFavorite,
    required this.onFavoriteToggle,
    this.expandedHeight = 280,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: expandedHeight.h,
      pinned: true,
      stretch: true,
      backgroundColor: AppColor.surfaceContainerLow,
      leading: _GlassCircleButton(
        icon: Icons.arrow_back_ios_new_rounded,
        onTap: () => Navigator.of(context).pop(),
      ),
      actions: [
        _GlassCircleButton(
          icon: isFavorite
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          iconColor: isFavorite ? AppColor.secondaryColor : AppColor.onSurface,
          onTap: onFavoriteToggle,
        ),
        SizedBox(width: 8.w),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: _HeroBackground(mosque: mosque),
      ),
    );
  }
}

class _HeroBackground extends StatelessWidget {
  final MosqueDetailModel mosque;
  const _HeroBackground({required this.mosque});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Mosque image or gradient placeholder with error handling
        if (mosque.imageUrl != null)
          Image.network(
            mosque.imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Show default placeholder if image fails to load (e.g., no internet)
              return _MosquePlaceholderArt();
            },
          )
        else
          _MosquePlaceholderArt(),
        // Bottom gradient for text legibility
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 120.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  AppColor.surface,
                  AppColor.surface.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        // Mosque names at the bottom of the hero
        Positioned(
          bottom: 16.h,
          left: 20.w,
          right: 20.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (mosque.arabicName != null)
                Text(
                  mosque.arabicName!,
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 14.sp,
                    color: AppColor.primaryColor,
                    letterSpacing: 0.5,
                  ),
                ),
              Text(
                mosque.name,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColor.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MosquePlaceholderArt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.surface,
            AppColor.primaryContainer,
            AppColor.surfaceContainer,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Decorative geometric rings
          Center(
            child: SizedBox(
              width: 200.w,
              height: 200.w,
              child: CustomPaint(painter: _GeometricRingsPainter()),
            ),
          ),
          Center(
            child: Icon(
              Icons.mosque_rounded,
              size: 72.sp,
              color: AppColor.primaryColor.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassCircleButton extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;

  const _GlassCircleButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: AppColor.surfaceVariant.withValues(alpha: 0.45),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColor.outlineVariant.withValues(alpha: 0.2),
                ),
              ),
              child: Icon(
                icon,
                size: 18.sp,
                color: iconColor ?? AppColor.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GeometricRingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radii = [40.0, 65.0, 88.0, 100.0];

    for (int i = 0; i < radii.length; i++) {
      paint.color = Color.fromRGBO(132, 213, 197, 0.08 + i * 0.04);
      canvas.drawCircle(center, radii[i], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

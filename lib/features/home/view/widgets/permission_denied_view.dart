import 'package:flutter/material.dart';
import 'package:mosques_app/core/constants/app_colors.dart';
import 'package:mosques_app/features/home/view/widgets/centered_action_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PermissionDeniedView
//
// Shown when HomeCubit emits HomePermissionDenied.
// Delegates all layout to CenteredActionView; only supplies its specific
// icon, colour, copy, and retry callback.
// ─────────────────────────────────────────────────────────────────────────────
class PermissionDeniedView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const PermissionDeniedView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return CenteredActionView(
      icon: Icons.location_off,
      iconColor: AppColor.textSecondary,
      title: 'Location Permission Required',
      message: message,
      onRetry: onRetry,
    );
  }
}
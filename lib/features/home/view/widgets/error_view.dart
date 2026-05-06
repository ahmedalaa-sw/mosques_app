import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mosques_app/features/home/view/widgets/centered_action_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ErrorView
//
// Shown when HomeCubit emits HomeError.
// Delegates all layout to CenteredActionView; passes the optional status code
// as a subtitle so it surfaces as a muted annotation below the main message.
// ─────────────────────────────────────────────────────────────────────────────
class ErrorView extends StatelessWidget {
  final String message;
  final int? statusCode;
  final VoidCallback onRetry;

  const ErrorView({
    super.key,
    required this.message,
    required this.statusCode,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return CenteredActionView(
      icon: Icons.error_outline,
      iconColor: Colors.red,
      title: 'prayer_times_error'.tr(),
      message: message,
      subtitle: statusCode != null ? '${'prayer_times_error_code'.tr()}$statusCode' : null,
      onRetry: onRetry,
    );
  }
}
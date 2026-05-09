import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosques_app/core/constants/app_colors.dart';
import 'package:mosques_app/core/services/battery_optimization_service.dart';
import 'package:mosques_app/core/services/notification_service.dart';
import 'package:mosques_app/features/home/view/cubit/home_cubit.dart';
import 'package:mosques_app/features/home/view/cubit/home_state.dart';
import 'package:mosques_app/features/home/view/widgets/loaded_view.dart';
import 'package:mosques_app/features/home/view/widgets/home_skeleton_view.dart';
import 'package:mosques_app/features/home/view/widgets/error_view.dart';
import 'package:mosques_app/features/home/view/widgets/permission_denied_view.dart';

class HomePrayerView extends StatefulWidget {
  const HomePrayerView({super.key});

  @override
  State<HomePrayerView> createState() => _HomePrayerViewState();
}

class _HomePrayerViewState extends State<HomePrayerView> {
  bool _permissionsChecked = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listenWhen: (_, current) => current is HomeLoaded && !_permissionsChecked,
      listener: (context, state) {
        if (state is HomeLoaded) {
          _permissionsChecked = true;
          _checkNotificationPermissions();
        }
      },
      builder: (context, state) {
        return switch (state) {
          HomeInitial()  => const HomeSkeletonView(),
          HomeLoading()  => const HomeSkeletonView(),

          HomeLoaded(:final prayerTimes, :final prayers) => LoadedView(
              prayerTimes: prayerTimes,
              prayers: prayers,
            ),

          HomePermissionDenied(:final message) => PermissionDeniedView(
              message: message,
              onRetry: () => context.read<HomeCubit>().loadPrayerTimes(),
            ),

          HomeError(:final message, :final statusCode) => ErrorView(
              message: message,
              statusCode: statusCode,
              onRetry: () => context.read<HomeCubit>().refreshPrayerTimes(),
            ),

          _ => const HomeSkeletonView(),
        };
      },
    );
  }

  // Checks exact-alarm permission and battery optimization once after the first
  // successful prayer-times load. Dialogs are shown sequentially so they don't
  // stack on top of each other.
  Future<void> _checkNotificationPermissions() async {
    if (!mounted) return;

    final canAlarm = await NotificationService.instance.canScheduleExactAlarms();
    if (!canAlarm && mounted) {
      final granted = await _showPermissionDialog(
        title: 'notif_exact_alarm_title'.tr(),
        body: 'notif_exact_alarm_body'.tr(),
        actionLabel: 'notif_exact_alarm_action'.tr(),
      );
      if (granted) await NotificationService.instance.openExactAlarmSettings();
    }

    if (!mounted) return;
    final ignoring = await BatteryOptimizationService.isIgnoringBatteryOptimizations();
    if (!ignoring && mounted) {
      final granted = await _showPermissionDialog(
        title: 'notif_battery_title'.tr(),
        body: 'notif_battery_body'.tr(),
        actionLabel: 'notif_battery_action'.tr(),
      );
      if (granted) await BatteryOptimizationService.requestIgnoreBatteryOptimizations();
    }
  }

  // Shows a two-button dialog explaining the permission. Returns true if the
  // user pressed the action button, false if they dismissed.
  Future<bool> _showPermissionDialog({
    required String title,
    required String body,
    required String actionLabel,
  }) async {
    if (!mounted) return false;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColor.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.notifications_active, color: AppColor.primaryColor1, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppColor.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          body,
          style: TextStyle(color: AppColor.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'notif_dismiss'.tr(),
              style: TextStyle(color: AppColor.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor1,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

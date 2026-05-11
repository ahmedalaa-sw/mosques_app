// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:mosques_app/core/constants/app_colors.dart';
// import 'package:mosques_app/core/services/notification_service.dart';
// import 'package:mosques_app/features/more/viewmodels/azan_cubit.dart';
// import 'package:mosques_app/features/more/viewmodels/azan_state.dart';

// /// Glass-style FAB that fires an immediate test prayer notification.
// ///
// /// Plays the call-only or merged call+azan file depending on the azan toggle —
// /// identical to what a real scheduled notification plays.
// ///
// /// Wrapped in [Padding] so it clears the glass bottom nav bar
// /// (68 h bar + 20 h bottom gap = 88 h total).
// class TestNotificationFab extends StatelessWidget {
//   const TestNotificationFab({super.key});

//   static const _navBarClearance = 88.0;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: _navBarClearance.h),
//       child: BlocBuilder<AzanCubit, AzanState>(
//         builder: (context, azanState) {
//           return FloatingActionButton(
//             heroTag: 'testNotificationFab',
//             onPressed: () => _onPressed(context, azanState.isAzanEnabled),
//             backgroundColor: AppColor.primaryColor1,
//             shape: const CircleBorder(),
//             elevation: 0,
//             tooltip: 'Test prayer notification',
//             child: Icon(
//               Icons.notifications_active_rounded,
//               color: AppColor.onPrimary,
//               size: 22.sp,
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Future<void> _onPressed(BuildContext context, bool azanEnabled) async {
//     await NotificationService.instance.showTestNotification(
//       azanEnabled: azanEnabled,
//     );

//     if (!context.mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           azanEnabled
//               ? 'Test sent — merged call + azan audio playing'
//               : 'Test sent — call-only audio playing',
//         ),
//         behavior: SnackBarBehavior.floating,
//         margin: EdgeInsets.only(
//           bottom: _navBarClearance.h + 8.h,
//           left: 16.w,
//           right: 16.w,
//         ),
//         duration: const Duration(seconds: 3),
//         backgroundColor: AppColor.primaryColor1,
//       ),
//     );
//   }
// }

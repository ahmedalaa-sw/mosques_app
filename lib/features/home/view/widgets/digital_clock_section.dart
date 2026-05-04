// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:mosques_app/core/constants/app_colors.dart';
// import 'package:mosques_app/core/cubit/time_format_cubit.dart';

// class DigitalClockSection extends StatefulWidget {
//   const DigitalClockSection({super.key});

//   @override
//   State<DigitalClockSection> createState() => _DigitalClockSectionState();
// }

// class _DigitalClockSectionState extends State<DigitalClockSection> {
//   Timer? _timer;

//   @override
//   void initState() {
//     super.initState();
//     _timer = Timer.periodic(const Duration(seconds: 1), _tick);
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     _timer = null;
//     super.dispose();
//   }

//   void _tick(Timer _) {
//     if (mounted) setState(() {});
//   }

//   String _formatTime(DateTime now, bool use24Hour) {
//     final h = now.hour;
//     final m = now.minute.toString().padLeft(2, '0');
//     final s = now.second.toString().padLeft(2, '0');

//     if (use24Hour) {
//       return '${h.toString().padLeft(2, '0')}:$m:$s';
//     }

//     final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
//     return '$h12:$m:$s';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final use24Hour = context.watch<TimeFormatCubit>().state.is24Hour;
//     return Column(
//       children: [
//         Text(
//           _formatTime(DateTime.now(), use24Hour),
//           style: TextStyle(
//             color: AppColor.white,
//             fontSize: 48.sp,
//             fontWeight: FontWeight.w700,
//             fontFeatures: const [FontFeature.tabularFigures()],
//             letterSpacing: 2,
//           ),
//         ),
//       ],
//     );
//   }
// }
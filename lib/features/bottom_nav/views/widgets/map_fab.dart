import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosques_app/core/constants/app_colors.dart';
import 'package:mosques_app/features/mosque_search/viewmodels/mosque_search_cubit.dart';

class MapFab extends StatelessWidget {
  const MapFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => context.read<MosqueSearchCubit>().loadMosques(),
      backgroundColor: AppColor.secondaryColor,
      shape: const CircleBorder(),
      elevation: 0,
      child: Icon(
        Icons.my_location_rounded,
        color: AppColor.onSecondary,
        size: 22.sp,
      ),
    );
  }
}

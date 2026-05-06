import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosques_app/core/constants/app_colors.dart';
import 'package:mosques_app/features/home/view/cubit/home_cubit.dart';
import 'package:mosques_app/features/home/view/cubit/home_state.dart';
import 'package:mosques_app/features/home/view/widgets/loaded_view.dart';
import 'package:mosques_app/features/home/view/widgets/loading_view.dart';
import 'package:mosques_app/features/home/view/widgets/error_view.dart';
import 'package:mosques_app/features/home/view/widgets/permission_denied_view.dart';

class HomePrayerView extends StatelessWidget {
  const HomePrayerView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return switch (state) {
          HomeInitial() || HomeLoading() => const LoadingView(),

          HomeLoaded(:final prayerTimes, :final prayers) => RefreshIndicator(
              onRefresh: () => context.read<HomeCubit>().refreshPrayerTimes(),
              color: AppColor.secondaryColor,
              backgroundColor: AppColor.primaryColor,
              strokeWidth: 2.5,
              displacement: 40,
              child: LoadedView(
                prayerTimes: prayerTimes,
                prayers: prayers,
              ),
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

          _ => const LoadingView(),
        };
      },
    );
  }
}
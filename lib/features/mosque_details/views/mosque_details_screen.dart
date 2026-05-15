import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../viewmodels/mosque_details_cubit.dart';
import '../viewmodels/mosque_details_state.dart';
import 'widgets/mosque_about_card.dart';
import 'widgets/mosque_action_buttons.dart';
import 'widgets/mosque_hero_section.dart';
import 'widgets/mosque_info_section.dart';

class MosqueDetailsScreen extends StatelessWidget {
  final MosqueDetailsCubit cubit;

  const MosqueDetailsScreen({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(value: cubit, child: const _MosqueDetailsView());
  }
}

class _MosqueDetailsView extends StatelessWidget {
  const _MosqueDetailsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.surfaceDim,
      body: BlocBuilder<MosqueDetailsCubit, MosqueDetailsState>(
        builder: (context, state) {
          if (state is MosqueDetailsLoading || state is MosqueDetailsInitial) {
            return const _LoadingView();
          }
          if (state is MosqueDetailsError) {
            return _ErrorView(
              message: state.message,
              onRetry: () => context.read<MosqueDetailsCubit>().retry(),
            );
          }
          if (state is MosqueDetailsSuccess) {
            return _SuccessView(state: state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final MosqueDetailsSuccess state;
  const _SuccessView({required this.state});

  @override
  Widget build(BuildContext context) {
    final mosque = state.mosque;
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        MosqueHeroSection(
          mosque: mosque,
          isFavorite: mosque.isFavorite,
          onFavoriteToggle: () =>
              context.read<MosqueDetailsCubit>().toggleFavorite(),
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MosqueInfoSection(mosque: mosque),
              SizedBox(height: 20.h),
              MosqueActionButtons(mosque: mosque),
              SizedBox(height: 16.h),
              MosqueAboutCard(address: mosque.address),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ],
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: AppColor.primaryColor,
        strokeWidth: 2.5,
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.mosque_rounded,
              size: 56.sp,
              color: AppColor.primaryColor,
            ),
            SizedBox(height: 16.h),
            Text(
              'error'.tr(),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.onSurface,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColor.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 24.h),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColor.secondaryColor,
                  borderRadius: BorderRadius.circular(50.r),
                ),
                child: Text(
                  'retry'.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

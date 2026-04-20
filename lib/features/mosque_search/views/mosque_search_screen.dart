import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosques_app/core/constants/app_colors.dart';
import 'package:mosques_app/features/mosque_search/viewmodels/mosque_search_states.dart';
import 'package:mosques_app/features/mosque_search/viewmodels/mosque_search_cubit.dart';
import 'widgets/mosque_card.dart';
import 'widgets/mosque_list_header.dart';
import 'widgets/mosque_search_bar.dart';

class MosqueSearchScreen extends StatelessWidget {
  const MosqueSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.surfaceDim,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: _ScreenHeader(),
            ),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: BlocBuilder<MosqueSearchCubit, MosqueSearchState>(
                buildWhen: (_, __) => false,
                builder: (context, _) => MosqueSearchBar(
                  onChanged: context.read<MosqueSearchCubit>().search,
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Expanded(
              child: BlocBuilder<MosqueSearchCubit, MosqueSearchState>(
                builder: (context, state) {
                  if (state is MosqueSearchLocating) {
                    return const _StatusMessage(
                      icon: Icons.my_location_rounded,
                      label: 'Finding your location…',
                    );
                  }
                  if (state is MosqueSearchLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColor.primaryColor,
                      ),
                    );
                  }
                  if (state is MosqueSearchSuccess) {
                    return _MosqueList(mosques: state.mosques);
                  }
                  if (state is MosqueSearchError) {
                    return _StatusMessage(
                      icon: Icons.location_off_rounded,
                      label: state.message,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScreenHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Al-Masjid',
      style: TextStyle(
        color: AppColor.primaryColor,
        fontSize: 22.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
    );
  }
}

class _MosqueList extends StatelessWidget {
  final List mosques;

  const _MosqueList({required this.mosques});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: MosqueListHeader(count: mosques.length),
        ),
        SizedBox(height: 14.h),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.h),
            itemCount: mosques.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (_, i) => MosqueCard(mosque: mosques[i]),
          ),
        ),
      ],
    );
  }
}

class _StatusMessage extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatusMessage({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColor.onSurfaceVariant, size: 40.sp),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColor.onSurfaceVariant,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


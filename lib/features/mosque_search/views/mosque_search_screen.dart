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
    return BlocProvider(
      create: (_) => MosqueSearchCubit()..loadMosques(),
      child: Scaffold(
        backgroundColor: AppColor.surfaceDim,
        floatingActionButton: _MapFab(),
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
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
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

class _MapFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {},
      backgroundColor: AppColor.secondaryColor,
      shape: const CircleBorder(),
      elevation: 0,
      child: Icon(
        Icons.map_outlined,
        color: AppColor.onSecondary,
        size: 22.sp,
      ),
    );
  }
}

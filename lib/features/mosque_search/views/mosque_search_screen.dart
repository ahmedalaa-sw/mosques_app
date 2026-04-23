import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosques_app/core/constants/app_colors.dart';
import 'package:mosques_app/core/constants/app_strings.dart';
import 'package:mosques_app/core/routing/routes.dart';
import 'package:mosques_app/features/mosque_search/models/mosque_model.dart';
import 'package:mosques_app/features/mosque_search/viewmodels/mosque_search_cubit.dart';
import 'package:mosques_app/features/mosque_search/viewmodels/mosque_search_states.dart';
import 'widgets/mosque_list.dart';
import 'widgets/mosque_screen_header.dart';
import 'widgets/mosque_search_bar.dart';
import 'widgets/mosque_status_message.dart';

class MosqueSearchScreen extends StatelessWidget {
  const MosqueSearchScreen({super.key});

  void _openMosqueDetails(BuildContext context, MosqueModel mosque) {
    Navigator.of(context).pushNamed(Routes.mosqueDetails, arguments: mosque);
  }

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
              child: const MosqueScreenHeader(),
            ),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: BlocBuilder<MosqueSearchCubit, MosqueSearchState>(
                buildWhen: (_, _) => false,
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
                    return const MosqueStatusMessage(
                      icon: Icons.my_location_rounded,
                      label: AppStrings.findingLocation,
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
                    return MosqueList(
                      mosques: state.mosques,
                      onMosqueTap: (mosque) =>
                          _openMosqueDetails(context, mosque),
                    );
                  }
                  if (state is MosqueSearchError) {
                    return MosqueStatusMessage(
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

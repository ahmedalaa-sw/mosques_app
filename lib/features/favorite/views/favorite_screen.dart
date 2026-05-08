import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosques_app/core/constants/app_colors.dart';
import 'package:mosques_app/core/routing/routes.dart';
import 'package:mosques_app/core/widgets/mosque_list_card.dart';
import 'package:mosques_app/features/favorite/models/favorite_model.dart';
import 'package:mosques_app/features/favorite/viewmodels/favorite_cubit.dart';
import 'package:mosques_app/features/favorite/viewmodels/favorite_states.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.surfaceDim,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: BlocBuilder<FavoriteCubit, FavoriteState>(
            builder: (context, state) {
              if (state is FavoriteLoading || state is FavoriteInitial) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColor.primaryColor,
                  ),
                );
              }

              if (state is FavoriteError) {
                return Center(
                  child: Text(
                    state.message,
                    style: TextStyle(
                      color: AppColor.onSurfaceVariant,
                      fontSize: 14.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              if (state is FavoriteSuccess) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    Text(
                      'favorites'.tr(),
                      style: TextStyle(
                        color: AppColor.onSurface,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      '${state.favorites.length}${'saved_mosques_count'.tr()}',
                      style: TextStyle(
                        color: AppColor.onSurfaceVariant,
                        fontSize: 13.sp,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    if (state.favorites.isEmpty)
                      Expanded(
                        child: Center(
                          child: Text(
                            'no_saved_mosques'.tr(),
                            style: TextStyle(
                              color: AppColor.onSurfaceVariant,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.separated(
                          padding: EdgeInsets.only(bottom: 100.h),
                          itemCount: state.favorites.length,
                          separatorBuilder: (_, _) => SizedBox(height: 12.h),
                          itemBuilder: (context, index) {
                            final favorite = state.favorites[index];
                            return MosqueListCard(
                              name: favorite.name,
                              distanceLabel: favorite.distanceLabel,
                              statusLabel: favorite.statusLabel,
                              statusColor: _statusColor(favorite),
                              amenities: favorite.amenities,
                              imageUrl: favorite.photoUrl,
                              trailing: IconButton(
                                onPressed: () => context
                                    .read<FavoriteCubit>()
                                    .toggleFavorite(favorite),
                                icon: Icon(
                                  Icons.favorite_rounded,
                                  color: AppColor.secondaryColor,
                                  size: 20.sp,
                                ),
                              ),
                              onTap: () => Navigator.of(context).pushNamed(
                                Routes.mosqueDetails,
                                arguments: favorite.toMosqueModel(),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Color _statusColor(FavoriteModel favorite) {
    if (favorite.isOpen == true) return AppColor.primaryColor1;
    if (favorite.isOpen == false) return AppColor.errorColor;
    if (favorite.statusLabel == 'status_not_valid') {
      return AppColor.secondaryColor;
    }
    return AppColor.onSurfaceVariant;
  }
}

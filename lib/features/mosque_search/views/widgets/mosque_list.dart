import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosques_app/core/constants/app_colors.dart';
import 'package:mosques_app/features/mosque_search/models/mosque_model.dart';
import 'mosque_card.dart';
import 'mosque_list_header.dart';

class MosqueList extends StatelessWidget {
  final List<MosqueModel> mosques;
  final ValueChanged<MosqueModel> onMosqueTap;
  final VoidCallback onRefresh;

  const MosqueList({
    super.key,
    required this.mosques,
    required this.onMosqueTap,
    required this.onRefresh,
  });

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
          child: mosques.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.mosque_rounded,
                        color: AppColor.onSurfaceVariant,
                        size: 48.sp,
                      ),
                      SizedBox(height: 12.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40.w),
                        child: Text(
                          'no_mosques_nearby'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColor.onSurfaceVariant,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      TextButton.icon(
                        onPressed: onRefresh,
                        icon: Icon(Icons.my_location_rounded, size: 18.sp),
                        label: Text(
                          'check_my_location'.tr(),
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColor.appBarTextColor,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.h),
                  itemCount: mosques.length,
                  separatorBuilder: (_, _) => SizedBox(height: 12.h),
                  itemBuilder: (_, i) => MosqueCard(
                    mosque: mosques[i],
                    onTap: () => onMosqueTap(mosques[i]),
                  ),
                ),
        ),
      ],
    );
  }
}

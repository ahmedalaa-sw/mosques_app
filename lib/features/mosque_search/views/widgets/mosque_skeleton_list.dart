import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosques_app/core/constants/app_colors.dart';
import 'package:mosques_app/core/widgets/mosque_list_card.dart';
import 'package:mosques_app/features/mosque_search/views/widgets/mosque_list_header.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MosqueSkeletonList extends StatelessWidget {
  const MosqueSkeletonList({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      effect: const ShimmerEffect(
        baseColor: AppColor.surfaceContainerHigh,
        highlightColor: AppColor.surfaceBright,
        duration: Duration(milliseconds: 1200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: const MosqueListHeader(count: 5),
          ),
          SizedBox(height: 14.h),
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.h),
              itemCount: 5,
              separatorBuilder: (_, _) => SizedBox(height: 12.h),
              itemBuilder: (_, _) => MosqueListCard(
                name: 'Mosque Name Placeholder Long Text',
                distanceLabel: '1.2 km away',
                statusLabel: 'open',
                statusColor: AppColor.primaryColor1,
                amenities: const ['amenity_parking', 'amenity_wudu'],
                onTap: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}

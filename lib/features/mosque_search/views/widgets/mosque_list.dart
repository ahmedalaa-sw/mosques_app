import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosques_app/features/mosque_search/models/mosque_model.dart';
import 'mosque_card.dart';
import 'mosque_list_header.dart';

class MosqueList extends StatelessWidget {
  final List<MosqueModel> mosques;

  const MosqueList({super.key, required this.mosques});

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
            separatorBuilder: (_, _) => SizedBox(height: 12.h),
            itemBuilder: (_, i) => MosqueCard(mosque: mosques[i]),
          ),
        ),
      ],
    );
  }
}

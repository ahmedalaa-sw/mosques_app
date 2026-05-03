import 'package:flutter/material.dart';
import 'package:mosques_app/core/constants/app_colors.dart';
import 'package:mosques_app/core/constants/app_strings.dart';
import 'package:mosques_app/core/widgets/mosque_list_card.dart';
import 'package:mosques_app/features/mosque_search/models/mosque_model.dart';

class MosqueCard extends StatelessWidget {
  final MosqueModel mosque;
  final VoidCallback onTap;

  const MosqueCard({super.key, required this.mosque, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MosqueListCard(
      name: mosque.name,
      distanceLabel: mosque.distanceLabel,
      statusLabel: mosque.statusLabel,
      statusColor: _statusColor(),
      amenities: mosque.amenities,
      imageUrl: mosque.photoUrl,
      onTap: onTap,
    );
  }

  Color _statusColor() {
    if (mosque.isOpen == true) return AppColor.primaryColor;
    if (mosque.isOpen == false) return AppColor.errorColor;
    if (mosque.statusLabel == AppStrings.statusNotValid) {
      return AppColor.secondaryColor;
    }
    return AppColor.onSurfaceVariant;
  }
}

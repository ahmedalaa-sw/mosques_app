import 'package:flutter/material.dart';
import 'package:mosques_app/core/constants/app_colors.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColor.surfaceDim,
      body: Center(
        child: Text(
          'Favorites',
          style: TextStyle(color: AppColor.onSurface, fontSize: 20),
        ),
      ),
    );
  }
}

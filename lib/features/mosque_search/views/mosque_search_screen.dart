import 'package:flutter/material.dart';
import 'package:mosques_app/core/constants/app_colors.dart';

class MosqueSearchScreen extends StatelessWidget {
  const MosqueSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColor.surfaceDim,
      body: Center(
        child: Text(
          'Search Mosques',
          style: TextStyle(color: AppColor.onSurface, fontSize: 20),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class OnboardingIndicator extends StatelessWidget {
  final bool isActive;

  const OnboardingIndicator({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 10 : 6,
      height: isActive ? 10 : 6,
      decoration: BoxDecoration(
        color: isActive ? AppColors.green : Colors.grey[300],
        shape: BoxShape.circle,
      ),
    );
  }
}
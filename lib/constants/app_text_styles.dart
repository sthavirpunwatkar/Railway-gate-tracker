import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const TextStyle title = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.white,
  );

  static const TextStyle linkText = TextStyle(
    color: AppColors.accent,
    fontSize: 14,
  );

  static const TextStyle small = TextStyle(
    fontSize: 12,
    color: AppColors.black,
  );
}

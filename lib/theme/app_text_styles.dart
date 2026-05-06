import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 28, fontWeight: FontWeight.w900,
    color: AppColors.white, fontFamily: 'Cairo',
  );
  static const TextStyle heading2 = TextStyle(
    fontSize: 22, fontWeight: FontWeight.w900,
    color: AppColors.black, fontFamily: 'Cairo',
  );
  static const TextStyle subtitle = TextStyle(
    fontSize: 13, color: AppColors.gray, fontFamily: 'Cairo',
  );
  static const TextStyle body = TextStyle(
    fontSize: 14, color: AppColors.black, fontFamily: 'Cairo',
  );
  static const TextStyle bodyGray = TextStyle(
    fontSize: 13, color: AppColors.gray, fontFamily: 'Cairo',
  );
  static const TextStyle label = TextStyle(
    fontSize: 13, fontWeight: FontWeight.w700,
    color: AppColors.black, fontFamily: 'Cairo',
  );
  static const TextStyle btnText = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w700,
    color: AppColors.white, fontFamily: 'Cairo',
  );
  static const TextStyle link = TextStyle(
    fontSize: 13, fontWeight: FontWeight.w700,
    color: AppColors.teal, fontFamily: 'Cairo',
  );
}

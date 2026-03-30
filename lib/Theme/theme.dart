import 'package:flutter/material.dart';

class AppColors {
  static const Color dark = Color(0xFF000611);
  static const Color navy = Color(0xFF001F54);
  static const Color blue = Color(0xFF034078);
  static const Color teal = Color(0xFF1282A2);
  static const Color background = Color(0xFFFEFCFB);
  static const Color danger = Color(0xFFE11414);
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,

    primaryColor: AppColors.navy,
    colorScheme: const ColorScheme.light(
      primary: AppColors.navy,
      secondary: AppColors.teal,
      error: AppColors.danger,
      surface: AppColors.background,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.blue,
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.dark),
      bodyMedium: TextStyle(color: AppColors.dark),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.dark,

    colorScheme: const ColorScheme.dark(
      primary: AppColors.teal,
      secondary: AppColors.blue,
      error: AppColors.danger,
      surface: AppColors.dark,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.dark,
      foregroundColor: Colors.white,
    ),
  );
}

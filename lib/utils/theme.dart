// lib/utils/theme.dart
import 'package:flutter/material.dart';
import 'package:quiz_app/utils/constants.dart';

ThemeData appTheme() {
  return ThemeData(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: AppColors.secondary,
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(color: AppColors.text, fontSize: 24, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: AppColors.text, fontSize: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black, backgroundColor: AppColors.secondary,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    ),
  );
}
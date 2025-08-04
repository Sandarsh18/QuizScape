// lib/utils/constants.dart
import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF6A1B9A);
  static const Color primaryLight = Color(0xFFAB47BC);
  static const Color secondary = Color(0xFF1DE9B6);
  static const Color background = Color(0xFFF3E5F5);
  static const Color text = Colors.white;
  static const Color correct = Colors.green;
  static const Color incorrect = Colors.red;

  static const Map<String, Color> categoryColors = {
    'General Knowledge': Color(0xFF8E24AA),
    'Science & Nature': Color(0xFF43A047),
    'Technology': Color(0xFF1E88E5),
    'Sports': Color(0xFFF4511E),
    'History': Color(0xFF6D4C41),
    'Movies': Color(0xFFD81B60),
    'Geography': Color(0xFF00897B),
    'Mathematics': Color(0xFF3949AB),
  };

  static const List<Color> optionColors = [
    Color(0xFFB39DDB), // Light Purple
    Color(0xFFA5D6A7), // Light Green
    Color(0xFF90CAF9), // Light Blue
    Color(0xFFFFAB91), // Light Orange
    Color(0xFFFFCDD2), // Light Red
    Color(0xFFFFF59D), // Light Yellow
  ];
}
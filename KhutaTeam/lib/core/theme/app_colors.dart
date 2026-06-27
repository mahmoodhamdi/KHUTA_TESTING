import 'package:flutter/material.dart';

class AppColors {
  // Base Colors
  static const softBlue = Color(0xFF5A9BF6);
  static const calmGreen = Color(0xFFA1C398);
  static const mildYellow = Color(0xFFF7D774);
  static const softWhite = Color(0xFFFAFAFA);
  static const darkGray = Color(0xFF333333);
  static const darkBackground = Color(0xFF121212);

  // Light Theme Colors
  static const lightBackground = softWhite;
  static const lightSurface = Colors.white;
  static const lightText = darkGray;

  // Dark Theme Colors
  static const darkSurface = Color(0xFF1E1E1E);
  static const darkText = softWhite;

  // Semantic Colors
  static const success = calmGreen;
  static const warning = mildYellow;
  static const error = Color(0xFFFF6B6B);
  static const info = softBlue;
}

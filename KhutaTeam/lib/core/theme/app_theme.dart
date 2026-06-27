import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  static final _baseTheme = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: AppColors.softBlue,
  );

  static ThemeData lightTheme(BuildContext context) => _baseTheme.copyWith(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    textTheme: _getTextTheme(AppColors.lightText, context),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.softWhite,
      foregroundColor: AppColors.darkGray,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.softBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.softBlue),
      ),
    ),
  );

  static ThemeData darkTheme(BuildContext context) => _baseTheme.copyWith(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    textTheme: _getTextTheme(AppColors.darkText, context),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.softWhite,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.softBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade800),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.softBlue),
      ),
    ),
  );

  static TextTheme _getTextTheme(Color textColor, BuildContext context) {
    final locale = context.locale.languageCode;
    final isArabic = locale == 'ar';

    final headlineFont = isArabic ? GoogleFonts.cairo : GoogleFonts.poppins;
    final bodyFont = isArabic ? GoogleFonts.cairo : GoogleFonts.roboto;

    return TextTheme(
      displayLarge: headlineFont(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      displayMedium: headlineFont(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      displaySmall: headlineFont(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineMedium: headlineFont(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleLarge: headlineFont(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      bodyLarge: bodyFont(fontSize: 16, color: textColor),
      bodyMedium: bodyFont(fontSize: 14, color: textColor),
      labelLarge: headlineFont(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
    ).apply(bodyColor: textColor, displayColor: textColor);
  }
}

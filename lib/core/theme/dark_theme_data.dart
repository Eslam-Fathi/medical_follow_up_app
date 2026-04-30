import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medical_follow_up_app/core/utils/colors.dart' show AppColors, HealthCareColors;


// healtec_dark_theme.dart
final ThemeData healtecDarkTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  primaryColor: HealthCareColors.primary,
  scaffoldBackgroundColor: HealthCareColors.darkBackground,
  
  colorScheme: ColorScheme.dark(
    primary: HealthCareColors.primary,
    primaryContainer: const Color(0xFF4F46E5),
    secondary: HealthCareColors.primaryLight,
    tertiary: const Color(0xFFFCD34D),
    surface: HealthCareColors.darkSurface,
    background: HealthCareColors.darkBackground,
    error: const Color(0xFFEF4444),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onTertiary: HealthCareColors.textPrimary,
    onSurface: HealthCareColors.darkTextPrimary,
    onBackground: HealthCareColors.darkTextPrimary,
    onError: Colors.white,
  ),
  
  appBarTheme: const AppBarTheme(
    backgroundColor: HealthCareColors.darkSurface,
    foregroundColor: HealthCareColors.darkTextPrimary,
    elevation: 1,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: HealthCareColors.darkTextPrimary,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
  ),
  
  cardTheme: CardThemeData(
    color: HealthCareColors.darkCardBackground,
    elevation: 0,
    shadowColor: Colors.black.withOpacity(0.3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    margin: const EdgeInsets.all(0),
  ),
  
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: HealthCareColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: HealthCareColors.primary,
      side: const BorderSide(
        color: HealthCareColors.primary,
        width: 1.5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    ),
  ),
  
  textTheme: GoogleFonts.interTextTheme(const TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: HealthCareColors.darkTextPrimary,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: HealthCareColors.darkTextPrimary,
    ),
    headlineLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: HealthCareColors.darkTextPrimary,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: HealthCareColors.darkTextPrimary,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: HealthCareColors.darkTextPrimary,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: HealthCareColors.darkTextPrimary,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: HealthCareColors.darkTextPrimary,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: HealthCareColors.darkTextSecondary,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: HealthCareColors.darkTextPrimary,
    ),
  )),
  
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: HealthCareColors.darkSurface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: HealthCareColors.darkBorder,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: HealthCareColors.darkBorder,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: HealthCareColors.primary,
        width: 2,
      ),
    ),
    hintStyle: const TextStyle(
      color: HealthCareColors.darkTextSecondary,
      fontSize: 14,
    ),
  ),
  
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: HealthCareColors.darkSurface,
    selectedItemColor: HealthCareColors.primary,
    unselectedItemColor: HealthCareColors.darkTextSecondary,
    elevation: 8,
    type: BottomNavigationBarType.fixed,
  ),
);

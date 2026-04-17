import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medical_follow_up_app/core/utils/colors.dart' show AppColors, HealthCareColors;



// healtec_theme.dart

final ThemeData healtecLightTheme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  primaryColor: HealthCareColors.primary,
  scaffoldBackgroundColor: HealthCareColors.background,
  
  colorScheme: ColorScheme.light(
    primary: HealthCareColors.primary,
    primaryContainer: HealthCareColors.primaryLight,
    secondary: HealthCareColors.primaryLighter,
    tertiary: HealthCareColors.accent,
    surface: Colors.white,
    background: HealthCareColors.background,
    error: const Color(0xFFEF4444),
    onPrimary: Colors.white,
    onSecondary: HealthCareColors.textPrimary,
    onTertiary: HealthCareColors.textPrimary,
    onSurface: HealthCareColors.textPrimary,
    onBackground: HealthCareColors.textPrimary,
    onError: Colors.white,
  ),
  
  appBarTheme: const AppBarTheme(
    backgroundColor: HealthCareColors.primary,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
  ),
  
  cardTheme: CardThemeData(
    color: HealthCareColors.cardBackground,
    elevation: 2,
    shadowColor: Colors.black.withOpacity(0.08),
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
      color: HealthCareColors.textPrimary,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: HealthCareColors.textPrimary,
    ),
    headlineLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: HealthCareColors.textPrimary,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: HealthCareColors.textPrimary,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: HealthCareColors.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: HealthCareColors.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: HealthCareColors.textPrimary,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: HealthCareColors.textSecondary,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: HealthCareColors.textPrimary,
    ),
  )),
  
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: HealthCareColors.borderLight,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: HealthCareColors.borderLight,
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
      color: HealthCareColors.textSecondary,
      fontSize: 14,
    ),
  ),
  
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: HealthCareColors.primary,
    unselectedItemColor: HealthCareColors.textSecondary,
    elevation: 8,
    type: BottomNavigationBarType.fixed,
  ),
);

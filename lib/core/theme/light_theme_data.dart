// theme.dart
import 'package:flutter/material.dart';
import 'package:medical_follow_up_app/core/utils/colors.dart' show AppColors, HealtecColors;



// healtec_theme.dart

final ThemeData healtecLightTheme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  primaryColor: HealtecColors.primary,
  scaffoldBackgroundColor: HealtecColors.background,
  
  colorScheme: ColorScheme.light(
    primary: HealtecColors.primary,
    primaryContainer: HealtecColors.primaryLight,
    secondary: HealtecColors.primaryLighter,
    tertiary: HealtecColors.accent,
    surface: Colors.white,
    background: HealtecColors.background,
    error: const Color(0xFFEF4444),
    onPrimary: Colors.white,
    onSecondary: HealtecColors.textPrimary,
    onTertiary: HealtecColors.textPrimary,
    onSurface: HealtecColors.textPrimary,
    onBackground: HealtecColors.textPrimary,
    onError: Colors.white,
  ),
  
  appBarTheme: const AppBarTheme(
    backgroundColor: HealtecColors.primary,
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
    color: HealtecColors.cardBackground,
    elevation: 2,
    shadowColor: Colors.black.withOpacity(0.08),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    margin: const EdgeInsets.all(0),
  ),
  
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: HealtecColors.primary,
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
      foregroundColor: HealtecColors.primary,
      side: const BorderSide(
        color: HealtecColors.primary,
        width: 1.5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    ),
  ),
  
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: HealtecColors.textPrimary,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: HealtecColors.textPrimary,
    ),
    headlineLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: HealtecColors.textPrimary,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: HealtecColors.textPrimary,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: HealtecColors.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: HealtecColors.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: HealtecColors.textPrimary,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: HealtecColors.textSecondary,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: HealtecColors.textPrimary,
    ),
  ),
  
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: HealtecColors.borderLight,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: HealtecColors.borderLight,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: HealtecColors.primary,
        width: 2,
      ),
    ),
    hintStyle: const TextStyle(
      color: HealtecColors.textSecondary,
      fontSize: 14,
    ),
  ),
  
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: HealtecColors.primary,
    unselectedItemColor: HealtecColors.textSecondary,
    elevation: 8,
    type: BottomNavigationBarType.fixed,
  ),
);

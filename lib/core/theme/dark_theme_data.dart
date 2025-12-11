// dark_theme.dart
import 'package:flutter/material.dart';
import 'package:medical_follow_up_app/core/utils/colors.dart' show AppColors, HealtecColors;


// healtec_dark_theme.dart
final ThemeData healtecDarkTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  primaryColor: HealtecColors.primary,
  scaffoldBackgroundColor: HealtecColors.darkBackground,
  
  colorScheme: ColorScheme.dark(
    primary: HealtecColors.primary,
    primaryContainer: const Color(0xFF4F46E5),
    secondary: HealtecColors.primaryLight,
    tertiary: const Color(0xFFFCD34D),
    surface: HealtecColors.darkSurface,
    background: HealtecColors.darkBackground,
    error: const Color(0xFFEF4444),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onTertiary: HealtecColors.textPrimary,
    onSurface: HealtecColors.darkTextPrimary,
    onBackground: HealtecColors.darkTextPrimary,
    onError: Colors.white,
  ),
  
  appBarTheme: const AppBarTheme(
    backgroundColor: HealtecColors.darkSurface,
    foregroundColor: HealtecColors.darkTextPrimary,
    elevation: 1,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: HealtecColors.darkTextPrimary,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
  ),
  
  cardTheme: CardThemeData(
    color: HealtecColors.darkCardBackground,
    elevation: 0,
    shadowColor: Colors.black.withOpacity(0.3),
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
      color: HealtecColors.darkTextPrimary,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: HealtecColors.darkTextPrimary,
    ),
    headlineLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: HealtecColors.darkTextPrimary,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: HealtecColors.darkTextPrimary,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: HealtecColors.darkTextPrimary,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: HealtecColors.darkTextPrimary,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: HealtecColors.darkTextPrimary,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: HealtecColors.darkTextSecondary,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: HealtecColors.darkTextPrimary,
    ),
  ),
  
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: HealtecColors.darkSurface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: HealtecColors.darkBorder,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: HealtecColors.darkBorder,
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
      color: HealtecColors.darkTextSecondary,
      fontSize: 14,
    ),
  ),
  
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: HealtecColors.darkSurface,
    selectedItemColor: HealtecColors.primary,
    unselectedItemColor: HealtecColors.darkTextSecondary,
    elevation: 8,
    type: BottomNavigationBarType.fixed,
  ),
);

import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1BAC6D);
  static const Color primaryDark = Color(0xFF148C54);
  static const Color primaryLight = Color(0xFF8ED4B4);
  static const Color accentDark = Color(0xFF3C7C5C);
  static const Color card = Color(0xFFB7DACC);
  static const Color textSecondary = Color(0xFF947C74);
}

// healtec_colors.dart

class HealthCareColors {
  // Light Theme Colors
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryLighter = Color(0xFFA5B4FC);
  static const Color background = Color(0xFFF3E8FF);
  static const Color cardBackground = Color(0xFFFAFAFA);
  static const Color accent = Color(0xFFFCD34D);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color borderLight = Color(0xFFE5E7EB);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCardBackground = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkBorder = Color(0xFF475569);

  // Aurora UI Gradients
  static const List<Color> auroraGradient = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF0EA5E9), // Azure
  ];

  static const List<Color> auroraDarkGradient = [
    Color(0xFF4338CA), // Deep Indigo
    Color(0xFF0369A1), // Deep Azure
  ];

  // Glassmorphism Helpers
  static Color glassBackground(bool isDark) => isDark 
    ? Colors.black.withOpacity(0.3) 
    : Colors.white.withOpacity(0.7);
  
  static Color glassBorder(bool isDark) => isDark 
    ? Colors.white.withOpacity(0.1) 
    : Colors.white.withOpacity(0.5);
}

import 'package:flutter/material.dart';

/// Defines the color palettes used throughout the AuraMed application.
///
/// There are two separate color sets:
/// 1. **[AppColors]** — An older, greener palette from the initial prototype.
///    Kept for backward compatibility but not recommended for new code.
/// 2. **[HealthCareColors]** — The current, production palette used in both
///    [healtecLightTheme] and [healtecDarkTheme].
///
/// ### Design philosophy
/// All colors are declared as `static const` members to ensure they are
/// compile-time constants. This means zero allocation overhead at runtime.
/// By grouping them into classes, we avoid polluting the global namespace and
/// make it easy to discover the full palette in one place.

// ─────────────────────────────────────────────────────────────────────────────
// LEGACY PALETTE (used in early prototypes — avoid in new code)
// ─────────────────────────────────────────────────────────────────────────────

/// The legacy green-centric color palette from the app's first iteration.
///
/// **Deprecated pattern:** These are referenced directly by name in older
/// widgets. New code should use [HealthCareColors] or the ambient [ThemeData].
class AppColors {
  static const Color primary = Color(0xFF1BAC6D); // Vibrant emerald green.
  static const Color primaryDark = Color(0xFF148C54); // Darker emerald for pressed states.
  static const Color primaryLight = Color(0xFF8ED4B4); // Lighter mint, used for backgrounds.
  static const Color accentDark = Color(0xFF3C7C5C); // Deep teal for accents.
  static const Color card = Color(0xFFB7DACC); // Soft mint card fill.
  static const Color textSecondary = Color(0xFF947C74); // Warm grey for secondary text.
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTIVE PRODUCTION PALETTE (used in ThemeData — healtec_colors)
// ─────────────────────────────────────────────────────────────────────────────

/// The current production color palette for the AuraMed / MedME application.
///
/// Organized into three sections:
/// - **Light theme colors** — used by [healtecLightTheme].
/// - **Dark theme colors** — used by [healtecDarkTheme].
/// - **Aurora gradients** — used by the gradient accents and backgrounds.
///
/// Additionally, two static helper methods — [glassBackground] and
/// [glassBorder] — compute opacity-adjusted colors for the
/// **glassmorphism** effect used on cards and overlays.
class HealthCareColors {
  // ── Light Theme ────────────────────────────────────────────────────────────

  /// The main brand color. An indigo/violet hue that gives a medical,
  /// trustworthy, and modern feel.
  static const Color primary = Color(0xFF6366F1);

  /// A lighter variant of the primary color, used for hover states and
  /// secondary highlights.
  static const Color primaryLight = Color(0xFF818CF8);

  /// An even lighter variant, used for background tints and disabled states.
  static const Color primaryLighter = Color(0xFFA5B4FC);

  /// The page/scaffold background in light mode — a very soft lavender.
  static const Color background = Color(0xFFF3E8FF);

  /// The background color of elevated card surfaces in light mode.
  static const Color cardBackground = Color(0xFFFAFAFA);

  /// A warm amber accent used for highlights, badges, and star ratings.
  static const Color accent = Color(0xFFFCD34D);

  /// The default body text color in light mode — near black for high contrast.
  static const Color textPrimary = Color(0xFF111827);

  /// The secondary/hint text color in light mode — a medium grey.
  static const Color textSecondary = Color(0xFF9CA3AF);

  /// The border color for cards and input fields in light mode.
  static const Color borderLight = Color(0xFFE5E7EB);

  // ── Dark Theme ─────────────────────────────────────────────────────────────

  /// The deepest background layer in dark mode (the app scaffold).
  ///
  /// A very dark navy-blue rather than pure black. This reduces eye strain
  /// and avoids the "AMOLED black" look.
  static const Color darkBackground = Color(0xFF0F172A);

  /// The surface color for cards, dialogs, and panels in dark mode.
  static const Color darkSurface = Color(0xFF1E293B);

  /// The background color for nested card elements within dark surfaces.
  static const Color darkCardBackground = Color(0xFF334155);

  /// The primary text color in dark mode — very light slate.
  static const Color darkTextPrimary = Color(0xFFF1F5F9);

  /// The secondary text color in dark mode — a lighter, muted slate.
  static const Color darkTextSecondary = Color(0xFFCBD5E1);

  /// The border color for elements in dark mode — medium-dark slate.
  static const Color darkBorder = Color(0xFF475569);

  // ── Gradient Accents (Aurora UI) ───────────────────────────────────────────

  /// A two-stop gradient from indigo to azure for light-mode decorative accents.
  ///
  /// Used for the desktop sidebar header, splash screen, and auth card
  /// decorative backgrounds.
  static const List<Color> auroraGradient = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF0EA5E9), // Azure
  ];

  /// A darker, more saturated version of [auroraGradient] for dark mode.
  static const List<Color> auroraDarkGradient = [
    Color(0xFF4338CA), // Deep Indigo
    Color(0xFF0369A1), // Deep Azure
  ];

  // ── Glassmorphism Helpers ──────────────────────────────────────────────────
  // Glassmorphism is a UI design trend where elements appear as frosted glass:
  // semi-transparent backgrounds with a blur backdrop filter.
  //
  // These methods return colors with the correct opacity for the current theme,
  // avoiding hard-coded values scattered throughout widget code.

  /// Returns a semi-transparent background color appropriate for glass cards.
  ///
  /// In dark mode, uses `black@30%` opacity for a dark-glass look.
  /// In light mode, uses `white@70%` opacity for a frosted-glass look.
  static Color glassBackground(bool isDark) => isDark
      ? Colors.black.withOpacity(0.3)
      : Colors.white.withOpacity(0.7);

  /// Returns a border color appropriate for glass card borders.
  ///
  /// Glass borders use white at very low opacity to create a subtle "rim"
  /// effect that separates the card from its blurred background.
  static Color glassBorder(bool isDark) => isDark
      ? Colors.white.withOpacity(0.1)
      : Colors.white.withOpacity(0.5);
}

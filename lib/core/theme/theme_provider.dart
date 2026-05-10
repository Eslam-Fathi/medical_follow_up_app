import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Manages the application's theme mode (light, dark, or system-default).
///
/// ### How Flutter theming works
/// Flutter's [MaterialApp] accepts a [ThemeMode] enum that tells it which
/// theme to apply:
/// - [ThemeMode.system] — Follow the OS setting (dark mode toggle in Settings).
/// - [ThemeMode.light]  — Always use [healtecLightTheme].
/// - [ThemeMode.dark]   — Always use [healtecDarkTheme].
///
/// ### Why a StateNotifier?
/// [StateNotifier] is a Riverpod primitive for managing mutable, immutable-state
/// objects. In this case, the "state" is a [ThemeMode] enum value. Any widget
/// that watches [themeModeProvider] is automatically rebuilt when the user
/// changes the theme.
///
/// ### Usage example
/// ```dart
/// // Toggle theme in a settings screen:
/// ref.read(themeModeProvider.notifier).cycleTheme();
///
/// // Apply a specific theme:
/// ref.read(themeModeProvider.notifier).toggleTheme(ThemeMode.dark);
///
/// // Watch the current theme in a widget:
/// final mode = ref.watch(themeModeProvider);
/// ```
class ThemeNotifier extends StateNotifier<ThemeMode> {
  /// Initializes with [ThemeMode.system] so the app respects the OS setting
  /// by default — no user preference is required for a good first experience.
  ThemeNotifier() : super(ThemeMode.system);

  /// Directly sets the theme to a specific [ThemeMode].
  ///
  /// Use this when you have an explicit radio button or dropdown that lets
  /// the user pick from Light / Dark / System.
  void toggleTheme(ThemeMode mode) {
    state = mode;
  }

  /// Cycles through themes in order: System → Light → Dark → System → ...
  ///
  /// This is useful for a single icon-button toggle that cycles through all
  /// three options without needing a dropdown or sheet.
  void cycleTheme() {
    if (state == ThemeMode.system) {
      state = ThemeMode.light;
    } else if (state == ThemeMode.light) {
      state = ThemeMode.dark;
    } else {
      state = ThemeMode.system;
    }
  }
}

/// A Riverpod provider that exposes [ThemeNotifier] and the current [ThemeMode].
///
/// Consumed in [main.dart] by the root [MedME] widget to set the active theme
/// on [MaterialApp.themeMode].
///
/// ```dart
/// // In MedME.build:
/// final currentThemeMode = ref.watch(themeModeProvider);
/// return MaterialApp(themeMode: currentThemeMode, ...);
/// ```
final themeModeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((
  ref,
) {
  return ThemeNotifier();
});

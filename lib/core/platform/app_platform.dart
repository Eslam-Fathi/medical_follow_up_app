import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

/// A static utility class for detecting the current runtime platform.
///
/// ### Why not use `Platform` directly?
/// Flutter's `dart:io` [Platform] class is **not available on Web**. Calling
/// `Platform.isAndroid` in a web build throws a runtime exception. The
/// [kIsWeb] constant from `flutter/foundation.dart` must be checked first.
///
/// This class encapsulates that guard check, so callers across the app can
/// safely write `AppPlatform.isAndroid` without worrying about the web guard.
///
/// ### Usage
/// ```dart
/// if (AppPlatform.isWeb) {
///   // Render web-optimized UI
/// } else if (AppPlatform.isMobile) {
///   // Render native mobile UI
/// }
/// ```
///
/// ### Where is it used?
/// - [AppIcons] uses [AppPlatform.isWeb] to choose between Material icons
///   (Web) and Feather icons (Mobile) for a consistent look on each platform.
/// - [NotificationService] uses [AppPlatform.isAndroid] to skip notification
///   initialization on web (where local notifications are not supported).
class AppPlatform {
  /// Returns `true` if the app is running in a web browser.
  ///
  /// Internally uses the Flutter-provided compile-time constant [kIsWeb],
  /// which is `true` regardless of the OS the browser runs on.
  static bool get isWeb => kIsWeb;

  /// Returns `true` if running natively on an Android device or emulator.
  ///
  /// **Note:** The `!kIsWeb` guard is mandatory. [Platform.isAndroid] throws
  /// an [UnsupportedError] on web, so we must check [kIsWeb] first.
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;

  /// Returns `true` if running natively on an iPhone or iPad.
  static bool get isIOS => !kIsWeb && Platform.isIOS;

  /// Returns `true` if running on any native mobile platform (Android or iOS).
  ///
  /// This is the most common check for mobile-specific logic such as:
  /// - Showing native back buttons.
  /// - Using touch-specific gesture recognizers.
  static bool get isMobile => isAndroid || isIOS;

  /// Returns `true` if running as a native desktop app (macOS, Windows, Linux).
  ///
  /// Desktop builds are distinct from web builds even though both run on
  /// a computer. For example, local notifications work on desktop but not web.
  static bool get isDesktop =>
      !kIsWeb &&
      (Platform.isMacOS || Platform.isWindows || Platform.isLinux);
}

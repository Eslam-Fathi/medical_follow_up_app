import 'package:flutter/material.dart';

/// A utility class with static helpers for determining the current screen
/// size category (mobile, tablet, desktop) based on the device's viewport width.
///
/// ### Why not use `LayoutBuilder`?
/// [LayoutBuilder] is great for widget-level responsiveness (it reacts to the
/// parent's constraints). This class uses [MediaQuery.of(context).size.width],
/// which reflects the *entire screen* width, making it suitable for
/// **screen-level** layout decisions such as:
/// - Choosing between a bottom navigation bar (mobile) and a sidebar (desktop).
/// - Deciding whether to show a full-width list or a constrained two-column grid.
///
/// ### Breakpoints
/// | Category | Width range       |
/// |----------|-------------------|
/// | Mobile   | < 600 px          |
/// | Tablet   | 600 px – 1023 px  |
/// | Desktop  | ≥ 1024 px         |
///
/// These breakpoints follow the Material 3 / Flutter web design guidelines.
///
/// ### Usage
/// ```dart
/// final isDesktop = Responsive.isDesktop(context);
/// return isDesktop ? DesktopLayout() : MobileLayout();
/// ```
class Responsive {
  /// Returns `true` if the current screen width is less than 600 logical pixels.
  ///
  /// This covers phones in both portrait and landscape orientation.
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  /// Returns `true` if the current screen width is between 600 and 1023 px.
  ///
  /// This covers tablets and large phones (iPad, Android tablets).
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1024;

  /// Returns `true` if the current screen width is 1024 px or wider.
  ///
  /// This covers desktop browsers, laptops, and large external monitors.
  /// The home screen uses this to switch from bottom navigation to a sidebar.
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;
}

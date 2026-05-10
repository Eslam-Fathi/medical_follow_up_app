import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import '../platform/app_platform.dart';

/// A centralized registry of icon assets used throughout the AuraMed app.
///
/// ### Design Rationale: Platform-Adaptive Icons
/// AuraMed runs on both mobile (Android/iOS) and web. Each platform has its
/// own visual language:
///
/// - **Mobile** uses [FeatherIcons] — a lightweight, stroke-based icon set that
///   looks native and clean on small touchscreens.
/// - **Web** uses Material Design icons ([Icons.*]) — the standard icon family
///   for Material 3, which renders sharply at all DPIs in web browsers.
///
/// By centralizing all icon lookups in [AppIcons], the rest of the app never
/// needs to branch on the platform — it simply references `AppIcons.home` and
/// gets the right icon automatically.
///
/// ### Pattern
/// Each property is a static getter that returns one of two [IconData] values
/// depending on [AppPlatform.isWeb]. Many icons also have a "filled" variant
/// (e.g. [homeFilled]) used when the navigation item is **active/selected**.
///
/// ### Usage
/// ```dart
/// BottomNavigationBarItem(
///   icon: Icon(AppIcons.home),
///   activeIcon: Icon(AppIcons.homeFilled),
///   label: 'Home',
/// )
/// ```
class AppIcons {
  // ─────────────────────────────────────────────────────────────────────────
  // NAVIGATION
  // ─────────────────────────────────────────────────────────────────────────

  /// Home icon (outline variant) for the inactive state of the Home tab.
  static IconData get home =>
      AppPlatform.isWeb ? Icons.home_outlined : FeatherIcons.home;

  /// Home icon (filled variant) for the active/selected state.
  static IconData get homeFilled =>
      AppPlatform.isWeb ? Icons.home : FeatherIcons.home;

  /// Calendar icon (outline) for the Appointments/Checks tab.
  static IconData get calendar =>
      AppPlatform.isWeb ? Icons.calendar_today_outlined : FeatherIcons.calendar;

  /// Calendar icon (filled) for when the Appointments tab is active.
  static IconData get calendarFilled =>
      AppPlatform.isWeb ? Icons.calendar_today : FeatherIcons.calendar;

  /// User/Profile icon (outline) for the Profile tab.
  static IconData get profile =>
      AppPlatform.isWeb ? Icons.person_outline : FeatherIcons.user;

  /// User/Profile icon (filled) for when the Profile tab is active.
  static IconData get profileFilled =>
      AppPlatform.isWeb ? Icons.person : FeatherIcons.user;

  /// Document/Reports icon (outline) for the medical records section.
  static IconData get reports =>
      AppPlatform.isWeb ? Icons.description_outlined : FeatherIcons.fileText;

  /// Document/Reports icon (filled) for when the reports section is active.
  static IconData get reportsFilled =>
      AppPlatform.isWeb ? Icons.description : FeatherIcons.fileText;

  /// Chat bubble icon (outline) for the Chatbot tab.
  static IconData get chat =>
      AppPlatform.isWeb ? Icons.chat_bubble_outline : FeatherIcons.messageCircle;

  /// Chat bubble icon (filled) for when the Chatbot tab is active.
  static IconData get chatFilled =>
      AppPlatform.isWeb ? Icons.chat_bubble : FeatherIcons.messageCircle;

  // ─────────────────────────────────────────────────────────────────────────
  // ACTIONS
  // ─────────────────────────────────────────────────────────────────────────

  /// Magnifying glass icon for search actions.
  static IconData get search =>
      AppPlatform.isWeb ? Icons.search : FeatherIcons.search;

  /// Sliders/filter icon for filtering lists (e.g., appointment filters).
  static IconData get filter =>
      AppPlatform.isWeb ? Icons.tune : FeatherIcons.sliders;

  /// Bell/notification icon for the notifications area.
  static IconData get notifications =>
      AppPlatform.isWeb ? Icons.notifications_none : FeatherIcons.bell;

  /// Hamburger menu icon for opening drawers or menus.
  static IconData get menu =>
      AppPlatform.isWeb ? Icons.menu : FeatherIcons.menu;

  /// Settings/gear icon for the settings screen.
  static IconData get settings =>
      AppPlatform.isWeb ? Icons.settings_outlined : FeatherIcons.settings;

  /// Heart icon (outline) — used for the "Care Team" button.
  static IconData get heart =>
      AppPlatform.isWeb ? Icons.favorite_border : FeatherIcons.heart;

  /// Heart icon (filled) — used when the care team panel is open.
  static IconData get heartFilled =>
      AppPlatform.isWeb ? Icons.favorite : FeatherIcons.heart;

  /// Star icon (outline) — used for doctor ratings.
  static IconData get star =>
      AppPlatform.isWeb ? Icons.star_border : FeatherIcons.star;

  /// Star icon (filled) — used for active/rated stars.
  static IconData get starFilled =>
      AppPlatform.isWeb ? Icons.star : FeatherIcons.star;

  /// Right-pointing arrow for "see all" links and navigation cues.
  static IconData get arrowRight =>
      AppPlatform.isWeb ? Icons.arrow_forward : FeatherIcons.arrowRight;

  // ─────────────────────────────────────────────────────────────────────────
  // STATUS
  // ─────────────────────────────────────────────────────────────────────────

  /// Heart-rate / activity icon for health monitoring indicators.
  static IconData get activity =>
      AppPlatform.isWeb ? Icons.monitor_heart_outlined : FeatherIcons.activity;

  /// Clock icon for displaying times and upcoming event countdowns.
  static IconData get clock =>
      AppPlatform.isWeb ? Icons.access_time : FeatherIcons.clock;

  /// Check-circle icon for completed or confirmed statuses.
  static IconData get checkCircle =>
      AppPlatform.isWeb ? Icons.check_circle_outline : FeatherIcons.checkCircle;

  /// Alert/error-circle icon for warning or error statuses.
  static IconData get alertCircle =>
      AppPlatform.isWeb ? Icons.error_outline : FeatherIcons.alertCircle;

  /// Info icon for informational tooltips and help text.
  static IconData get info =>
      AppPlatform.isWeb ? Icons.info_outline : FeatherIcons.info;

  // ─────────────────────────────────────────────────────────────────────────
  // LOCATION / COMMUNICATION
  // ─────────────────────────────────────────────────────────────────────────

  /// Location pin icon for displaying clinic addresses.
  static IconData get mapPin =>
      AppPlatform.isWeb ? Icons.place_outlined : FeatherIcons.mapPin;

  /// Phone icon for displaying doctor or clinic contact numbers.
  static IconData get phone =>
      AppPlatform.isWeb ? Icons.phone_in_talk_outlined : FeatherIcons.phone;
}

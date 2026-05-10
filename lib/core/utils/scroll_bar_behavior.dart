import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A custom [ScrollBehavior] that controls two platform-specific scroll traits:
///
/// ### 1. Scrollbar Visibility
/// By default, Flutter Web shows a native-looking scrollbar for all scrollable
/// widgets. On native mobile (Android/iOS), Flutter renders no scrollbar,
/// which matches the platform's UI convention.
///
/// This class **only shows scrollbars on Web** (`kIsWeb == true`), keeping
/// the mobile experience clean while making content navigability obvious
/// for desktop-browser users.
///
/// ### 2. Allowed Pointer Devices for Dragging
/// By default, [MaterialScrollBehavior] only allows **touch** input to drag
/// scrollable areas. This means a mouse on desktop-web cannot drag a list
/// by clicking and dragging it — a common user expectation.
///
/// The overridden [dragDevices] getter enables scrolling via:
/// - [PointerDeviceKind.touch] — Finger on touchscreen (default).
/// - [PointerDeviceKind.mouse] — Click-and-drag with a mouse (desktop web/Linux).
/// - [PointerDeviceKind.trackpad] — Two-finger scroll on a laptop trackpad.
///
/// ### How it is applied
/// This behavior is set globally on [MaterialApp.scrollBehavior] in [main.dart],
/// so every [ListView], [SingleChildScrollView], [PageView], etc. in the app
/// automatically inherits these rules.
class NoScrollbarScrollBehavior extends MaterialScrollBehavior {
  /// Builds the scrollbar widget for a scrollable area.
  ///
  /// - On **Web** (`kIsWeb`): wraps [child] in a [Scrollbar] widget so the
  ///   user can see where they are in a long list and click to jump.
  /// - On **mobile**: returns [child] unchanged (no scrollbar rendered).
  ///
  /// Parameters:
  /// - [context]  The build context (used for theme lookups internally by [Scrollbar]).
  /// - [child]    The actual scrollable content widget.
  /// - [details]  Provides the [ScrollController] that [Scrollbar] needs to
  ///              track the scroll position.
  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // Show scrollbars only on Web
    if (kIsWeb) {
      return Scrollbar(
        controller: details.controller,
        child: child,
      );
    }
    return child;
  }

  /// The set of pointer devices that are allowed to initiate a drag-scroll gesture.
  ///
  /// Overriding this getter is necessary because [MaterialScrollBehavior]'s
  /// default only includes [PointerDeviceKind.touch]. Without this override,
  /// mouse users on desktop web could not drag-scroll lists.
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,    // Touchscreen finger
        PointerDeviceKind.mouse,    // Desktop mouse click-drag
        PointerDeviceKind.trackpad, // Laptop two-finger scroll
      };
}

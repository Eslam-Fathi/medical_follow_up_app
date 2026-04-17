import 'package:flutter/material.dart';

/// A wrapper widget designed to constrain the maximum width of content on larger screens.
/// This prevents the UI (lists, forms, etc.) from becoming excessively stretched 
/// and hard to read on tablets or desktop views.
class ResponsiveWrapper extends StatelessWidget {
  /// The main content to display inside the constrained box.
  final Widget child;

  /// The maximum width the content is allowed to expand to.
  /// Standard modern forms and lists look best between 600 - 800 pixels.
  final double maxWidth;

  /// Optional background color for the wrapper container.
  final Color? backgroundColor;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.maxWidth = 800.0, // Default maximum width set to 800.
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // 1. We wrap the constrained area in a full-width Container.
    // 2. We set the background color to the theme's surface color (or provided color),
    //    so the "empty space" blends gracefully with the app's overall theme.
    return Container(
      color: backgroundColor ?? Theme.of(context).colorScheme.surface,
      width: double.infinity,
      child: Center(
        // ConstrainedBox limits the maximum width of its child. If the screen is wider 
        // than [maxWidth], the child will be centered and exactly [maxWidth] wide.
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}

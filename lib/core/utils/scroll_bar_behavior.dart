import 'package:flutter/material.dart';

class NoScrollbarScrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // Return child directly = no visible scrollbar
    return child;
  }
}

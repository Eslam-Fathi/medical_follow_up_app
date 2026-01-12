import 'package:flutter/material.dart';

import 'package:medical_follow_up_app/core/utils/colors.dart';
import 'package:medical_follow_up_app/core/utils/responsive.dart';

import 'package:medical_follow_up_app/features/home/presentation/view/widgets/drawer_content_widget.dart';


class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDeskTop = Responsive.isDesktop(context);

    return Drawer(
      
      // clipBehavior: !isDeskTop ? Clip.none : Clip.hardEdge,
      
      // Slightly tinted background like the home screen
      backgroundColor:
          isDark ? HealtecColors.darkBackground : HealtecColors.background,
      child: DrawerContentWidget(theme: theme, isDark: isDark),
    );
  }
}

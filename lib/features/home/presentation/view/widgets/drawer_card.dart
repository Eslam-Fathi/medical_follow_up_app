import 'package:flutter/material.dart';
import 'package:medical_follow_up_app/core/utils/colors.dart';

/// Container that visually groups menu items like a card with dividers.
class DrawerCard extends StatelessWidget {
  final List<Widget> children;

  const DrawerCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      color: isDark ? HealthCareColors.darkSurface : Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isDark
              ? HealthCareColors.darkBorder
              : HealthCareColors.borderLight.withOpacity(0.7),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i != 0)
              Divider(
                height: 1,
                thickness: 0.7,
                color: isDark
                    ? HealthCareColors.darkBorder
                    : HealthCareColors.borderLight.withOpacity(0.6),
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}


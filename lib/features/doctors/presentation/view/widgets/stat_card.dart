import 'package:flutter/material.dart';
import 'package:medical_follow_up_app/core/utils/colors.dart';

/// Single stat card (patients, years, rating, reviews)
/// A compact widget for displaying a single numerical statistic with an icon and label.
/// 
/// Commonly used to show doctor metrics like patient count, years of experience, or rating.
class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final ThemeData theme;

  const StatCard({super.key, 
    required this.icon,
    required this.value,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;

    return Flexible(
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: HealthCareColors.primary,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark
                  ? HealthCareColors.darkTextSecondary
                  : HealthCareColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}



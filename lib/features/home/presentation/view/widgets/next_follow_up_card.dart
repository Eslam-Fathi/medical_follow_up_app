import 'package:flutter/material.dart';
import 'package:medical_follow_up_app/core/theme/app_icons.dart';
import 'package:medical_follow_up_app/core/utils/colors.dart';

class NextFollowUpCard extends StatelessWidget {
  const NextFollowUpCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      color: isDark
          ? HealtecColors.darkCardBackground
          : HealtecColors.primaryLighter.withOpacity(0.35),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Left: details text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Next follow-up',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: isDark
                          ? HealtecColors.darkTextPrimary
                          : HealtecColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                       Icon(
                        AppIcons.calendar,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Today • 5:30 PM',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                       Icon(
                        AppIcons.mapPin,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Cardiology Clinic, Floor 3',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: details
                    },
                    icon:  Icon(
                      AppIcons.arrowRight,
                      size: 16,
                    ),
                    label: const Text('View details'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      textStyle: const TextStyle(fontSize: 14),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Right: icon container / illustration
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? HealtecColors.darkSurface
                    : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              child:  Icon(
                AppIcons.activity,
                size: 32,
                color: HealtecColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

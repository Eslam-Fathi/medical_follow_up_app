import 'package:flutter/material.dart';
import 'package:medical_follow_up_app/core/theme/app_icons.dart';
import 'package:medical_follow_up_app/core/utils/colors.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.isDark,
    required this.theme,
  });

  final bool isDark;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isDark
          ? HealtecColors.darkSurface
          : Colors.white, // light card
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
             CircleAvatar(
              radius: 24,
              backgroundColor: HealtecColors.primary,
              child: Icon(
                AppIcons.profileFilled,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Eslam Fathi',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Patient ID: 123456',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? HealtecColors.darkTextSecondary
                          : HealtecColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


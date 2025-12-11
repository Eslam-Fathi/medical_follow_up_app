import 'package:flutter/material.dart';
import 'package:medical_follow_up_app/core/theme/app_icons.dart';
import 'package:medical_follow_up_app/core/utils/colors.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback? onMenuPressed;
  final VoidCallback? onCareTeamPressed; // NEW

  const HomeHeader({
    super.key,
    this.onMenuPressed,
    this.onCareTeamPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // Menu icon (opens left drawer)
            IconButton(
              icon:  Icon(AppIcons.menu),
              onPressed: onMenuPressed,
            ),
            const SizedBox(width: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello,',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Welcome, Eslam',
                  style: theme.textTheme.headlineMedium,
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            // Care team icon (opens end drawer)
            IconButton(
              onPressed: onCareTeamPressed,
              icon:  Icon(AppIcons.heart), // or AppIcons.activity / people icon
              tooltip: 'Your care team',
            ),
            IconButton(
              onPressed: () {
                // TODO: notifications
              },
              icon:  Icon(AppIcons.notifications),
            ),
            const SizedBox(width: 4),
             CircleAvatar(
              radius: 18,
              backgroundColor: HealtecColors.primary,
              child: Icon(
                AppIcons.profileFilled,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

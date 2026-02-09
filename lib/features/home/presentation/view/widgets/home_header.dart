import 'package:flutter/material.dart';
import 'package:medical_follow_up_app/core/theme/app_icons.dart';
import 'package:medical_follow_up_app/core/utils/colors.dart';
import 'package:medical_follow_up_app/core/utils/responsive.dart';

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
    final isDeskTop = Responsive.isDesktop(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // Menu icon (opens left drawer)
            isDeskTop
                ? const SizedBox.shrink()
                :
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
                  'Welcome, Ahmed',
                  style: theme.textTheme.headlineMedium,
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            // Care team icon (opens end drawer)
            isDeskTop
                ? const SizedBox.shrink()
                :
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
              backgroundColor: HealthCareColors.primary,
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

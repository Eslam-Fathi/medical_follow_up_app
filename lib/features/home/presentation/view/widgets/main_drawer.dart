import 'package:flutter/material.dart';
import 'package:medical_follow_up_app/core/theme/app_icons.dart';
import 'package:medical_follow_up_app/core/utils/colors.dart';
import 'package:medical_follow_up_app/features/home/presentation/view/widgets/drawer_card.dart';
import 'package:medical_follow_up_app/features/home/presentation/view/widgets/drawer_item.dart';
import 'package:medical_follow_up_app/features/home/presentation/view/widgets/logout_card.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      // Slightly tinted background like the home screen
      backgroundColor:
          isDark ? HealtecColors.darkBackground : HealtecColors.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top close / app name row (optional)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Heal-Follow-up',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Profile card
              Card(
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
              ),

              const SizedBox(height: 24),

              // Section label
              Text(
                'General',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: isDark
                      ? HealtecColors.darkTextSecondary
                      : HealtecColors.textSecondary,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 8),

              // General menu items (grouped in a card)
              DrawerCard(
                children: [
                  DrawerItem(
                    icon: AppIcons.profile,
                    label: 'Profile',
                    onTap: () {
                      // TODO: navigate to profile
                      
                    },
                  ),
                  DrawerItem(
                    icon: AppIcons.settings,
                    label: 'Settings',
                    onTap: () {
                      // TODO: navigate to settings
                      
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Text(
                'Health',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: isDark
                      ? HealtecColors.darkTextSecondary
                      : HealtecColors.textSecondary,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 8),

              DrawerCard(
                children: [
                  DrawerItem(
                    icon: AppIcons.calendar,
                    label: 'Follow-up checks',
                    onTap: () {
                      // TODO: checks
                      
                    },
                  ),
                  DrawerItem(
                    icon: AppIcons.reports,
                    label: 'Medical records',
                    onTap: () {
                      // TODO: records
                      
                    },
                  ),
                  DrawerItem(
                    icon: AppIcons.activity,
                    label: 'Vitals & health metrics',
                    onTap: () {
                      // TODO: vitals
                      
                    },
                  ),
                  DrawerItem(
                    icon: AppIcons.phone,
                    label: 'Contact doctor',
                    onTap: () {
                      // TODO: telehealth / contact
                      
                    },
                  ),
                ],
              ),

              const Spacer(),

              // Logout card at bottom, red accent
              LogoutCard(
                onLogout: () {
                  // TODO: logout
                  
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


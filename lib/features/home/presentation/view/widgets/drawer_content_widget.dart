import 'package:flutter/material.dart';
import 'package:medical_follow_up_app/core/theme/app_icons.dart';
import 'package:medical_follow_up_app/core/utils/colors.dart';
import 'package:medical_follow_up_app/features/home/presentation/view/widgets/drawer_card.dart';
import 'package:medical_follow_up_app/features/home/presentation/view/widgets/drawer_item.dart';
import 'package:medical_follow_up_app/features/home/presentation/view/widgets/logout_card.dart';
import 'package:medical_follow_up_app/features/home/presentation/view/widgets/profile_card.dart';

class DrawerContentWidget extends StatelessWidget {
  const DrawerContentWidget({
    super.key,
    required this.theme,
    required this.isDark,
  });

  final ThemeData theme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SafeArea(

      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? HealthCareColors.darkBackground
              : HealthCareColors.background,
        ),
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
                  
                ],
              ),
              const SizedBox(height: 16),
            
              // Profile card
              ProfileCard(isDark: isDark, theme: theme),
            
              const SizedBox(height: 24),
            
              // Section label
              Text(
                'General',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: isDark
                      ? HealthCareColors.darkTextSecondary
                      : HealthCareColors.textSecondary,
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
                      ? HealthCareColors.darkTextSecondary
                      : HealthCareColors.textSecondary,
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

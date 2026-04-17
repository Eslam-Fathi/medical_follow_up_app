import 'package:flutter/material.dart';
import 'package:medical_follow_up_app/core/theme/app_icons.dart';
import 'package:medical_follow_up_app/core/utils/colors.dart';
import 'package:medical_follow_up_app/features/home/presentation/view/widgets/drawer_card.dart';
import 'package:medical_follow_up_app/features/home/presentation/view/widgets/drawer_item.dart';
import 'package:medical_follow_up_app/features/home/presentation/view/widgets/logout_card.dart';
import 'package:medical_follow_up_app/features/home/presentation/view/widgets/mock_record.dart';
import 'package:medical_follow_up_app/features/home/presentation/view/widgets/profile_card.dart';
import 'package:medical_follow_up_app/features/medical_record/presentation/view/medical_record_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_follow_up_app/core/theme/theme_provider.dart';

class DrawerContentWidget extends ConsumerWidget {
  const DrawerContentWidget({
    super.key,
    required this.theme,
    required this.isDark,
    required this.userName,
    required this.userEmail,
    required this.userRole,
    required this.onLogout,
  });

  final ThemeData theme;
  final bool isDark;

  final String userName;
  final String userEmail;
  final String userRole;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              // Top title
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

              // Profile card – we’ll pass user data to it
              ProfileCard(
                isDark: isDark,
                theme: theme,
                userName: userName,
                userEmail: userEmail,
                userRole: userRole,
              ),

              const SizedBox(height: 24),

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
                  DrawerItem(
                    icon: isDark ? Icons.dark_mode : Icons.light_mode,
                    label: 'Dark Mode',
                    trailing: Switch.adaptive(
                      value: isDark,
                      activeColor: HealthCareColors.primary,
                      onChanged: (val) {
                        ref.read(themeModeProvider.notifier).state =
                            val ? ThemeMode.dark : ThemeMode.light;
                      },
                    ),
                    onTap: () {
                      ref.read(themeModeProvider.notifier).state =
                          isDark ? ThemeMode.light : ThemeMode.dark;
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
                      // TODO
                    },
                  ),
                  DrawerItem(
                    icon: AppIcons.reports,
                    label: 'Medical records',
                    onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MedicalRecordScreen(
          patientRecord: kMockPatientRecord,
        ),
      ),
    );
  },

                  ),
                  DrawerItem(
                    icon: AppIcons.activity,
                    label: 'Vitals & health metrics',
                    onTap: () {
                      // TODO
                    },
                  ),
                  DrawerItem(
                    icon: AppIcons.phone,
                    label: 'Contact doctor',
                    onTap: () {
                      // TODO
                    },
                  ),
                ],
              ),

              const Spacer(),

              LogoutCard(
                onLogout: onLogout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

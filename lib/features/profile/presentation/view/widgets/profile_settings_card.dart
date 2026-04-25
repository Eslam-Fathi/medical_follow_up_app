import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_follow_up_app/core/theme/theme_provider.dart';
import 'package:medical_follow_up_app/core/utils/colors.dart';
import 'package:medical_follow_up_app/features/auth/presentation/manager/state/auth_notifier.dart';

/// Settings actions including theme toggle and logout.
class ProfileSettingsCard extends ConsumerWidget {
  const ProfileSettingsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settings & Account', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.lock_outline_rounded),
              title: const Text('Change password'),
              onTap: () {
                // TODO: navigate to change password
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Notifications'),
              onTap: () {
                // TODO
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
              title: const Text('Dark Mode'),
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
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.logout_rounded, color: colorScheme.error),
              title: Text(
                'Logout',
                style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Logout?'),
                    content: const Text('Are you sure you want to sign out?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: TextButton.styleFrom(foregroundColor: colorScheme.error),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  await ref.read(authNotifierProvider.notifier).logout();
                  if (!context.mounted) return;
                  Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:medical_follow_up_app/core/utils/colors.dart';
import 'package:medical_follow_up_app/core/utils/responsive.dart';
import 'package:medical_follow_up_app/features/home/presentation/view/widgets/drawer_content_widget.dart';

class MainDrawer extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String userRole;
  final VoidCallback onLogout;

  const MainDrawer({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userRole,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      backgroundColor:
          isDark ? HealthCareColors.darkBackground : HealthCareColors.background,
      child: DrawerContentWidget(
        theme: theme,
        isDark: isDark,
        userName: userName,
        userEmail: userEmail,
        userRole: userRole,
        onLogout: onLogout,
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Logout card at the bottom with red accent, matching the rounded style.
class LogoutCard extends StatelessWidget {
  final VoidCallback onLogout;

  const LogoutCard({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: Colors.red.withOpacity(0.06),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onLogout,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(
                Icons.logout,
                color: Colors.red,
              ),
              const SizedBox(width: 12),
              Text(
                'Logout',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Small reusable row used in profile cards to show:
/// [icon] + [label] (caption) + [value] (main text).
///
/// Example:
///   [heart icon]  Blood Type
///                  O+
class ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ProfileInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Leading icon that visually represents the piece of info.
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        // Text column expands to take remaining horizontal space.
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Small, subtle label (e.g. "Blood Type").
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),
              const SizedBox(height: 2),
              // Actual value (e.g. "O+").
              Text(value, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

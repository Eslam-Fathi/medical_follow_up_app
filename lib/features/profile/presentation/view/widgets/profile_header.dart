import 'package:flutter/material.dart';
import 'package:medical_follow_up_app/features/auth/data/models/login/login_response.dart';



/// Avatar + name + role (Doctor/Patient).
class ProfileHeader extends StatelessWidget {
  final UserDto  user;
  final bool isDoctor;
  final bool large;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.isDoctor,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = large ? 50.0 : 40.0;
    final textStyle = large
        ? theme.textTheme.titleLarge
        : theme.textTheme.titleMedium;

    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: radius,
            child: Text(
              _initials(user.name),
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user.name,
            style: textStyle?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            isDoctor ? 'Doctor' : 'Patient',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.hintColor),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}

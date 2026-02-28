import 'package:flutter/material.dart';
import 'profile_info_row.dart';
import 'package:medical_follow_up_app/features/auth/data/models/login/login_response.dart';

/// Shows email + phone (if available).
class ProfileAccountCard extends StatelessWidget {
  final UserDto user;
  final Map<String, dynamic>? patient;

  const ProfileAccountCard({
    super.key,
    required this.user,
    required this.patient,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Account', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            ProfileInfoRow(
              icon: Icons.email_outlined,
              label: 'Email',
              value: user.email,
            ),
            const SizedBox(height: 8),
            if (patient?['phone'] != null)
              ProfileInfoRow(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: patient!['phone'].toString(),
              ),
          ],
        ),
      ),
    );
  }
}

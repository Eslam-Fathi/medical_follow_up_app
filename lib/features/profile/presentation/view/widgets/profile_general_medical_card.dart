import 'package:flutter/material.dart';

/// Quick medical stats (Age, Gender, Blood type, ID) in a clean horizontal row.
class ProfileGeneralMedicalCard extends StatelessWidget {
  final Map<String, dynamic> patient;

  const ProfileGeneralMedicalCard({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            Icons.cake_outlined,
            'Age',
            '${patient['age'] ?? '—'} yrs',
          ),
          _buildDivider(),
          _buildStatItem(
            context,
            Icons.transgender_rounded,
            'Gender',
            patient['gender']?.toString() ?? '—',
          ),
          _buildDivider(),
          _buildStatItem(
            context,
            Icons.description_outlined,
            'Blood',
            patient['bloodType']?.toString() ?? '—',
          ),
           _buildDivider(),
          _buildStatItem(
            context,
            Icons.badge_outlined,
            'ID',
            patient['displayId']?.toString() ?? '—',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, size: 22, color: theme.colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.hintColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey.withOpacity(0.2),
    );
  }
}

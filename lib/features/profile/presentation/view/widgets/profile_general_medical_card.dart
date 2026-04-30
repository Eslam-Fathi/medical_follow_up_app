import 'package:flutter/material.dart';

/// Card that shows quick, high‑level medical stats for a patient:
/// Age, Gender, Blood type, and Display ID.
///
/// Designed as a single horizontal row to be used in the Profile screen.
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
          // Age stat (e.g. "54 yrs").
          _buildStatItem(
            context,
            Icons.cake_outlined,
            'Age',
            '${patient['age'] ?? '—'} yrs',
          ),
          _buildDivider(),

          // Gender stat (e.g. "MALE", "FEMALE").
          _buildStatItem(
            context,
            Icons.transgender_rounded,
            'Gender',
            patient['gender']?.toString() ?? '—',
          ),
          _buildDivider(),

          // Blood type stat (e.g. "O+").
          _buildStatItem(
            context,
            Icons.description_outlined,
            'Blood',
            patient['bloodType']?.toString() ?? '—',
          ),
          _buildDivider(),

          // Human‑friendly display ID (e.g. "P-0001").
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

  /// Helper to build a single stat item:
  /// icon + value (big) + label (small).
  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
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

  /// Vertical divider used between stat items.
  Widget _buildDivider() {
    return Container(height: 30, width: 1, color: Colors.grey.withOpacity(0.2));
  }
}

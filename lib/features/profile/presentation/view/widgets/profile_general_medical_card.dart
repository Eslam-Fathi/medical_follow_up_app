import 'package:flutter/material.dart';

class ProfileGeneralMedicalCard extends StatelessWidget {
  final Map<String, dynamic> patient;

  const ProfileGeneralMedicalCard({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'General medical info',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _InfoChip(
                  label: 'Age',
                  value: '${patient['age'] ?? '-'} yrs',
                ),
                _InfoChip(
                  label: 'Gender',
                  value: '${patient['gender'] ?? '-'}',
                ),
                _InfoChip(
                  label: 'Blood Type',
                  value: '${patient['bloodType'] ?? '-'}',
                ),
                _InfoChip(
                  label: 'Patient ID',
                  value: '${patient['displayId'] ?? '-'}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      label: Text(
        '$label: $value',
        style: theme.textTheme.bodySmall,
      ),
      backgroundColor:
          theme.colorScheme.surfaceVariant.withOpacity(0.6),
    );
  }
}

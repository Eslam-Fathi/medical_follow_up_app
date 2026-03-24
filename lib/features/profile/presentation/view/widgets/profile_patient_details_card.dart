import 'package:flutter/material.dart';
import 'package:medical_follow_up_app/features/profile/presentation/view/widgets/profile_info_row.dart';


/// Extra info for patient role.
class ProfilePatientDetailsCard extends StatelessWidget {
  final Map<String, dynamic> patient;

  const ProfilePatientDetailsCard({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    String formatList(dynamic value) {
      if (value is List && value.isNotEmpty) {
        return value.join(', ');
      }
      return 'None';
    }

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
            Text('Medical History', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ProfileInfoRow(
              icon: Icons.personal_injury_outlined,
              label: 'Chronic Diseases',
              value: formatList(patient['chronicDiseases']),
            ),
            const SizedBox(height: 8),
            ProfileInfoRow(
              icon: Icons.warning_amber_rounded,
              label: 'Allergies',
              value: formatList(patient['allergies']),
            ),
            const SizedBox(height: 8),
            if (patient['notes'] != null && patient['notes'].toString().isNotEmpty)
              ProfileInfoRow(
                icon: Icons.notes,
                label: 'Notes',
                value: patient['notes'].toString(),
              ),
          ],
        ),
      ),
    );
  }
}

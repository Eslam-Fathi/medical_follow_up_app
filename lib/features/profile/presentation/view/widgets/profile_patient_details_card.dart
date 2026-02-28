import 'package:flutter/material.dart';
import 'package:medical_follow_up_app/features/profile/presentation/view/widgets/profile_info_row.dart';


/// Extra info for patient role.
class ProfilePatientDetailsCard extends StatelessWidget {
  final Map<String, dynamic> patient;

  const ProfilePatientDetailsCard({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Patient details', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            if (patient['age'] != null)
              ProfileInfoRow(
                icon: Icons.cake_outlined,
                label: 'Age',
                value: patient['age'].toString(),
              ),
            if (patient['gender'] != null)
              ProfileInfoRow(
                icon: Icons.person_outline,
                label: 'Gender',
                value: patient['gender'].toString(),
              ),
            if (patient['address'] != null)
              ProfileInfoRow(
                icon: Icons.location_on_outlined,
                label: 'Address',
                value: patient['address'].toString(),
              ),
            if (patient['emergencyContact'] != null)
              ProfileInfoRow(
                icon: Icons.medical_services_outlined,
                label: 'Emergency contact',
                value: patient['emergencyContact'].toString(),
              ),
          ],
        ),
      ),
    );
  }
}

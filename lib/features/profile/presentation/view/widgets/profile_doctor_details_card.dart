import 'package:flutter/material.dart';
import 'profile_info_row.dart';

/// Extra info for doctor role.
class ProfileDoctorDetailsCard extends StatelessWidget {
  final Map<String, dynamic> doctor;

  const ProfileDoctorDetailsCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            Text('Doctor Details', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            if (doctor['status'] != null)
              ProfileInfoRow(
                icon: Icons.admin_panel_settings_outlined,
                label: 'Account Status',
                value: doctor['status'].toString().toUpperCase(),
              ),
            if (doctor['specialization'] != null)
              ProfileInfoRow(
                icon: Icons.local_hospital_outlined,
                label: 'Specialization',
                value: doctor['specialization'].toString(),
              ),
            if (doctor['yearsOfExperience'] != null)
              ProfileInfoRow(
                icon: Icons.timeline_outlined,
                label: 'Experience',
                value: '${doctor['yearsOfExperience']} years',
              ),
            if (doctor['licenseNumber'] != null)
              ProfileInfoRow(
                icon: Icons.badge_outlined,
                label: 'License Number',
                value: doctor['licenseNumber'].toString(),
              ),
          ],
        ),
      ),
    );
  }
}

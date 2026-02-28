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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Doctor details', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            if (doctor['specialization'] != null)
              ProfileInfoRow(
                icon: Icons.local_hospital_outlined,
                label: 'Specialization',
                value: doctor['specialization'].toString(),
              ),
            if (doctor['experienceYears'] != null)
              ProfileInfoRow(
                icon: Icons.timeline_outlined,
                label: 'Experience',
                value: '${doctor['experienceYears']} years',
              ),
            if (doctor['clinicAddress'] != null)
              ProfileInfoRow(
                icon: Icons.location_on_outlined,
                label: 'Clinic address',
                value: doctor['clinicAddress'].toString(),
              ),
          ],
        ),
      ),
    );
  }
}

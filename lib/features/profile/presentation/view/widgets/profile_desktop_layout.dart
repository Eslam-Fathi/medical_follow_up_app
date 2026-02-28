import 'package:flutter/material.dart';
import 'package:medical_follow_up_app/features/auth/data/models/login/login_response.dart';

import 'package:medical_follow_up_app/features/profile/data/network/profile_api.dart';

import 'profile_header.dart';
import 'profile_account_card.dart';
import 'profile_patient_details_card.dart';
import 'profile_doctor_details_card.dart';
import 'profile_settings_card.dart';

/// Desktop layout: two columns (left basic info, right details/settings).
class ProfileDesktopLayout extends StatelessWidget {
  final UserDto  user;
  final Map<String, dynamic>? patient;
  final Map<String, dynamic>? doctor;
  final bool isDoctor;

  const ProfileDesktopLayout({
    super.key,
    required this.user,
    required this.patient,
    required this.doctor,
    required this.isDoctor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT: avatar + title + account info
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    ProfileHeader(user: user, isDoctor: isDoctor, large: true),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: ProfileAccountCard(
                          user: user,
                          patient: patient,
                          // This card ignores layout, only data.
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 24),

              // RIGHT: patient/doctor details + settings
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    if (!isDoctor && patient != null)
                      ProfilePatientDetailsCard(patient: patient!),
                    if (isDoctor && doctor != null)
                      ProfileDoctorDetailsCard(doctor: doctor!),
                    const SizedBox(height: 16),
                    const ProfileSettingsCard(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

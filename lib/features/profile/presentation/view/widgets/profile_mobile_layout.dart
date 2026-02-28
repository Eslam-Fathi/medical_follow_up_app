import 'package:flutter/material.dart';
import 'package:medical_follow_up_app/features/auth/data/models/login/login_response.dart';

import 'profile_header.dart';
import 'profile_account_card.dart';
import 'profile_patient_details_card.dart';
import 'profile_doctor_details_card.dart';
import 'profile_settings_card.dart';

/// Mobile/tablet profile layout: single scrollable column.
class ProfileMobileLayout extends StatelessWidget {
  final UserDto user;
  final Map<String, dynamic>? patient;
  final Map<String, dynamic>? doctor;
  final bool isDoctor;
  final bool isMobile;

  const ProfileMobileLayout({
    super.key,
    required this.user,
    required this.patient,
    required this.doctor,
    required this.isDoctor,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfileHeader(user: user, isDoctor: isDoctor),
          const SizedBox(height: 24),
          ProfileAccountCard(user: user, patient: patient),
          const SizedBox(height: 16),
          if (!isDoctor && patient != null)
            ProfilePatientDetailsCard(patient: patient!)
          else if (isDoctor && doctor != null)
            ProfileDoctorDetailsCard(doctor: doctor!),
          const SizedBox(height: 24),
          const ProfileSettingsCard(),
        ],
      ),
    );
  }
}

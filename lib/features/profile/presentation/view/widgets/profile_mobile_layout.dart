import 'package:flutter/material.dart';
import 'package:medical_follow_up_app/features/auth/data/models/login/login_response.dart';
import 'package:medical_follow_up_app/features/profile/presentation/view/widgets/profile_general_medical_card.dart';

import 'profile_header.dart';
import 'profile_account_card.dart';
import 'profile_patient_details_card.dart';
import 'profile_doctor_details_card.dart';
import 'profile_settings_card.dart';
import 'profile_desktop_layout.dart'; // for ProfileGeneralMedicalCard

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Card(
        elevation: 12,
        shadowColor: colorScheme.shadow.withOpacity(0.22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileHeader(user: user, isDoctor: isDoctor),
              const SizedBox(height: 20),

              // Account card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ProfileAccountCard(user: user, patient: patient),
                ),
              ),
              const SizedBox(height: 16),
              // Patient / doctor medical info + details
              if (!isDoctor && patient != null) ...[
                ProfileGeneralMedicalCard(patient: patient!),
                const SizedBox(height: 16),
                ProfilePatientDetailsCard(patient: patient!),
              ] else if (isDoctor && doctor != null) ...[
                ProfileDoctorDetailsCard(doctor: doctor!),
              ],

              const SizedBox(height: 16),

              // Settings
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const ProfileSettingsCard(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:medical_follow_up_app/features/auth/data/models/login/login_response.dart';
import 'package:medical_follow_up_app/features/profile/presentation/view/widgets/profile_general_medical_card.dart';

import 'profile_header.dart';
import 'profile_account_card.dart';
import 'profile_patient_details_card.dart';
import 'profile_doctor_details_card.dart';
import 'profile_settings_card.dart';

import 'package:medical_follow_up_app/features/medical_record/presentation/view/medical_record_screen.dart';

/// Desktop / large-screen profile layout.
///
/// Uses a two-column card:
/// - LEFT: avatar + header + account basics
/// - RIGHT: patient/doctor details + settings & logout
/// A responsive layout for the Profile screen optimized for large displays.
///
/// Organizes profile information into a multi-column grid, making efficient
/// use of horizontal space on desktop and web.
class ProfileDesktopLayout extends StatelessWidget {
  final UserDto user;
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
    final colorScheme = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          // Prevent content from becoming too wide on ultra-wide screens.
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Card(
              elevation: 16,
              shadowColor: colorScheme.shadow.withOpacity(0.25),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              color: colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LEFT COLUMN: profile header + core account information.
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          ProfileHeader(
                            user: user,
                            isDoctor: isDoctor,
                            large: true, // bigger header on desktop.
                          ),
                          const SizedBox(height: 16),
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: ProfileAccountCard(
                                user: user,
                                patient: patient,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 24),

                    // RIGHT COLUMN: medical details and settings.
                    Expanded(
                      flex: 5,
                      child: Column(
                        children: [
                          // Patient-specific cards: medical record & history.
                          if (!isDoctor && patient != null) ...[
                            // CTA card to open full medical record screen.
                            Card(
                              elevation: 4,
                              color: colorScheme.primaryContainer.withOpacity(
                                0.4,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: ListTile(
                                leading: const Icon(Icons.medical_information),
                                title: const Text('View Full Medical Record'),
                                subtitle: const Text(
                                  'Access your health metrics and detailed history',
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MedicalRecordScreen(
                                        user: user,
                                        patientRecord: patient!,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Compact stats row (age, gender, blood type, ID).
                            ProfileGeneralMedicalCard(patient: patient!),
                            const SizedBox(height: 16),

                            // Collapsible chronic diseases / allergies / notes.
                            ProfilePatientDetailsCard(patient: patient!),
                          ],

                          // Doctor-specific professional details card.
                          if (isDoctor && doctor != null)
                            ProfileDoctorDetailsCard(doctor: doctor!),

                          const SizedBox(height: 16),

                          // Settings: theme toggle, logout, etc.
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

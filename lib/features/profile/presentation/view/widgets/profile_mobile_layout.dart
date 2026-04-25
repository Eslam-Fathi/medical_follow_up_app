import 'package:flutter/material.dart';
import 'package:medical_follow_up_app/features/auth/data/models/login/login_response.dart';
import 'package:medical_follow_up_app/features/profile/presentation/view/widgets/profile_general_medical_card.dart';

import 'profile_header.dart';
import 'profile_account_card.dart';
import 'profile_patient_details_card.dart';
import 'profile_doctor_details_card.dart';
import 'profile_settings_card.dart';
import 'profile_desktop_layout.dart'; // for ProfileGeneralMedicalCard

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_follow_up_app/features/auth/presentation/manager/state/auth_notifier.dart';
import 'package:medical_follow_up_app/features/medical_record/presentation/view/medical_record_screen.dart';

/// Mobile/tablet profile layout with entrance animations and premium redesign.
class ProfileMobileLayout extends ConsumerStatefulWidget {
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
  ConsumerState<ProfileMobileLayout> createState() => _ProfileMobileLayoutState();
}

class _ProfileMobileLayoutState extends ConsumerState<ProfileMobileLayout> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _animate(Widget child, int index) {
    final start = 0.1 * index;
    final end = start + 0.5;
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _controller,
        curve: Interval(start.clamp(0, 1), end.clamp(0, 1), curve: Curves.easeIn),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Interval(start.clamp(0, 1), end.clamp(0, 1), curve: Curves.easeOut),
        )),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _animate(ProfileHeader(user: widget.user, isDoctor: widget.isDoctor), 0),
          const SizedBox(height: 24),

          // Account & Common Info
          _animate(
            Card(
              elevation: 0,
              color: colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: ProfileAccountCard(user: widget.user, patient: widget.patient),
              ),
            ),
            1,
          ),
          const SizedBox(height: 16),

          // Medical Record Access (Patient Only)
          if (!widget.isDoctor && widget.patient != null) ...[
            _animate(
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primaryContainer.withOpacity(0.7),
                      colorScheme.primaryContainer.withOpacity(0.3),
                    ],
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MedicalRecordScreen(
                            user: widget.user,
                            patientRecord: widget.patient!,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.cardColor.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.medical_information_rounded, color: colorScheme.primary),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Full Medical Record',
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Health history and clinical data',
                                  style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded, size: 16, color: colorScheme.primary),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              2,
            ),
            const SizedBox(height: 16),
            _animate(ProfileGeneralMedicalCard(patient: widget.patient!), 3),
            const SizedBox(height: 16),
            _animate(ProfilePatientDetailsCard(patient: widget.patient!), 4),
          ] else if (widget.isDoctor && widget.doctor != null) ...[
            _animate(ProfileDoctorDetailsCard(doctor: widget.doctor!), 2),
          ],

          const SizedBox(height: 16),

          // Settings Section
          _animate(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Text(
                    'Preferences & Account',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.hintColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const ProfileSettingsCard(),
              ],
            ),
            5,
          ),
        ],
      ),
    );
  }
}

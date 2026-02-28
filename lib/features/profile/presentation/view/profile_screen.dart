import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:medical_follow_up_app/core/utils/responsive.dart';
import 'package:medical_follow_up_app/features/profile/presentation/manager/profile.provider.dart';


import 'widgets/profile_mobile_layout.dart';
import 'widgets/profile_desktop_layout.dart';

/// Profile screen that reads profileProvider and chooses mobile/desktop layout.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return profileAsync.when(
      loading: () => const Scaffold(
        
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(child: Text(err.toString())),
      ),
      data: (profile) {
        final user = profile.user;
        final patient = profile.patient;
        final doctor = profile.doctor;
        final isDoctor = user.role == 'DOCTOR';

        final isDesktop = Responsive.isDesktop(context);
        final isMobile = Responsive.isMobile(context);

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('Profile'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // TODO: navigate to EditProfileScreen later
                },
              ),
            ],
          ),
          body: SafeArea(
            child: isDesktop
                ? ProfileDesktopLayout(
                    user: user,
                    patient: patient,
                    doctor: doctor,
                    isDoctor: isDoctor,
                  )
                : ProfileMobileLayout(
                    user: user,
                    patient: patient,
                    doctor: doctor,
                    isDoctor: isDoctor,
                    isMobile: isMobile,
                  ),
          ),
        );
      },
    );
  }
}

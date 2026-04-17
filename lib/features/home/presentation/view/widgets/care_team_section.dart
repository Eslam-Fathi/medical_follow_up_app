import 'package:flutter/material.dart';
import 'package:medical_follow_up_app/core/theme/app_icons.dart';
import 'package:medical_follow_up_app/core/utils/colors.dart';
import 'package:medical_follow_up_app/features/doctors/data/models/doctor_model/doctor_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_follow_up_app/features/doctors/presentation/manager/care_team_provider.dart';
import 'package:medical_follow_up_app/features/doctors/presentation/view/care_team_detail_screen.dart';
import 'package:medical_follow_up_app/features/doctors/presentation/view/my_care_team_screen.dart';
import 'package:medical_follow_up_app/features/profile/data/network/profile_api.dart';

class CareTeamSection extends ConsumerWidget {
final ProfileResponse profile;

  const CareTeamSection({super.key, required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Read doctors from the shared_preferences provider
    final doctors = ref.watch(careTeamProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your care team',
              style: theme.textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const MyCareTeamScreen()
                ));
              },
              child: const Text('See all'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 170, // Increased height to prevent vertical overflow
          child: doctors.isEmpty 
              ? const Center(child: Text("No doctors added to care team yet.\nPlease add them from the doctor list.", textAlign: TextAlign.center))
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: doctors.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final doctor = doctors[index];
                    return _DoctorCard(doctor: doctor, profile: profile);
                  },
                ),
        ),
      ],
    );
  }
}

class _DoctorCard extends ConsumerWidget {
  final ProfileResponse profile;
  final DoctorModel doctor;

  const _DoctorCard({required this.doctor, required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        // Navigate to detail screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CareTeamDetailScreen(doctor: doctor, profile: profile),
          ),
        );
      },
      child: SizedBox(
        width: 180,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                     CircleAvatar(
                      radius: 18,
                      backgroundColor: HealthCareColors.primary,
                      child: Icon(
                        AppIcons.profileFilled,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                          ref.read(careTeamProvider.notifier).removeDoctor(doctor.id);
                      },
                      icon: const Icon(
                          Icons.favorite,
                          size: 18,
                          color: Colors.red,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: Text(
                    doctor.name,
                    style: theme.textTheme.bodyLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    doctor.specialty,
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                     Icon(
                      AppIcons.starFilled,
                      size: 14,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      doctor.rating,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

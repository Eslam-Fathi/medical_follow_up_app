import 'package:flutter/material.dart';
import 'package:medical_follow_up_app/core/theme/app_icons.dart';
import 'package:medical_follow_up_app/core/utils/colors.dart';
import 'package:medical_follow_up_app/features/doctors/data/models/doctor_model/doctor_model.dart';
import 'package:medical_follow_up_app/features/doctors/presentation/view/care_team_detail_screen.dart';
import 'package:medical_follow_up_app/features/profile/data/network/profile_api.dart';

class CareTeamSection extends StatelessWidget {
final ProfileResponse profile;

  const CareTeamSection({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // You can later inject this from a ViewModel / repository
    final doctors = [
      {
        'name': 'Dr. Ahmed Hassan',
        'specialty': 'Cardiologist',
        'rating': '4.9',
      },
      {
        'name': 'Dr. Sara Ali',
        'specialty': 'Endocrinologist',
        'rating': '4.8',
      },
    ];

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
                Navigator.of(context).pushNamed('/doctors_list');
              },
              child: const Text('See all'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: doctors.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final doctor = doctors[index];
              return _DoctorCard(doctor: doctor, profile: profile ,);
            },
          ),
        ),
      ],
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final ProfileResponse profile;
  final Map<String, String> doctor;

  const _DoctorCard({required this.doctor, required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        // Create a DoctorModel from the Map data
        final doctorModel = DoctorModel(
          id: doctor['id'] ?? '1',
          userId: doctor['userId'] ?? '2',
          name: doctor['name'] ?? '',
          specialty: doctor['specialty'] ?? '',
          rating: doctor['rating'] ?? '0',
          reviewCount: doctor['reviewCount'] ?? '0',
          patientsCount: doctor['patientsCount'] ?? '0+',
          yearsExperience: doctor['yearsExperience'] ?? '0',
          aboutMe: doctor['aboutMe'] ??
              'Experienced healthcare professional dedicated to providing quality medical care.',
        );

        // Navigate to detail screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CareTeamDetailScreen(doctor: doctorModel, profile: profile),
          ),
        );
        print("##############################################################");
        print('Tapped on ${doctor['name']}');
        print("user id: ${profile.user.id}");
        print("user name: ${profile.user.name}");
        print("##############################################################");
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
                        // TODO: favorite toggle
                      },
                      icon:  Icon(
                        AppIcons.heart,
                        size: 18,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  doctor['name']!,
                  style: theme.textTheme.bodyLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  doctor['specialty']!,
                  style: theme.textTheme.bodySmall,
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
                      doctor['rating']!,
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

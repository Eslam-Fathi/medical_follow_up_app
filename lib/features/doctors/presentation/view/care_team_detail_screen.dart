import 'package:flutter/material.dart';

import 'package:medical_follow_up_app/core/theme/app_icons.dart';
import 'package:medical_follow_up_app/core/utils/colors.dart';
import 'package:medical_follow_up_app/features/doctors/data/models/doctor_model/doctor_model.dart';

class CareTeamDetailScreen extends StatelessWidget {
  final DoctorModel doctor;

  const CareTeamDetailScreen({
    super.key,
    required this.doctor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with back button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    Text(
                      'Doctor Profile',
                      style: theme.textTheme.titleLarge,
                    ),
                    const Spacer(),
                    SizedBox(width: 48), // balance for back button
                  ],
                ),
              ),

              // Doctor photo card 
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20),
  child: DoctorPhotoCard(
    doctorName: doctor.name,
    specialty: doctor.specialty,
    rating: doctor.rating,
    reviewCount: doctor.reviewCount,
  ),
),

const SizedBox(height: 24),


              // Doctor image / avatar (large)
              // Padding(
              //   padding: const EdgeInsets.symmetric(vertical: 16),
              //   child: CircleAvatar(
              //     radius: 60,
              //     backgroundColor: HealtecColors.primary,
              //     child: Icon(
              //       AppIcons.profileFilled,
              //       size: 60,
              //       color: Colors.white,
              //     ),
              //   ),
              // ),

              // Doctor name
              // Text(
              //   doctor.name,
              //   style: theme.textTheme.headlineMedium?.copyWith(
              //     fontWeight: FontWeight.w700,
              //   ),
              // ),
              // const SizedBox(height: 4),

              // // Specialty
              // Text(
              //   doctor.specialty,
              //   style: theme.textTheme.bodyMedium?.copyWith(
              //     color: isDark
              //         ? HealtecColors.darkTextSecondary
              //         : HealtecColors.textSecondary,
              //   ),
              // ),

              const SizedBox(height: 8),

              // Rating + review count
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //      Icon(
              //       AppIcons.starFilled,
              //       size: 16,
              //       color: Colors.amber,
              //     ),
              //     const SizedBox(width: 4),
              //     Text(
              //       doctor.rating,
              //       style: theme.textTheme.bodyMedium?.copyWith(
              //         fontWeight: FontWeight.w600,
              //       ),
              //     ),
              //     const SizedBox(width: 4),
              //     Text(
              //       '(${doctor.reviewCount} reviews)',
              //       style: theme.textTheme.bodySmall?.copyWith(
              //         color: isDark
              //             ? HealtecColors.darkTextSecondary
              //             : HealtecColors.textSecondary,
              //       ),
              //     ),
              //   ],
              // ),

              const SizedBox(height: 24),

              // Stats row (patients, years, rating, reviews)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatCard(
                      icon: AppIcons.activity,
                      value: doctor.patientsCount,
                      label: 'Patients',
                      theme: theme,
                    ),
                    _StatCard(
                      icon: AppIcons.clock,
                      value: doctor.yearsExperience,
                      label: 'Years',
                      theme: theme,
                    ),
                    _StatCard(
                      icon: AppIcons.starFilled,
                      value: doctor.rating,
                      label: 'Rating',
                      theme: theme,
                    ),
                    _StatCard(
                      icon: Icons.chat_bubble_outline,
                      value: doctor.reviewCount,
                      label: 'Reviews',
                      theme: theme,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // About Me section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About Me',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? HealtecColors.darkSurface
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? HealtecColors.darkBorder
                              : HealtecColors.borderLight,
                        ),
                      ),
                      child: Text(
                        doctor.aboutMe,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Voice call button
                    SizedBox(
                      width: MediaQuery.of( context).size.width * 70 / 100,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: initiate voice call
                        },
                        icon:  Icon(AppIcons.phone),
                        label: const Text('Voice Call (14:30 - 16:00 PM)'),
                        style: ElevatedButton.styleFrom(
                          
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                          shape: RoundedRectangleBorder(
                            
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Message button
                    SizedBox(
                       width: MediaQuery.of( context).size.width * 60 / 100,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: open chat
                        },
                        icon: const Icon(Icons.message_outlined),
                        label: const Text('Send Message'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
         



              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// Single stat card (patients, years, rating, reviews)
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final ThemeData theme;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;

    return Flexible(
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: HealtecColors.primary,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark
                  ? HealtecColors.darkTextSecondary
                  : HealtecColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}


/// Doctor photo card with image placeholder
class DoctorPhotoCard extends StatelessWidget {
  final String doctorName;
  final String specialty;
  final String rating;
  final String reviewCount;

  const DoctorPhotoCard({super.key, 
    required this.doctorName,
    required this.specialty,
    required this.rating,
    required this.reviewCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(

      color: isDark ? HealtecColors.darkSurface : Colors.white,
      elevation: 80,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo placeholder
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: isDark
                    ? HealtecColors.darkCardBackground
                    : HealtecColors.primaryLighter.withOpacity(0.4),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    AppIcons.profileFilled,
                    size: 80,
                    color: HealtecColors.primary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Doctor Photo',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? HealtecColors.darkTextSecondary
                          : HealtecColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Bottom info section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctorName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    specialty,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? HealtecColors.darkTextSecondary
                          : HealtecColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                       Icon(
                        AppIcons.starFilled,
                        size: 14,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rating,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '($reviewCount reviews)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? HealtecColors.darkTextSecondary
                              : HealtecColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

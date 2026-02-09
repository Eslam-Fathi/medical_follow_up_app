import 'package:flutter/material.dart';
import 'package:medical_follow_up_app/core/theme/app_icons.dart';
import 'package:medical_follow_up_app/core/utils/colors.dart';

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

      color: isDark ? HealthCareColors.darkSurface : Colors.white,
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
                    ? HealthCareColors.darkCardBackground
                    : HealthCareColors.primaryLighter.withOpacity(0.4),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    AppIcons.profileFilled,
                    size: 80,
                    color: HealthCareColors.primary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Doctor Photo',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? HealthCareColors.darkTextSecondary
                          : HealthCareColors.textSecondary,
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
                          ? HealthCareColors.darkTextSecondary
                          : HealthCareColors.textSecondary,
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
                              ? HealthCareColors.darkTextSecondary
                              : HealthCareColors.textSecondary,
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

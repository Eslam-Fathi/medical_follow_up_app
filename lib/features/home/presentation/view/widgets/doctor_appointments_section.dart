import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_follow_up_app/core/theme/app_icons.dart';
import 'package:medical_follow_up_app/core/utils/colors.dart';
import 'package:medical_follow_up_app/features/appointments/presentation/manager/providers/appointments_provider.dart';
import 'package:medical_follow_up_app/features/appointments/data/models/appointment_model.dart';
import 'appointment_card.dart';

/// Compact "My Appointments" section for doctors.
///
/// Shows:
/// - Title + "See all" action
/// - A horizontal list of upcoming (pending/confirmed) appointments
///   or an empty/loader/error state.
/// A dashboard section for doctors displaying their upcoming appointments.
/// 
/// Filters and shows PENDING/CONFIRMED bookings in a horizontal scrollable list.
class DoctorAppointmentsSection extends ConsumerWidget {
  final VoidCallback onSeeAll;

  const DoctorAppointmentsSection({super.key, required this.onSeeAll});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // All appointments where the current user is the doctor.
    final appointmentsAsync = ref.watch(doctorAppointmentsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row: "My Appointments" + "See all" link.
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Appointments',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(onPressed: onSeeAll, child: const Text('See all')),
          ],
        ),
        const SizedBox(height: 12),

        appointmentsAsync.when(
          // Loading placeholder with fixed height to avoid layout jump.
          loading: () => const SizedBox(
            height: 140,
            child: Center(child: CircularProgressIndicator()),
          ),
          // Error state with a soft red background.
          error: (err, _) => Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(child: Text('Failed to load appointments')),
          ),
          data: (appointments) {
            // Keep only upcoming bookings: PENDING or CONFIRMED.
            final upcoming = appointments.where((app) {
              final status = app.status.toUpperCase();
              return status == 'PENDING' || status == 'CONFIRMED';
            }).toList();

            // Sort chronologically by date.
            upcoming.sort((a, b) => a.date.compareTo(b.date));

            if (upcoming.isEmpty) {
              // Empty-state card when there are no upcoming appointments.
              return Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? HealthCareColors.darkCardBackground
                      : HealthCareColors.primaryLighter.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text('No reserved appointments yet.'),
                ),
              );
            }

            // Horizontal list of upcoming appointments.
            return SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: upcoming.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 280,
                    margin: const EdgeInsets.only(right: 16),
                    child: AppointmentCard(
                      appointment: upcoming[index],
                      isDoctorView: true,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_follow_up_app/core/utils/colors.dart';
import 'package:medical_follow_up_app/features/appointments/presentation/manager/providers/appointments_provider.dart';
import 'package:medical_follow_up_app/features/appointments/data/models/appointment_model.dart';
import 'doctor_stat_card.dart';
import 'appointment_card.dart';
import 'recent_chats_section.dart';

class DoctorHomeContent extends ConsumerWidget {
  const DoctorHomeContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appointmentsAsync = ref.watch(doctorAppointmentsProvider);
    final filteredAsync = ref.watch(filteredDoctorAppointmentsProvider);
    final filterIndex = ref.watch(homeFilterProvider);

    final filterLabels = ['All', 'Upcoming', 'Missed', 'Completed'];

    return appointmentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (appointments) {
        // Calculate stats (ALWAYS based on full day list for context)
        final now = DateTime.now();
        final todayAppointments = appointments.where((app) {
          return app.date.year == now.year &&
                 app.date.month == now.month &&
                 app.date.day == now.day;
        }).toList();

        final pendingCount = appointments.where((app) => app.status.toUpperCase() == 'PENDING' && !app.isMissed).length;
        final confirmedToday = todayAppointments.where((app) => app.status.toUpperCase() == 'CONFIRMED').length;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // Stats Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  DoctorStatCard(
                    title: 'Today\'s Total',
                    value: todayAppointments.length.toString(),
                    icon: Icons.calendar_today,
                    color: HealthCareColors.primary,
                  ),
                  DoctorStatCard(
                    title: 'Pending',
                    value: pendingCount.toString(),
                    icon: Icons.pending_actions,
                    color: Colors.orange,
                  ),
                  DoctorStatCard(
                    title: 'Confirmed Today',
                    value: confirmedToday.toString(),
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                  DoctorStatCard(
                    title: 'Total Patients',
                    value: appointments.map((e) => e.patient.id).toSet().length.toString(),
                    icon: Icons.people_outline,
                    color: Colors.teal,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Appointments Heading
              Text(
                '${filterLabels[filterIndex]} Appointments',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // Appointments List
              filteredAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text('Error: $err'),
                data: (filteredList) {
                  if (filteredList.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark 
                            ? HealthCareColors.darkSurface 
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          'No ${filterLabels[filterIndex].toLowerCase()} appointments found.',
                          style: TextStyle(color: theme.hintColor),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return AppointmentCard(
                        appointment: filteredList[index],
                        isDoctorView: true,
                      );
                    },
                  );
                },
              ),
                
              const SizedBox(height: 32),
              const RecentChatsSection(),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}

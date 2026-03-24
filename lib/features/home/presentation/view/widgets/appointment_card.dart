// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:medical_follow_up_app/features/appointments/data/models/appointment_model.dart';
import 'package:medical_follow_up_app/features/appointments/presentation/view/doctor_appointment_detail_screen.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final bool isDoctorView;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.isDoctorView = false,
  });

  Color _statusColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (appointment.status) {
      case 'CONFIRMED':
        return scheme.primary;
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default: // PENDING
        return scheme.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr =
        '${appointment.date.toLocal()}'.split('.').first; // quick format

    final displayName = isDoctorView
        ? appointment.patient.user.name
        : 'Dr. ${appointment.doctor.user.name}';
    final displaySub = isDoctorView
        ? 'Patient'
        : appointment.doctor.specialization;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AppointmentDetailScreen(
              appointment: appointment,
              isDoctorView: isDoctorView,
            ),
          ),
        );
      },
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Top row: doctor + status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    displayName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(context).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    appointment.status,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _statusColor(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              displaySub,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 6),
                Text(
                  dateStr,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }
}

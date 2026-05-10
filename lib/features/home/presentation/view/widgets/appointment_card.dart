// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:medical_follow_up_app/features/appointments/data/models/appointment_model.dart';
import 'package:medical_follow_up_app/features/appointments/presentation/view/doctor_appointment_detail_screen.dart';
import 'package:medical_follow_up_app/features/chat/presentation/view/chat_screen.dart';
import 'package:medical_follow_up_app/features/medical_record/presentation/view/medical_record_form_screen.dart';

/// Reusable appointment card for both patient and doctor views.
///
/// - In patient view: shows doctor name + specialization.
/// - In doctor view: shows patient name + “Patient” and extra actions (Chat, Record).
/// A versatile card for displaying appointment details in a list.
/// 
/// Context-aware: shows doctor info for patients and patient info for doctors.
/// Includes status-colored labels and quick action buttons (Chat/Record) for doctors.
class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final bool isDoctorView;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.isDoctorView = false,
  });

  /// Returns a color representing the appointment status (with missed override).
  Color _statusColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (appointment.isMissed) return scheme.error;

    switch (appointment.status.toUpperCase()) {
      case 'CONFIRMED':
        return scheme.primary;
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default: // PENDING and any other unknown status.
        return scheme.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Quick date formatting; consider intl for production/localization.
    final dateStr = '${appointment.date.toLocal()}'.split('.').first;

    // Display name and subtitle depend on who is viewing.
    final displayName = isDoctorView
        ? appointment.patient.user.name
        : 'Dr. ${appointment.doctor.user.name}';
    final displaySub = isDoctorView
        ? 'Patient'
        : appointment.doctor.specialization;

    return GestureDetector(
      // Tap anywhere to open full appointment details.
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
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: name + status pill.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      displayName.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.hintColor,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(context).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      (appointment.isMissed ? 'MISSED' : appointment.status)
                          .toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _statusColor(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Subtitle: specialization or "Patient".
              Text(
                displaySub,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Date row.
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: theme.hintColor),
                  const SizedBox(width: 8),
                  Text(
                    dateStr,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),

              // Extra actions only for doctor view.
              if (isDoctorView) ...[
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Chat action.
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                chatPartnerName: displayName,
                                otherUserId: appointment.patient.user.id,
                              ),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Chat',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Medical record action (disabled for missed).
                    Expanded(
                      child: InkWell(
                        onTap: appointment.isMissed
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MedicalRecordFormScreen(
                                      patientDisplayId: appointment.patient.id,
                                      patientName:
                                          appointment.patient.user.name,
                                    ),
                                  ),
                                );
                              },
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_note,
                              size: 20,
                              color: appointment.isMissed
                                  ? theme.disabledColor
                                  : Colors.teal,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Record',
                              style: TextStyle(
                                color: appointment.isMissed
                                    ? theme.disabledColor
                                    : Colors.teal,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

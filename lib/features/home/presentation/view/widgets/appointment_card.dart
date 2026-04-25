// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:medical_follow_up_app/features/appointments/data/models/appointment_model.dart';
import 'package:medical_follow_up_app/features/appointments/presentation/view/doctor_appointment_detail_screen.dart';
import 'package:medical_follow_up_app/features/chat/presentation/view/chat_screen.dart';
import 'package:medical_follow_up_app/features/medical_record/presentation/view/medical_record_form_screen.dart';

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
    if (appointment.isMissed) return scheme.error;
    
    switch (appointment.status.toUpperCase()) {
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
              // Top row: doctor + status
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(context).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      (appointment.isMissed ? 'MISSED' : appointment.status).toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _statusColor(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                displaySub,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
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
              if (isDoctorView) ...[
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
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
                            Icon(Icons.chat_bubble_outline, size: 18, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Chat',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: appointment.isMissed ? null : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MedicalRecordFormScreen(
                                patientDisplayId: appointment.patient.id,
                                patientName: appointment.patient.user.name,
                              ),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_note, 
                              size: 20, 
                              color: appointment.isMissed ? theme.disabledColor : Colors.teal
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Record',
                              style: TextStyle(
                                color: appointment.isMissed ? theme.disabledColor : Colors.teal,
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_follow_up_app/features/appointments/data/models/appointment_model.dart';
import 'package:medical_follow_up_app/features/appointments/presentation/manager/providers/appointments_provider.dart';
import 'package:medical_follow_up_app/features/auth/data/models/login/login_response.dart';
import 'package:medical_follow_up_app/features/chat/presentation/view/chat_screen.dart';
import 'package:medical_follow_up_app/features/medical_record/presentation/view/medical_record_form_screen.dart';
import 'package:medical_follow_up_app/core/utils/responsive_wrapper.dart';
import 'package:medical_follow_up_app/features/medical_record/presentation/view/medical_record_screen.dart';

class AppointmentDetailScreen extends ConsumerStatefulWidget {
  final Appointment appointment;
  final bool isDoctorView;

  const AppointmentDetailScreen({
    super.key,
    required this.appointment,
    this.isDoctorView = true,
  });

  @override
  ConsumerState<AppointmentDetailScreen> createState() =>
      _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState
    extends ConsumerState<AppointmentDetailScreen> {
  bool _isLoading = false;

  Future<void> _updateStatus(String status) async {
    setState(() => _isLoading = true);
    try {
      final api = ref.read(appointmentsApiProvider);
      await api.updateAppointmentStatus(
        widget.appointment.id,
        status,
        widget.appointment.date,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Status updated to $status')));
        ref.invalidate(appointmentsProvider);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openMedicalRecordForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MedicalRecordFormScreen(
          // We pass the display ID if needed. For now we use the patient document ID.
          patientDisplayId: widget.appointment.patient.id,
          patientName: widget.appointment.patient.user.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appointment = widget.appointment;

    // Determine what name/info to show based on roles
    final displayName = widget.isDoctorView
        ? appointment.patient.user.name
        : 'Dr. ${appointment.doctor.user.name}';

    final displayEmail = widget.isDoctorView
        ? appointment.patient.user.email
        : appointment.doctor.user.email;

    final otherUserId = widget.isDoctorView
        ? appointment.patient.user.id
        : appointment.doctor.user.id;

    final infoTitle = widget.isDoctorView
        ? 'Patient Information'
        : 'Doctor Information';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isDoctorView ? 'Manage Appointment' : 'Appointment Details',
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ResponsiveWrapper(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    if (appointment.isMissed) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.colorScheme.error.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: theme.colorScheme.error),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Appointment Missed',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: theme.colorScheme.error,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'This pending appointment expired as it passed the 30-minute grace period without confirmation.',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onErrorContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    // Person Data (Patient/Doctor)
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              infoTitle,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(height: 24),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor:
                                    theme.colorScheme.primaryContainer,
                                child: Icon(
                                  widget.isDoctorView
                                      ? Icons.person
                                      : Icons.medical_services,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              title: Text(
                                displayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(displayEmail),
                            ),
                            if (!widget.isDoctorView &&
                                appointment.doctor.specialization.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 56.0),
                                child: Text(
                                  appointment.doctor.specialization,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Scheduled: ${appointment.date.toLocal().toString().split('.').first}',
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Status: ${appointment.isMissed ? 'MISSED' : appointment.status}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: appointment.isMissed 
                                        ? theme.colorScheme.error 
                                        : theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Medical record access block (ONLY for doctors)
                    if (widget.isDoctorView)
                      Card(
                        elevation: 2,
                        color: theme.colorScheme.primaryContainer.withOpacity(
                          0.4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.medical_information,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Medical Record',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Access and digitally update the patient\'s full medical record file with vitals and assessments.',
                              ),
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.dashboard_outlined),
                                label: const Text('View Health Dashboard'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  // Create a UserDto from the appointment patient user
                                  final patientUser = UserDto(
                                    id: appointment.patient.user.id,
                                    name: appointment.patient.user.name,
                                    email: appointment.patient.user.email,
                                    role: 'PATIENT',
                                  );

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MedicalRecordScreen(
                                        user: patientUser,
                                        patientRecord:
                                            const {}, // No clinical data in appointment model yet
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.edit_document),
                                label: const Text('Access & Edit Record'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  backgroundColor: appointment.isMissed 
                                      ? theme.disabledColor 
                                      : theme.colorScheme.primary,
                                  foregroundColor: appointment.isMissed 
                                      ? theme.colorScheme.onSurface.withOpacity(0.38)
                                      : theme.colorScheme.onPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: appointment.isMissed ? null : _openMedicalRecordForm,
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 32),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.chat),
                            label: const Text('Chat'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(
                                    chatPartnerName: displayName,
                                    otherUserId: otherUserId,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        if (widget.isDoctorView && !appointment.isMissed) ...[
                          const SizedBox(width: 16),
                          if (appointment.status == 'PENDING')
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.check),
                                label: const Text('Confirm'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                onPressed: () => _updateStatus('CONFIRMED'),
                              ),
                            )
                          else if (appointment.status == 'CONFIRMED')
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.check_circle),
                                label: const Text('Complete'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                onPressed: () => _updateStatus('COMPLETED'),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

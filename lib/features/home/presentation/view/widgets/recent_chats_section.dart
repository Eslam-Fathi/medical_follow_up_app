import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_follow_up_app/core/theme/app_icons.dart';
import 'package:medical_follow_up_app/core/utils/colors.dart';
import 'package:medical_follow_up_app/features/appointments/presentation/manager/providers/appointments_provider.dart';
import 'package:medical_follow_up_app/features/chat/presentation/view/chat_screen.dart';

class RecentChatsSection extends ConsumerWidget {
  const RecentChatsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appointmentsAsync = ref.watch(doctorAppointmentsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Patient Messages',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        appointmentsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => const Center(child: Text('Error loading patients')),
          data: (appointments) {
            // Get unique patients from appointments
            final patients = <String, String>{}; // userId -> name
            for (final app in appointments) {
              final id = app.patient.user.id;
              final name = app.patient.user.name;
              if (id.isNotEmpty) {
                patients[id] = name;
              }
            }

            if (patients.isEmpty) {
              return _buildEmptyPlaceholder(theme);
            }

            final patientIds = patients.keys.toList();

            return Column(
              children: patientIds.map((id) {
                final name = patients[id]!;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: const Icon(Icons.person),
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('Tap to open conversation'),
                    trailing: Icon(
                      AppIcons.chat,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            chatPartnerName: name,
                            otherUserId: id,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyPlaceholder(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? HealthCareColors.darkCardBackground
            : HealthCareColors.primaryLighter.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            AppIcons.chat,
            size: 40,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Patients with appointments will appear here.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

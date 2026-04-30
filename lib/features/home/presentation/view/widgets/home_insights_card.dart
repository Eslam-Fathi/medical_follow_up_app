import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_follow_up_app/core/utils/colors.dart';
import 'package:medical_follow_up_app/features/appointments/presentation/manager/providers/appointments_provider.dart';

/// A premium dashboard card for the home screen providing quick clinical insights.
///
/// - For doctors: shows "Today's Overview" with today’s total & pending appointments.
/// - For patients: shows simple health stats (blood type + placeholders for vitals).
class HomeInsightsCard extends ConsumerWidget {
  final String role;
  final Map<String, dynamic>? patientRecord;

  const HomeInsightsCard({super.key, required this.role, this.patientRecord});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDoctor = role.toUpperCase() == 'DOCTOR';
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // Gradient background for a "premium" dashboard look.
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withOpacity(0.8),
            colorScheme.secondary.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle background icon as decoration.
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              isDoctor ? Icons.analytics_outlined : Icons.favorite_outline,
              size: 140,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row: title + "Live" badge.
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isDoctor ? 'Today\'s Overview' : 'Health Pulse',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Live',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Different content for doctors vs patients.
                isDoctor
                    ? _buildDoctorInsights(ref, theme)
                    : _buildPatientInsights(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Doctor view: aggregates today's appointments for quick stats.
  Widget _buildDoctorInsights(WidgetRef ref, ThemeData theme) {
    final appointmentsAsync = ref.watch(doctorAppointmentsProvider);

    return appointmentsAsync.when(
      data: (appointments) {
        final now = DateTime.now();

        // Filter only today's appointments.
        final todayApps = appointments
            .where(
              (a) =>
                  a.date.year == now.year &&
                  a.date.month == now.month &&
                  a.date.day == now.day,
            )
            .toList();

        // Count pending & not missed appointments.
        final pending = todayApps
            .where((a) => a.status.toUpperCase() == 'PENDING' && !a.isMissed)
            .length;

        return Row(
          children: [
            _buildStatItem(
              theme,
              todayApps.length.toString(),
              'Total Today',
              Icons.people_outline,
            ),
            const SizedBox(width: 32),
            _buildStatItem(
              theme,
              pending.toString(),
              'Pending',
              Icons.pending_actions,
            ),
          ],
        );
      },
      loading: () => const SizedBox(
        height: 40,
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
      error: (_, __) => const Text(
        'Unable to load stats',
        style: TextStyle(color: Colors.white70),
      ),
    );
  }

  /// Patient view: currently shows blood type and placeholder stats.
  ///
  /// In the future you can plug in real vitals from a backend or wearable.
  Widget _buildPatientInsights(ThemeData theme) {
    final bloodType = patientRecord?['bloodType'] ?? '—';

    return Row(
      children: [
        _buildStatItem(
          theme,
          bloodType,
          'Blood Type',
          Icons.water_drop_outlined,
        ),
        const SizedBox(width: 32),
        _buildStatItem(theme, '—', 'Heart Rate', Icons.favorite_border),
        const SizedBox(width: 32),
        _buildStatItem(theme, '—', 'Sleep', Icons.bedtime_outlined),
      ],
    );
  }

  /// Reusable stat item (icon + label + value) used in the insights row.
  Widget _buildStatItem(
    ThemeData theme,
    String value,
    String label,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.white70),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

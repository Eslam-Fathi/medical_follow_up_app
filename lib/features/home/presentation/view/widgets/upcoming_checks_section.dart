import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_follow_up_app/core/theme/app_icons.dart';
import 'package:medical_follow_up_app/core/utils/colors.dart';
import 'package:medical_follow_up_app/features/appointments/presentation/manager/providers/appointments_provider.dart';
import 'package:medical_follow_up_app/features/appointments/data/models/appointment_model.dart';

/// Dashboard section showing a small list of upcoming/filtered checks.
///
/// Uses [filteredDashboardAppointmentsProvider] and [homeFilterProvider]
/// to drive both the title and the visible list.
/// A vertical list of upcoming medical appointments or checkups.
/// 
/// Displays a summary of each check (specialty, date) and its current status 
/// in a compact, scrollable format.
class UpcomingChecksSection extends ConsumerWidget {
  final VoidCallback onSeeAll;

  const UpcomingChecksSection({super.key, required this.onSeeAll});

  /// Formats an appointment date as:
  /// - "Today • 2:30 PM"
  /// - "Tomorrow • 9:00 AM"
  /// - "In 2 days • 4:00 PM"
  /// - "5 May • 11:00 AM" for further dates.
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    // Reset to start of day for accurate day-difference calculation.
    final dateDay = DateTime(date.year, date.month, date.day);
    final nowDay = DateTime(now.year, now.month, now.day);
    final difference = dateDay.difference(nowDay).inDays;

    // Build 12‑hour time string.
    final h = date.hour;
    final m = date.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final hr12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    final timeStr = '$hr12:$m $period';

    if (difference == 0) return 'Today • $timeStr';
    if (difference == 1) return 'Tomorrow • $timeStr';
    if (difference == 2) return 'In 2 days • $timeStr';
    if (difference == 3) return 'In 3 days • $timeStr';

    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} • $timeStr';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Appointments list already filtered by homeFilterProvider.
    final filteredAsync = ref.watch(filteredDashboardAppointmentsProvider);
    final filterIndex = ref.watch(homeFilterProvider);

    final filterLabels = ['All', 'Upcoming', 'Missed', 'Completed'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: "{Filter} checks" + "See all" action.
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${filterLabels[filterIndex]} checks',
              style: theme.textTheme.titleLarge,
            ),
            TextButton(onPressed: onSeeAll, child: const Text('See all')),
          ],
        ),
        const SizedBox(height: 8),

        filteredAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Could not load checks',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
              ),
            ),
          ),
          data: (filteredItems) {
            // Sort by date ascending before showing.
            final displayList = [...filteredItems];
            displayList.sort((a, b) => a.date.compareTo(b.date));

            if (displayList.isEmpty) {
              // Empty-state card when there are no items for the current filter.
              return Card(
                color: theme.brightness == Brightness.dark
                    ? HealthCareColors.darkCardBackground
                    : HealthCareColors.primaryLighter.withOpacity(0.2),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'No ${filterLabels[filterIndex].toLowerCase()} checks found.',
                      style: TextStyle(color: theme.hintColor),
                    ),
                  ),
                ),
              );
            }

            // Render up to 5 items as small cards.
            return Column(
              children: displayList.take(5).map((app) {
                final isCompleted = app.status.toUpperCase() == 'COMPLETED';

                final specialization = app.doctor.specialization.isNotEmpty
                    ? app.doctor.specialization
                    : 'General checkup';
                final title = 'Follow-up • $specialization';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: theme.colorScheme.primary.withOpacity(
                          0.1,
                        ),
                        child: Icon(
                          isCompleted ? AppIcons.checkCircle : AppIcons.clock,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      title: Text(title, style: theme.textTheme.bodyLarge),
                      subtitle: Text(
                        _formatDate(app.date),
                        style: theme.textTheme.bodySmall,
                      ),
                      trailing: _StatusPill(
                        status: app.status.toUpperCase(),
                        completed: isCompleted,
                        isMissed: app.isMissed,
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

/// Small pill used to display appointment status (MISSED, COMPLETED, etc.).
class _StatusPill extends StatelessWidget {
  final String status;
  final bool completed;
  final bool isMissed;

  const _StatusPill({
    required this.status,
    required this.completed,
    this.isMissed = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    if (isMissed) {
      bg = Colors.red.withOpacity(0.12);
      fg = Colors.red.shade700;
    } else if (completed) {
      bg = Colors.green.withOpacity(0.12);
      fg = Colors.green.shade700;
    } else {
      bg = HealthCareColors.accent.withOpacity(0.18);
      fg = Colors.orange.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isMissed ? 'MISSED' : status,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}

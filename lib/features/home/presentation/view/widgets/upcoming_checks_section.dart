import 'package:flutter/material.dart';
import 'package:medical_follow_up_app/core/theme/app_icons.dart';
import 'package:medical_follow_up_app/core/utils/colors.dart';

class UpcomingChecksSection extends StatelessWidget {
  const UpcomingChecksSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Could be injected from ViewModel later
    final items = [
      {
        'title': 'Blood pressure check',
        'subtitle': 'Tomorrow • 10:00 AM',
        'status': 'Upcoming',
      },
      {
        'title': 'Blood test (cholesterol)',
        'subtitle': 'Mon, 23 Dec • 08:30 AM',
        'status': 'Upcoming',
      },
      {
        'title': 'ECG follow-up',
        'subtitle': 'Completed • Last week',
        'status': 'Completed',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upcoming checks',
              style: theme.textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {
                // TODO: open full list
              },
              child: const Text('See all'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Column(
          children: items.map((item) {
            final status = item['status'] as String;
            final isCompleted = status == 'Completed';

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
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.1),
                    child: Icon(
                      isCompleted ? AppIcons.checkCircle : AppIcons.clock,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    item['title'] as String,
                    style: theme.textTheme.bodyLarge,
                  ),
                  subtitle: Text(
                    item['subtitle'] as String,
                    style: theme.textTheme.bodySmall,
                  ),
                  trailing: _StatusPill(
                    status: status,
                    completed: isCompleted,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// Internal widget for the pill, still reusable
class _StatusPill extends StatelessWidget {
  final String status;
  final bool completed;

  const _StatusPill({
    required this.status,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    if (completed) {
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
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

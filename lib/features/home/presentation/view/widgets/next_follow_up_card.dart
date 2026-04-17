import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_follow_up_app/core/theme/app_icons.dart';
import 'package:medical_follow_up_app/core/utils/colors.dart';
import 'package:medical_follow_up_app/features/appointments/presentation/manager/providers/appointments_provider.dart';

class NextFollowUpCard extends ConsumerWidget {
  const NextFollowUpCard({super.key});

  String _formatTime(DateTime date) {
    final h = date.hour;
    final m = date.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final hr12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$hr12:$m $period';
  }

  String _formatDateLabel(DateTime date) {
    final now = DateTime.now();
    final dateDay = DateTime(date.year, date.month, date.day);
    final nowDay = DateTime(now.year, now.month, now.day);
    final diff = dateDay.difference(nowDay).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${date.day} ${months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final nextAppointmentAsync = ref.watch(nextAppointmentProvider);

    Widget buildFallbackCard({
      required String title,
      required String subtitle,
      Widget? trailing,
    }) {
      return Card(
        color: isDark
            ? HealthCareColors.darkCardBackground
            : HealthCareColors.primaryLighter.withOpacity(0.35),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: isDark
                            ? HealthCareColors.darkTextPrimary
                            : HealthCareColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(subtitle, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 12), trailing],
            ],
          ),
        ),
      );
    }

    final trailingIcon = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? HealthCareColors.darkSurface
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(AppIcons.activity, size: 32, color: HealthCareColors.primary),
    );

    return nextAppointmentAsync.when(
      loading: () => buildFallbackCard(
        title: 'Next follow-up',
        subtitle: 'checking your appointments...',
        trailing: const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (err, _) => buildFallbackCard(
        title: 'Next follow-up',
        subtitle: err.toString().replaceAll('Exception: ', ''),
      ),
      data: (appointment) {
        if (appointment == null) {
          // Provide an alternative UI if there is no data
          return buildFallbackCard(
            title: 'Next follow-up',
            subtitle: 'No upcoming follow-ups scheduled.',
            trailing: trailingIcon,
          );
        }

        final nextAppointment = appointment;
        final timeString = _formatTime(nextAppointment.date);
        final dateLabel = _formatDateLabel(nextAppointment.date);

        return Card(
          color: isDark
              ? HealthCareColors.darkCardBackground
              : HealthCareColors.primaryLighter.withOpacity(0.35),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Left: details text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Next follow-up',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: isDark
                                  ? HealthCareColors.darkTextPrimary
                                  : HealthCareColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(AppIcons.calendar, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                '$dateLabel • $timeString',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(AppIcons.mapPin, size: 16),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  nextAppointment.status.toUpperCase(),
                                  style: theme.textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Action for view details
                            },
                            icon: Icon(AppIcons.arrowRight, size: 16),
                            label: const Text('View details'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              textStyle: const TextStyle(fontSize: 14),
                              elevation: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Right: icon container / illustration
                    trailingIcon,
                  ],
                ),
              ),
              // Notification badge indicating there is a follow up today
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

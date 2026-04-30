import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_follow_up_app/core/theme/app_icons.dart';
import 'package:medical_follow_up_app/core/utils/colors.dart';
import 'package:medical_follow_up_app/features/appointments/presentation/manager/providers/appointments_provider.dart';

/// Card showing the user's next scheduled follow-up (if any).
///
/// Uses [nextAppointmentProvider] and handles:
/// - loading / error / no-appointment fallbacks
/// - friendly date labels ("Today", "Tomorrow", "5 May").
class NextFollowUpCard extends ConsumerWidget {
  const NextFollowUpCard({super.key});

  /// Formats a time as 12‑hour with AM/PM (e.g. "2:30 PM").
  String _formatTime(DateTime date) {
    final h = date.hour;
    final m = date.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final hr12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$hr12:$m $period';
  }

  /// Returns a short label for the date:
  /// - "Today"
  /// - "Tomorrow"
  /// - "5 May" for others.
  String _formatDateLabel(DateTime date) {
    final now = DateTime.now();
    final dateDay = DateTime(date.year, date.month, date.day);
    final nowDay = DateTime(now.year, now.month, now.day);
    final diff = dateDay.difference(nowDay).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';

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
    return '${date.day} ${months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // AsyncValue<Appointment?> giving the next upcoming appointment.
    final nextAppointmentAsync = ref.watch(nextAppointmentProvider);

    /// Small helper to build a consistent “soft card” for:
    /// - loading
    /// - error
    /// - no upcoming appointment.
    Widget buildFallbackCard({
      required String title,
      required String subtitle,
      Widget? trailing,
    }) {
      return Container(
        decoration: BoxDecoration(
          color: isDark
              ? HealthCareColors.darkCardBackground
              : HealthCareColors.primaryLighter.withOpacity(0.2),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: HealthCareColors.primary.withOpacity(0.05)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? HealthCareColors.darkTextPrimary
                            : HealthCareColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 12), trailing],
            ],
          ),
        ),
      );
    }

    // Reusable decorative trailing icon used on success / no-data states.
    final trailingIcon = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? HealthCareColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(AppIcons.activity, size: 32, color: HealthCareColors.primary),
    );

    return nextAppointmentAsync.when(
      // Show a skeleton-style card with a loader.
      loading: () => buildFallbackCard(
        title: 'Next follow-up',
        subtitle: 'Retrieving your medical schedule...',
        trailing: const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      // Show error message from provider.
      error: (err, _) => buildFallbackCard(
        title: 'Next follow-up',
        subtitle: err.toString().replaceAll('Exception: ', ''),
      ),
      data: (appointment) {
        // No upcoming appointments.
        if (appointment == null) {
          return buildFallbackCard(
            title: 'Next follow-up',
            subtitle: 'No upcoming follow-ups scheduled.',
            trailing: trailingIcon,
          );
        }

        // There is an upcoming appointment.
        final nextAppointment = appointment;
        final timeString = _formatTime(nextAppointment.date);
        final dateLabel = _formatDateLabel(nextAppointment.date);

        return Container(
          decoration: BoxDecoration(
            color: isDark
                ? HealthCareColors.darkCardBackground
                : HealthCareColors.primaryLighter.withOpacity(0.2),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: HealthCareColors.primary.withOpacity(0.05),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Main text content.
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Next follow-up',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                              color: isDark
                                  ? HealthCareColors.darkTextPrimary
                                  : HealthCareColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Date/time pill.
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: HealthCareColors.primary.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  AppIcons.calendar,
                                  size: 14,
                                  color: HealthCareColors.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$dateLabel • $timeString',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: HealthCareColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // CTA button to go to appointment details (hook to be implemented).
                          ElevatedButton(
                            onPressed: () {
                              // TODO: navigate to appointment details screen.
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: const Text('View details'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    trailingIcon,
                  ],
                ),
              ),
              // Small red dot indicator (e.g. "new" or "unseen").
              const Positioned(
                top: 12,
                right: 12,
                child: SizedBox(
                  width: 8,
                  height: 8,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
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

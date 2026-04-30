import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_follow_up_app/core/theme/app_icons.dart';
import 'package:medical_follow_up_app/core/utils/colors.dart';
import 'package:medical_follow_up_app/core/utils/responsive.dart';
import 'package:medical_follow_up_app/features/notifications/presentation/manager/notifications_provider.dart';
import 'package:medical_follow_up_app/features/notifications/presentation/view/widgets/notification_bubble.dart';

/// Home header shown at the top of the dashboard.
///
/// Responsibilities:
/// - Show greeting + user name/role
/// - Optional care team button (mobile)
/// - Notification bell with unread badge and overlay bubble.
class HomeHeader extends ConsumerWidget {
  final VoidCallback? onCareTeamPressed;
  final String userName;
  final String userRole;

  const HomeHeader({
    super.key,
    this.onCareTeamPressed,
    required this.userName,
    required this.userRole,
  });

  /// Returns a time‑of‑day greeting based on the current hour.
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  /// Shows the notifications bubble as a full‑screen [OverlayEntry].
  ///
  /// Tapping outside the bubble dismisses the overlay.
  void _showNotificationOverlay(BuildContext context) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => entry.remove(),
        child: Stack(
          children: [
            // Transparent full-screen area to capture taps outside.
            Positioned.fill(child: Container(color: Colors.transparent)),
            // Bubble aligned to the top-right of the screen.
            Positioned(
              top: 0,
              right: 0,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width,
                  maxHeight: MediaQuery.of(context).size.height,
                ),
                child: const NotificationBubble(),
              ),
            ),
          ],
        ),
      ),
    );

    overlay.insert(entry);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDeskTop = Responsive.isDesktop(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // LEFT: avatar + greeting + name/role.
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: HealthCareColors.primary.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: HealthCareColors.primary.withOpacity(0.1),
                  child: Icon(
                    userRole.toUpperCase() == 'DOCTOR'
                        ? Icons.medical_services
                        : Icons.person,
                    color: HealthCareColors.primary,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    userRole.toUpperCase() == 'DOCTOR'
                        ? 'Dr. $userName'
                        : userName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // RIGHT: care team (mobile only) + notifications.
          Row(
            children: [
              if (!isDeskTop)
                IconButton(
                  onPressed: onCareTeamPressed,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.1),
                      ),
                    ),
                    child: Icon(
                      AppIcons.heart,
                      size: 20,
                      color: HealthCareColors.primary,
                    ),
                  ),
                  tooltip: 'Your care team',
                ),
              // Notification bell + unread badge.
              Stack(
                children: [
                  IconButton(
                    onPressed: () => _showNotificationOverlay(context),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.outline.withOpacity(0.1),
                        ),
                      ),
                      child: Icon(
                        AppIcons.notifications,
                        size: 20,
                        color: theme.hintColor,
                      ),
                    ),
                  ),
                  // Badge based on unreadNotificationsCountProvider.
                  Consumer(
                    builder: (context, ref, child) {
                      final unreadCount = ref.watch(
                        unreadNotificationsCountProvider,
                      );
                      if (unreadCount == 0) {
                        return const SizedBox.shrink();
                      }

                      return Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            unreadCount > 9 ? '9+' : unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

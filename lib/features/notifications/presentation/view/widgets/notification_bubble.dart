import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_follow_up_app/core/utils/colors.dart';
import 'package:medical_follow_up_app/features/notifications/presentation/manager/notifications_provider.dart';
import 'package:medical_follow_up_app/features/notifications/data/models/notification_model.dart';

class NotificationBubble extends ConsumerStatefulWidget {
  const NotificationBubble({super.key});

  @override
  ConsumerState<NotificationBubble> createState() => _NotificationBubbleState();
}

class _NotificationBubbleState extends ConsumerState<NotificationBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Material(
          color: Colors.transparent,
          child: Align(
            alignment: Alignment.topRight,
            child: Container(
              width: 350,
              margin: const EdgeInsets.only(top: 70, right: 20),
              decoration: BoxDecoration(
                color: isDark
                    ? HealthCareColors.darkSurface.withOpacity(0.85)
                    : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: (isDark ? Colors.white : HealthCareColors.primary)
                      .withOpacity(0.1),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(context, ref, notifications),
                      const Divider(height: 1),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 400),
                        child: notifications.isEmpty
                            ? _buildEmptyState(context)
                            : ListView.separated(
                                shrinkWrap: true,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                itemCount: notifications.length,
                                separatorBuilder: (context, index) =>
                                    const Divider(
                                      indent: 72,
                                      endIndent: 16,
                                      height: 1,
                                    ),
                                itemBuilder: (context, index) {
                                  return _NotificationItem(
                                    notification: notifications[index],
                                  );
                                },
                              ),
                      ),
                      if (notifications.isNotEmpty) ...[
                        const Divider(height: 1),
                        _buildFooter(context, ref),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    List<AppNotification> notifications,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                'Notifications',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              if (notifications.any((n) => !n.isRead))
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: HealthCareColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    notifications.where((n) => !n.isRead).length.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          TextButton(
            onPressed: () =>
                ref.read(notificationsProvider.notifier).markAllAsRead(),
            child: const Text('Mark all as read'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 48,
            color: theme.hintColor.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'All caught up!',
            style: theme.textTheme.titleSmall?.copyWith(color: theme.hintColor),
          ),
          const SizedBox(height: 4),
          Text(
            'No new notifications for you.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.hintColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        // Navigate to full notifications screen if exists
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        child: Text(
          'See All Notifications',
          style: TextStyle(
            color: HealthCareColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _NotificationItem extends ConsumerWidget {
  final AppNotification notification;

  const _NotificationItem({required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        ref.read(notificationsProvider.notifier).markAsRead(notification.id);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        color: notification.isRead
            ? null
            : HealthCareColors.primary.withOpacity(0.03),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIcon(),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: notification.isRead
                                ? FontWeight.w600
                                : FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        _formatTimestamp(notification.timestamp),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor.withOpacity(0.9),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    IconData iconData;
    Color color;

    switch (notification.type) {
      case NotificationType.appointment:
        iconData = Icons.calendar_today_rounded;
        color = Colors.blue;
        break;
      case NotificationType.message:
        iconData = Icons.chat_bubble_outline_rounded;
        color = Colors.green;
        break;
      case NotificationType.reminder:
        iconData = Icons.access_alarm_rounded;
        color = Colors.orange;
        break;
      case NotificationType.system:
        iconData = Icons.info_outline_rounded;
        color = HealthCareColors.primary;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, size: 20, color: color),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dt.day}/${dt.month}';
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:medical_follow_up_app/features/notifications/data/models/notification_model.dart';

/// Global provider that exposes the current list of in-app notifications.
///
/// - State type: `List<AppNotification>`
/// - Notifier: [NotificationsNotifier] (handles markRead / clear / etc.)
final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<AppNotification>>((ref) {
      return NotificationsNotifier();
    });

/// Simple in-memory notifications store.
///
/// In a real app this could be backed by:
/// - an API
/// - local database
/// - push notifications stream, etc.
class NotificationsNotifier extends StateNotifier<List<AppNotification>> {
  NotificationsNotifier() : super([]) {
    // Seed with some mock notifications for demo/testing purposes.
    state = [
      AppNotification(
        id: '1',
        title: 'Upcoming Appointment',
        message:
            'You have an appointment with Dr. Sarah Smith tomorrow at 10:00 AM.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        type: NotificationType.appointment,
        isRead: false,
      ),
      AppNotification(
        id: '2',
        title: 'New Message',
        message:
            'Dr. Johnson sent you a new message regarding your lab results.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        type: NotificationType.message,
        isRead: true,
      ),
      AppNotification(
        id: '3',
        title: 'Medication Reminder',
        message: 'It\'s time to take your evening dose of Aspirin.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        type: NotificationType.reminder,
        isRead: false,
      ),
    ];
  }

  /// Marks a single notification as read by ID.
  void markAsRead(String id) {
    state = [
      for (final n in state)
        if (n.id == id) n.copyWith(isRead: true) else n,
    ];
  }

  /// Marks **all** notifications as read.
  void markAllAsRead() {
    state = [for (final n in state) n.copyWith(isRead: true)];
  }

  /// Clears all notifications from the list.
  void clearAll() {
    state = [];
  }
}

/// Derived provider that exposes only the unread count.
/// Useful for showing a badge on an icon in the app bar, etc.
final unreadNotificationsCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).where((n) => !n.isRead).length;
});

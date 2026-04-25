import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:medical_follow_up_app/features/notifications/data/models/notification_model.dart';

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<AppNotification>>((ref) {
      return NotificationsNotifier();
    });

class NotificationsNotifier extends StateNotifier<List<AppNotification>> {
  NotificationsNotifier() : super([]) {
    // Add some mock data for demonstration
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

  void markAsRead(String id) {
    state = [
      for (final n in state)
        if (n.id == id) n.copyWith(isRead: true) else n,
    ];
  }

  void markAllAsRead() {
    state = [for (final n in state) n.copyWith(isRead: true)];
  }

  void clearAll() {
    state = [];
  }
}

final unreadNotificationsCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).where((n) => !n.isRead).length;
});

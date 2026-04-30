/// Types of notifications supported by the app.
///
/// Used to drive UI (icons/colors) and behavior (e.g. navigation target).
enum NotificationType { appointment, message, reminder, system }

/// Simple model for an in-app notification.
///
/// Can be created locally or deserialized from JSON.
class AppNotification {
  /// Unique identifier (could be backend ID or local UUID).
  final String id;

  /// Short title shown in bold (first line).
  final String title;

  /// Main message body (short description).
  final String message;

  /// When the notification was created/received.
  final DateTime timestamp;

  /// Whether the user has already opened/acknowledged it.
  final bool isRead;

  /// High-level type used to pick icons/colors and actions.
  final NotificationType type;

  /// Optional ID that links this notification to another entity
  /// (e.g. appointmentId, messageId, recordId, etc.).
  final String? relatedId;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.type = NotificationType.system,
    this.relatedId,
  });

  /// Returns a copy with some fields changed.
  ///
  /// Useful for immutable updates in StateNotifier/Provider.
  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    NotificationType? type,
    String? relatedId,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      relatedId: relatedId ?? this.relatedId,
    );
  }

  /// Parses an [AppNotification] from JSON (e.g. backend response).
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool? ?? false,
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.system,
      ),
      relatedId: json['relatedId'] as String?,
    );
  }

  /// Serializes this notification to JSON (for APIs / local storage).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'type': type.name,
      'relatedId': relatedId,
    };
  }
}

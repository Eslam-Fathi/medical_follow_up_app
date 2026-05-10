import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter/foundation.dart';
import 'package:medical_follow_up_app/features/appointments/data/models/appointment_model.dart';
import 'dart:io' show Platform;

/// A singleton service that manages local push notifications for appointment reminders.
///
/// ### Responsibilities
/// 1. **Initialization** — Sets up the [FlutterLocalNotificationsPlugin] with
///    platform-specific settings (Android channel, iOS permissions) and
///    configures the device's local timezone for accurate scheduling.
/// 2. **Scheduling** — For each upcoming appointment, schedules up to 4 reminder
///    notifications at: T-15min, T-10min, T-5min, and T+0min (on-time alert).
///
/// ### Singleton pattern
/// Like [ApiClient], this service uses a Dart singleton to ensure the
/// notifications plugin is initialized exactly once. Multiple initializations
/// would cause duplicate channels and unpredictable behavior.
///
/// ### Web limitations
/// Local notifications are a native OS feature. Web browsers do not support them
/// in the same way. All methods in this class are no-ops (`return` early) when
/// [kIsWeb] is `true`. This prevents any web-specific crashes while keeping
/// the same API surface across platforms.
///
/// ### Architecture
/// This service is called from [HomeFollowUpScreen] via a Riverpod `ref.listen`
/// on [upcomingRemindersProvider]. When the list of upcoming appointments changes,
/// the screen automatically re-schedules all notifications.
class NotificationService {
  /// The single shared instance of this service.
  static final NotificationService _instance = NotificationService._internal();

  /// Returns the singleton instance. Initializing the service is done
  /// separately via [init].
  factory NotificationService() => _instance;

  /// Private constructor prevents external instantiation.
  NotificationService._internal();

  /// The underlying Flutter plugin that communicates with the OS.
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Guards against running [init] more than once.
  bool _initialized = false;

  /// Initializes the notification plugin and requests OS permissions.
  ///
  /// This **must** be called once, before any other method, typically in
  /// [main()] before [runApp()]:
  /// ```dart
  /// await NotificationService().init();
  /// runApp(const ProviderScope(child: MedME()));
  /// ```
  ///
  /// **Steps performed:**
  /// 1. Skip entirely if already initialized or running on Web.
  /// 2. Initialize timezone data so scheduled notifications fire at the
  ///    correct local time regardless of the device's UTC offset.
  /// 3. Configure the plugin for Android (app icon) and iOS/macOS (alert/badge/sound).
  /// 4. On Android specifically:
  ///    - Request the `POST_NOTIFICATIONS` runtime permission (required in Android 13+).
  ///    - Request `SCHEDULE_EXACT_ALARM` permission (required for exact timing).
  ///    - Create the "Appointment Reminders" notification channel with `Importance.max`
  ///      so reminders appear as heads-up notifications with sound.
  Future<void> init() async {
    // Skip on web or if already initialized.
    if (_initialized || kIsWeb) return;

    // ── Timezone Setup ─────────────────────────────────────────────────────
    // The timezone package requires manual initialization of its database.
    tz.initializeTimeZones();
    try {
      // Get the device's local IANA timezone string (e.g. "Africa/Cairo").
      final TimezoneInfo timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
    } catch (e) {
      // If timezone detection fails (emulator quirk, etc.), we fall back to UTC.
      debugPrint('Could not set local timezone: $e');
    }

    // ── Platform-Specific Settings ─────────────────────────────────────────
    const AndroidInitializationSettings initSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true, // Show alert banner.
      requestBadgePermission: true, // Show app badge counter.
      requestSoundPermission: true, // Play notification sound.
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsDarwin,
      macOS: initSettingsDarwin,
    );

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Called when the user taps a notification.
        // Future: Navigate to the relevant appointment screen.
      },
    );

    // ── Android-Specific Channel Setup ─────────────────────────────────────
    if (!kIsWeb && Platform.isAndroid) {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      // Android 13+ requires explicit permission to post notifications.
      await androidImplementation?.requestNotificationsPermission();

      // Exact alarms are required for time-sensitive reminders.
      // Without this permission, the OS may delay notifications.
      await androidImplementation?.requestExactAlarmsPermission();

      // Create the notification channel that all appointment reminders use.
      // The channel must be created before any notification is shown.
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'appointment_channel',         // Channel ID (must be unique per app).
        'Appointment Reminders',       // User-visible channel name.
        description: 'Notifications for upcoming appointments',
        importance: Importance.max,    // Shows as a heads-up notification with sound.
        enableLights: true,            // Flash the device's notification LED.
        enableVibration: true,         // Vibrate on notification.
        showBadge: true,               // Show badge count on the app icon.
      );

      await androidImplementation?.createNotificationChannel(channel);
    }

    _initialized = true;
  }

  /// Schedules appointment reminder notifications for a list of appointments.
  ///
  /// Before scheduling, all previously scheduled notifications are cancelled
  /// to avoid stale reminders for changed or cancelled appointments.
  ///
  /// **Reminder offsets:** For each appointment, up to 4 notifications are
  /// scheduled (if the time is still in the future):
  /// - T-15 min: "Your appointment is starting in 15 minutes!"
  /// - T-10 min: "Your appointment is starting in 10 minutes!"
  /// - T-5 min:  "Your appointment is starting in 5 minutes!"
  /// - T+0 min:  "Your appointment with Dr. X is starting now!"
  ///
  /// **ID generation:** Each notification needs a unique integer ID. We derive
  /// it from `appointment.id.hashCode & 0x7FFFFFFF` (clamp to positive int)
  /// plus the offset value, giving each reminder a distinct ID.
  ///
  /// **Skipping past appointments:** If an appointment is more than 1 minute
  /// in the past, it is skipped entirely. The 1-minute threshold accounts for
  /// appointments that just started — we still want to show the "starting now"
  /// notification.
  ///
  /// Parameters:
  /// - [appointments] The full list of appointments fetched from the server.
  Future<void> scheduleAppointmentReminders(
      List<Appointment> appointments) async {
    // No-op on web or if the plugin was never initialized.
    if (!_initialized || kIsWeb) return;

    // Cancel all existing alarms before re-scheduling.
    // This prevents duplicate notifications if the appointment list changes.
    await _notificationsPlugin.cancelAll();

    final now = DateTime.now();

    for (int i = 0; i < appointments.length; i++) {
      final app = appointments[i];
      final timeToApp = app.date.difference(now);

      // Skip appointments that are more than 1 minute in the past.
      if (timeToApp.isNegative && timeToApp.inMinutes.abs() > 1) continue;

      // The four reminder offsets in minutes (15, 10, 5, 0).
      final alertOffsets = [15, 10, 5, 0];

      for (final offset in alertOffsets) {
        // Calculate when this specific reminder should fire.
        final scheduleTime = app.date.subtract(Duration(minutes: offset));

        if (scheduleTime.isAfter(now)) {
          // Unique notification ID derived from the appointment ID + offset.
          final id = (app.id.hashCode & 0x7FFFFFFF) + offset;

          const title = 'Checkup Reminder';
          final body = offset == 0
              ? 'Your appointment with ${app.doctor.user.name} is starting now!'
              : 'Your appointment is starting in $offset minutes!';

          // Schedule the notification using the timezone-aware TZDateTime.
          await _notificationsPlugin.zonedSchedule(
            id: id,
            title: title,
            body: body,
            // Convert local DateTime to a timezone-aware TZDateTime.
            scheduledDate: tz.TZDateTime.from(scheduleTime, tz.local),
            notificationDetails: const NotificationDetails(
              android: AndroidNotificationDetails(
                'appointment_channel', // Must match the channel ID created in init().
                'Appointment Reminders',
                channelDescription: 'Notifications for upcoming appointments',
                importance: Importance.max,
                priority: Priority.high,
              ),
              iOS: DarwinNotificationDetails(),
            ),
            // exactAllowWhileIdle ensures the notification fires even when
            // the device is in Doze mode / battery-saving state.
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          );
        }
      }
    }
  }
}

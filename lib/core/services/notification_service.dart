import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter/foundation.dart';
import 'package:medical_follow_up_app/features/appointments/data/models/appointment_model.dart';
import 'dart:io' show Platform;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized || kIsWeb) return;

    tz.initializeTimeZones();
    try {
      final TimezoneInfo timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
    } catch (e) {
      debugPrint('Could not set local timezone: $e');
    }

    const AndroidInitializationSettings initSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initSettingsDarwin = 
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsDarwin,
      macOS: initSettingsDarwin,
    );

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification click if needed
      },
    );

    if (!kIsWeb && Platform.isAndroid) {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      await androidImplementation?.requestNotificationsPermission();
      await androidImplementation?.requestExactAlarmsPermission();

      // Explicitly create the channel to ensure high priority/sound
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'appointment_channel',
        'Appointment Reminders',
        description: 'Notifications for upcoming appointments',
        importance: Importance.max,
        enableLights: true,
        enableVibration: true,
        showBadge: true,
      );
      
      await androidImplementation?.createNotificationChannel(channel);
    }

    _initialized = true;
  }

  Future<void> scheduleAppointmentReminders(List<Appointment> appointments) async {
    if (!_initialized || kIsWeb) return;
    
    // Clear old alarms
    await _notificationsPlugin.cancelAll();

    final now = DateTime.now();

    for (int i = 0; i < appointments.length; i++) {
        final app = appointments[i];
        final timeToApp = app.date.difference(now);

        // If it's strictly in the past, skip
        if (timeToApp.isNegative && timeToApp.inMinutes.abs() > 1) continue;

        final alertOffsets = [15, 10, 5, 0];
        
        for (final offset in alertOffsets) {
          final scheduleTime = app.date.subtract(Duration(minutes: offset));
          
          if (scheduleTime.isAfter(now)) {
            final id = (app.id.hashCode & 0x7FFFFFFF) + offset;
            
            final title = 'Checkup Reminder';
            final body = offset == 0 
                ? 'Your appointment with ${app.doctor.user.name} is starting now!'
                : 'Your appointment is starting in $offset minutes!';

            await _notificationsPlugin.zonedSchedule(
              id: id,
              title: title,
              body: body,
              scheduledDate: tz.TZDateTime.from(scheduleTime, tz.local),
              notificationDetails: const NotificationDetails(
                android: AndroidNotificationDetails(
                  'appointment_channel',
                  'Appointment Reminders',
                  channelDescription: 'Notifications for upcoming appointments',
                  importance: Importance.max,
                  priority: Priority.high,
                ),
                iOS: DarwinNotificationDetails(),
              ),
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            );
          }
        }
    }
  }
}

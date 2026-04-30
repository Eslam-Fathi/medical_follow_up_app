import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_follow_up_app/features/appointments/presentation/manager/providers/appointments_provider.dart';

class GlobalNotificationWrapper extends ConsumerStatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;
  
  const GlobalNotificationWrapper({
    super.key, 
    required this.child,
    required this.navigatorKey,
  });

  @override
  ConsumerState<GlobalNotificationWrapper> createState() => _GlobalNotificationWrapperState();
}

class _GlobalNotificationWrapperState extends ConsumerState<GlobalNotificationWrapper> {
  Timer? _timer;
  final Set<String> _shownAlerts = {};

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
       _refreshAndCheck();
    });
  }

  Future<void> _refreshAndCheck() async {
    // Refresh to get new appointments/reminders
    await ref.refresh(upcomingRemindersProvider.future);
    _checkAppointments();
  }

  void _checkAppointments() {
    final asyncAppointments = ref.read(upcomingRemindersProvider);
    
    asyncAppointments.whenData((appointments) {
       final now = DateTime.now();
       
       for (final app in appointments) {
          // positive means in the future
          final diffSeconds = app.date.difference(now).inSeconds;
          final diffMinutes = diffSeconds / 60.0;
          
          // Thresholds for alerts
          final thresholds = [15.0, 10.0, 5.0, 0.0];
          
          for (final threshold in thresholds) {
             // If we are within 1 minute of the threshold (but not passed it significantly)
             // We show the alert if we haven't already.
             if (diffMinutes <= threshold && diffMinutes > threshold - 1.1) {
                final alertKey = '${app.id}_$threshold';
                
                if (!_shownAlerts.contains(alertKey)) {
                   _shownAlerts.add(alertKey);
                   _showInAppAlert(app.doctor.user.name, threshold.toInt());
                   break; 
                }
             }
          }
       }
    });
  }

  void _showInAppAlert(String doctorName, int minutes) {
     final context = widget.navigatorKey.currentState?.overlay?.context;
     if (context == null) return;

     final msg = minutes == 0 
         ? 'Your appointment with $doctorName is starting now!'
         : 'Your appointment is starting in $minutes minutes!';
         
     showDialog(
       context: context,
       builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
               Icon(Icons.notifications_active, color: Colors.blue),
               SizedBox(width: 8),
               Text('Checkup Reminder'),
            ]
          ),
          content: Text(msg),
          actions: [
            TextButton(
               onPressed: () => Navigator.of(ctx).pop(),
               child: const Text('Got it!'),
            ),
          ]
       )
     );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

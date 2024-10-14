import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ReminderPage extends StatefulWidget {
  @override
  _ReminderPageState createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  void _initializeNotifications() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Initialize settings for Android and iOS
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    // Initialize the plugin
    flutterLocalNotificationsPlugin.initialize(initSettings);
    tz.initializeTimeZones();
  }

  Future<void> _scheduleNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Vet Visit Reminder',
      'It\'s time to take your pet for a checkup!',
      tz.TZDateTime.now(tz.local)
          .add(Duration(seconds: 5)), // Example: 5 seconds from now
      const NotificationDetails(
        android: AndroidNotificationDetails(
            'your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker'),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Reminder'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _scheduleNotification,
          child: Text('Schedule a Vet Visit Reminder'),
        ),
      ),
    );
  }
}

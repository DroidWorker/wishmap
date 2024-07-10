import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import '../data/models.dart';
import '../repository/dbHelper.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

const checkRemindersTask = "checkRemindersTask";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case checkRemindersTask:
        try{await _checkReminders();}//_checkReminders();
        catch(ex){
          print("eeeeeeeeeeeeexxxxxxxx $ex");
        }
        break;
    }
    return Future.value(true);
  });
}

Future<void> _checkReminders() async {
  try {
    tz.initializeTimeZones();
    print("checking reminders");
  }catch(ex){
    _showNotification(null);
  }

  final dbHelper = DatabaseHelper();
  List<Reminder> reminders = [];
  try {
    reminders = await dbHelper.getReminders();
  } catch (ex, s) {
    print("errrrrrrrrrror worker - $ex");
    print(s);
  }
  /*final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initializationSettingsDarwin = DarwinInitializationSettings();
  const initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);*/

  DateTime now = DateTime.now();
  String currentDay = now.weekday.toString();

  for (Reminder reminder in reminders) {
    print("comparation - ${reminder.dateTime.weekday} ${now.weekday}");
    if (reminder.remindDays.contains(currentDay) || reminder.dateTime.weekday == now.weekday) {
      int nowMinutes = now.hour * 60 + now.minute;
      int reminderMinutes = reminder.dateTime.hour * 60 + reminder.dateTime.minute;
      int differenceMinutes = reminderMinutes - nowMinutes;

      if (differenceMinutes <= 15) {
        final interval = differenceMinutes<=0?1:differenceMinutes;
        // Schedule the notification
        sleep(Duration(minutes: interval));
        _showNotification(reminder);
        dbHelper.deleteReminder(reminder.id);
      }
    }
  }
}

Future<void> _showNotification(Reminder? reminder) async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
    'your_channel_id',
    'Channel Name',
    channelDescription: 'Channel Description',
    importance: Importance.max,
    priority: Priority.high,
    enableVibration: reminder?.vibration??false,
    showWhen: false,
  );

  NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);

  // Deep link URL
  String deepLink = 'WishMap://task?id=123'; // Replace with your deep link URL

  await flutterLocalNotificationsPlugin.show(
    0,
    'Время выполнить задачу!',
    reminder!=null?'Нажмите, чтообы перейти':'error',
    platformChannelSpecifics,
    payload: deepLink,
  );
}

Future<void> _scheduleNotification(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin, Reminder reminder, int delayMinutes) async {
  try {
    print("Starting to schedule notification");

    // Initialize timezone
    final timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '87585',
      'wishmap reminder',
      channelDescription: 'channel description',
      importance: Importance.max,
      icon: "@mipmap/ic_launcher", //<-- Add this parameter
    );

    final darwinPlatformChannelSpecifics = DarwinNotificationDetails();
    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: darwinPlatformChannelSpecifics,
    );

    final scheduledDate = tz.TZDateTime.now(tz.local).add(Duration(minutes: delayMinutes));
    print("Scheduling notification for ${scheduledDate.day}-${scheduledDate.month}-${scheduledDate.year} ${scheduledDate.hour}:${scheduledDate.minute}");

    // Schedule the notification
    await flutterLocalNotificationsPlugin.zonedSchedule(
      887,
      'Напоминание',
      'Время выполнить Вашу задачу!',
      scheduledDate,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );

    print("Notification scheduled successfully");
  } catch (ex, s) {
    print("Error scheduling notification: $ex");
    print(s);
  }
}
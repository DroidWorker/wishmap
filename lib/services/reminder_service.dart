import 'dart:io';
import 'dart:typed_data';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
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
        /*sleep(Duration(minutes: interval));
        _showNotification(reminder);
        dbHelper.deleteReminder(reminder.id);*/
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

void setReminder(Reminder reminder) async {
  if (reminder.remindDays.isNotEmpty) {
    int reminderId = reminder.TaskId*100;

    reminder.remindDays.indexed.forEach((v) async {
      final DateTime now = DateTime.now();
      final int dayOffset = getDayOffset(int.parse(v.$2), now.weekday);
      DateTime firstAlarmTime = now.add(Duration(days: dayOffset));
      firstAlarmTime = firstAlarmTime.copyWith(hour: reminder.dateTime.hour, minute: reminder.dateTime.minute);

      await AndroidAlarmManager.periodic(
        const Duration(days: 7),
        reminderId+v.$1,
        showRemindNotification,
        startAt: firstAlarmTime,
        exact: true,
        wakeup: true,
      );

      print('Repeating reminder ${reminderId+v.$1} set for ${v.$2} starting at $firstAlarmTime');
    });
  } else {
    final result = await AndroidAlarmManager.oneShotAt(
      reminder.dateTime,
      reminder.TaskId*100,
      showRemindNotification,
      alarmClock: true,
      exact: true,
      wakeup: true,
    );
    print('Single reminder set for ${reminder.dateTime} with id ${reminder.id} - $result');
  }
}

Future<bool> cancelAlarmManager(int id) async{
  print("canceled reminder $id");
  return await AndroidAlarmManager.cancel(id);
}

Future<List<int>> setAlarm(Alarm alarm, bool repeating) async {
  List<int> alarmIds = [];

  if (repeating) {
    int alarmId = alarm.id*100;
    alarm.remindDays.forEach((day) async {
      alarmId++;
      final DateTime now = DateTime.now();
      final int dayOffset = getDayOffset(int.parse(day), now.weekday);
      final DateTime firstAlarmTime = now.add(Duration(days: dayOffset));

      await AndroidAlarmManager.periodic(
        const Duration(days: 7),
        alarmId,
        showFSNotification,
        startAt: firstAlarmTime,
        exact: true,
        wakeup: true,
      );
      alarmIds.add(alarmId);

      print('Repeating alarm set for $day starting at $firstAlarmTime');
    });
  } else {
    final result = await AndroidAlarmManager.oneShotAt(
      alarm.dateTime,
      alarm.id*100,
      showFSNotification,
      alarmClock: true,
      exact: true,
      wakeup: true,
    );
    alarmIds.add(alarm.id+654);
    print('Single alarm set for ${alarm.dateTime} with id ${alarm.id} - $result');
  }
  return alarmIds;
}

int getDayOffset(int selectedDay, int currentWeekday) {
  if (selectedDay >= currentWeekday) {
    return selectedDay - currentWeekday;
  } else {
    return 7 - (currentWeekday - selectedDay);
  }
}

int getDayOffsetToClosest(List<int> days, int currentWeekday) {
  var selectedDay = 0;
  var diff = 20;
  for (var e in days) {
    final d = (e-currentWeekday);
    if(d<diff&&d>=0){
      diff=d;
      selectedDay = e;
    }
  }
  if(diff==20){
    selectedDay=days.first;
  }

  if (selectedDay >= currentWeekday) {
    return selectedDay - currentWeekday;
  } else {
    return 7 - (currentWeekday - selectedDay);
  }
}

@pragma('vm:entry-point')
void showFSNotification(int id) async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  const int insistentFlag = 4;
  const int ongoingFlag = 2;
  const int noClearFlag = 32;
  final Int32List flags = Int32List.fromList(<int>[insistentFlag, ongoingFlag, noClearFlag]);

  AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    '875855nnn',
    'WishMapAlarm',
    channelDescription: 'some channel description',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
    fullScreenIntent: true,
    ongoing: true,
    additionalFlags: flags,
    playSound: true,
    sound: const RawResourceAndroidNotificationSound('notification'),
    category: AndroidNotificationCategory.alarm,
    visibility: NotificationVisibility.public,
    enableVibration: true,
    autoCancel: true,
    timeoutAfter: 180000, // Уведомление исчезнет через минуту
  );

  NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    id,
    'Alarm',
    'Нажмите чтобы отключить!',
    platformChannelSpecifics,
    payload: 'alarm|$id',
  );
}

@pragma('vm:entry-point')
void showRemindNotification(int notificationId) async {
  final taskId = notificationId~/100;
  final deepLink = 'WishMap://task?id=$taskId';


  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  AndroidNotificationDetails androidPlatformChannelSpecifics =
  const AndroidNotificationDetails(
    '97585',
    'wishmapReminder',
    channelDescription: 'your channel description',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
    playSound: true
  );

  NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    notificationId,
    'Напоминание',
    'Нажмите чтобы посмотреть!',
    platformChannelSpecifics,
    payload: deepLink,
  );
}
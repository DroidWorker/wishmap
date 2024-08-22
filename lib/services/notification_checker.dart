import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

Future<bool> checkNotificationPermission() async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final isGranted = await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.areNotificationsEnabled();
  return isGranted ?? false;
}

void openNotificationSettings() {
  const intent = AndroidIntent(
    action: 'android.settings.APP_NOTIFICATION_SETTINGS',
    flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    arguments: <String, dynamic>{
      'android.provider.extra.APP_PACKAGE': 'com.kwork.wish.map.wishmap', // Замените на пакет вашего приложения
    },
  );
  intent.launch();
}

void showNotificationPermissionDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Требуется разрешение'),
        content: Text('Для корректной работы будильника нужно разрешить показ полноэкранных уведомлений. Хотите перейти в настройки?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openNotificationSettings();
            },
            child: Text('Перейти'),
          ),
        ],
      );
    },
  );
}

import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService() {
    initializeNotifications();
  }

  void initializeNotifications() async {
    tz.initializeTimeZones(); // Инициализация временных зон

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> requestExactAlarmPermission() async {
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        if (await Permission.scheduleExactAlarm.isDenied) {
          await Permission.scheduleExactAlarm.request();
        }
      }
    }
  }

  void scheduleNotification(DateTime deadline, String taskTitle) async {
    await requestExactAlarmPermission();  // Запрашиваем разрешение перед созданием уведомлений

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Срок задачи!',
      'Задача "$taskTitle" скоро истекает!',
      tz.TZDateTime.from(deadline, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'your_channel_id',
          'your_channel_name',
          channelDescription: 'Описание канала для уведомлений о сроках задач',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exact,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }
}

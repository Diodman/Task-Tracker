import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter/foundation.dart'; // Для debugPrint

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  NotificationService() {
    _initializeNotifications();
  }

  void _initializeNotifications() {
    tz_data.initializeTimeZones(); // Инициализация часовых поясов

    const AndroidInitializationSettings androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidInitSettings);

    _notificationsPlugin.initialize(initSettings);
  }

  Future<void> scheduleNotification(DateTime notificationTime, String taskTitle) async {
    final tz.TZDateTime scheduledTime = tz.TZDateTime.from(notificationTime, tz.local);

    try {
      await _notificationsPlugin.zonedSchedule(
        0, // ID уведомления
        'Напоминание о задаче',
        'Задача "$taskTitle" запланирована на ${DateFormat('yyyy-MM-dd HH:mm').format(notificationTime)}!',
        scheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_channel', 
            'Task Notifications', 
            channelDescription: 'Уведомления о задачах',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint('Уведомление запланировано на ${scheduledTime.toString()}');
    } catch (e) {
      debugPrint('Ошибка при создании уведомления: $e');
    }
  }
}

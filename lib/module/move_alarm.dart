import 'package:alarm_clock/main.dart';
import 'package:alarm_clock/module/alarm.dart';
import 'package:alarm_clock/screen/alarmstop.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

viewNotification(Alarm alarm) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
          'your channel id', 'your channel name', 'your channel description',
          importance: Importance.max, priority: Priority.high, showWhen: false);
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
      0, 'plain title', 'plain body', platformChannelSpecifics,
      payload: 'item x');
}

setAlarmWeeklySchedule(Alarm alarm) async {
  await flutterLocalNotificationsPlugin.zonedSchedule(
      alarm.id,
      'Weekly Alarm ${alarm.id}',
      '${alarm.description}',
      _nextInstanceWeek(alarm),
      const NotificationDetails(
          android: AndroidNotificationDetails(
              'your channel id', 'your channel name', 'alarmDescription')),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime);
}

//現在が、目的の時間より前か
tz.TZDateTime _nextInstanceTime(Alarm alarm) {
  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month,
      now.day, alarm.time.hour, alarm.time.minute);
  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }
  return scheduledDate;
}

//現在が、目的の曜日であるか
tz.TZDateTime _nextInstanceWeek(Alarm alarm) {
  tz.TZDateTime scheduledDate = _nextInstanceTime(alarm);
  int nowWeekDay = scheduledDate.weekday;
  int i = 0;
  while (alarm.repeat[i] < nowWeekDay) {
    i++;
  }
  while (scheduledDate.weekday != alarm.repeat[i]) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }
  return scheduledDate;
}

Future onDidReceiveLocalNotification(
    int id, String title, String body, String payload) async {
  // display a dialog with the notification details, tap ok to go to another page
  BuildContext context;
  showDialog(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          child: Text('Ok'),
          onPressed: () async {
            Navigator.of(context, rootNavigator: true).pop();
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AlarmStop(),
              ),
            );
          },
        )
      ],
    ),
  );
}

Future selectNotification(String payload) async {
  BuildContext context;
  if (payload != null) {
    debugPrint('notification payload: $payload');
  }
  await Navigator.push(
    context,
    MaterialPageRoute<void>(builder: (context) => AlarmStop()),
  );
}

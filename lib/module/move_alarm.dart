import 'dart:typed_data';
import 'dart:io';
import 'package:alarm_clock/main.dart';
import 'package:alarm_clock/module/alarm.dart';
import 'package:alarm_clock/module/alarm_list.dart';
import 'package:alarm_clock/screen/alarmstop.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

setVibrationPattern() {
  Int64List vibrationPattern = Int64List(2);
  vibrationPattern[0] = 800;
  vibrationPattern[1] = 800;
  return vibrationPattern;
}

setAlarmFirstSchedule(Alarm alarm) async {
  tz.TZDateTime scheduledDate = _nextInstanceTime(alarm);
  await flutterLocalNotificationsPlugin.zonedSchedule(
      alarm.id,
      '${alarm.description}',
      '${alarm.time.hour} : ${alarm.time.minute}',
      scheduledDate,
      NotificationDetails(
          android: AndroidNotificationDetails(
        'Alarm',
        'Alarm',
        'Alarm',
        vibrationPattern: setVibrationPattern(),
        ledColor: Colors.amber,
        ledOnMs: 1000,
        ledOffMs: 500,
        priority: Priority.max,
        importance: Importance.max,
        enableVibration: alarm.vibration,
        channelShowBadge: true,
        visibility: NotificationVisibility.public,
        onlyAlertOnce: true,
        category: 'alarm',
        fullScreenIntent: true,
        playSound: true,
      )),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: alarm.alarmId.toString());
}

setAlarmWeeklySchedule(Alarm alarm) async {
  await flutterLocalNotificationsPlugin.zonedSchedule(
      alarm.id,
      'Weekly Alarm ${alarm.alarmId.toString()}',
      '${alarm.description}',
      _nextInstanceWeek(alarm),
      NotificationDetails(
          android: AndroidNotificationDetails(
        'Alarm',
        'Alarm',
        'alarm',
        enableLights: true,
        ledColor: Colors.amber,
        ledOnMs: 1000,
        ledOffMs: 500,
        priority: Priority.max,
        importance: Importance.max,
        enableVibration: alarm.vibration,
        vibrationPattern: setVibrationPattern(),
        channelShowBadge: true,
        visibility: NotificationVisibility.public,
        onlyAlertOnce: true,
        category: 'alarm',
        fullScreenIntent: true,
        playSound: true,
      )),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: alarm.alarmId.toString());
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
  int i;
  for (i = 0; i < alarm.repeat[i]; i++) {
    if (alarm.repeat[i] == 0) {
      int check = 7;
      if (check == nowWeekDay) {
        break;
      }
    } else {
      if (alarm.repeat[i] >= nowWeekDay) {
        break;
      }
    }
  }
  while (scheduledDate.weekday != alarm.repeat[i]) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }
  return scheduledDate;
}

canselAlarm(int id) async {
  await flutterLocalNotificationsPlugin.cancel(id);
}

canselAllAlarm() async {
  await flutterLocalNotificationsPlugin.cancelAll();
}

Future onDidReceiveLocalNotification(
    int id, String title, String body, String payload) async {
  // display a dialog with the notification details, tap ok to go to another page
  BuildContext context;
  relodeAlarmList();
  int i = 0;
  while (alarmList[i].alarmId != int.parse(payload)) {
    i++;
  }
  showDialog(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          child: Text('アラームの時間になりました'),
          onPressed: () async {
            Navigator.of(context, rootNavigator: true).pop();
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AlarmStop(alarmList[i]),
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
  relodeAlarmList();
  int i = 0;
  while (alarmList[i].alarmId != int.parse(payload)) {
    i++;
  }
  await Navigator.push(
    context,
    MaterialPageRoute<void>(builder: (context) => AlarmStop(alarmList[i])),
  );
}

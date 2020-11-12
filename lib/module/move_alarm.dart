import 'package:alarm_clock/main.dart';
import 'package:alarm_clock/module/alarm.dart';
import 'package:alarm_clock/module/alarm_list.dart';
import 'package:alarm_clock/module/shared_prefs.dart';
import 'package:alarm_clock/screen/alarmstop.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:vibration/vibration.dart';
import 'package:workmanager/workmanager.dart';

int alarmedId;
FlutterRingtonePlayer ringtonePlayer = FlutterRingtonePlayer();
Vibration vibration = Vibration();

setBackgroundTimer(tz.TZDateTime time) {
  DateTime now = DateTime.now();
  Duration setTime = time.difference(now);
  print('timeset after ${setTime.toString()}');
  return setTime;
}

setAlarmFirstSchedule(Alarm alarm) async {
  Workmanager.registerOneOffTask(alarm.alarmId.toString(), 'alarm',
      tag: 'alarm',
      initialDelay: setBackgroundTimer(_nextInstanceTime(alarm)),
      inputData: {'int': alarm.alarmId, 'vibration': alarm.vibration});

  tz.TZDateTime scheduledDate = _nextInstanceTime(alarm);
  await flutterLocalNotificationsPlugin.zonedSchedule(
      alarm.id,
      '${alarm.description}',
      '${alarm.time.hour.toString().padLeft(2, '0')}:${alarm.time.minute.toString().padLeft(2, '0')}',
      scheduledDate,
      NotificationDetails(
          android: AndroidNotificationDetails(
        'Alarm',
        'Alarm',
        '卒研猫の会のアラーム',
        ledColor: Colors.amber,
        ledOnMs: 1000,
        ledOffMs: 500,
        priority: Priority.max,
        importance: Importance.max,
        channelShowBadge: true,
        visibility: NotificationVisibility.public,
        category: 'alarm',
      )),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: alarm.alarmId.toString());
}

setAlarmWeeklySchedule(Alarm alarm) async* {
  Workmanager.registerOneOffTask(alarm.alarmId.toString(), 'alarm',
      tag: 'alarm',
      initialDelay: setBackgroundTimer(_nextInstanceWeek(alarm)),
      inputData: {'int': alarm.alarmId, 'vibration': alarm.vibration});
  await flutterLocalNotificationsPlugin.zonedSchedule(
    alarm.id,
    '${alarm.description}',
    '${alarm.time.hour.toString().padLeft(2, '0')}:${alarm.time.minute.toString().padLeft(2, '0')}',
    _nextInstanceWeek(alarm),
    NotificationDetails(
        android: AndroidNotificationDetails(
      'Alarm',
      'Alarm',
      '卒研猫の会のアラーム',
      enableLights: true,
      ledColor: Colors.amber,
      ledOnMs: 1000,
      ledOffMs: 500,
      priority: Priority.max,
      importance: Importance.max,
      channelShowBadge: true,
      visibility: NotificationVisibility.public,
      category: 'alarm',
    )),
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    payload: alarm.alarmId.toString(),
  );
}

//SnoozeのIDは元のAlarmIDに+1している
setAlarm10minSnoozeSchedule(Alarm alarm) async* {
  Workmanager.registerOneOffTask(alarm.alarmId.toString(), 'snooze',
      tag: 'snooze',
      initialDelay: setBackgroundTimer(_nextInstanceTime(alarm)),
      inputData: {'int': alarm.alarmId - 1, 'vibration': alarm.vibration});

  tz.TZDateTime scheduledDate = _nextInstanceTime(alarm);
  await flutterLocalNotificationsPlugin.zonedSchedule(
      alarm.id,
      '${alarm.description}',
      '${alarm.time.hour.toString().padLeft(2, '0')}:${alarm.time.minute.toString().padLeft(2, '0')}',
      scheduledDate,
      NotificationDetails(
          android: AndroidNotificationDetails(
        'Alarm',
        'Alarm',
        '卒研猫の会のアラーム',
        ledColor: Colors.amber,
        ledOnMs: 1000,
        ledOffMs: 500,
        priority: Priority.max,
        importance: Importance.max,
        channelShowBadge: true,
        visibility: NotificationVisibility.public,
        category: 'alarm',
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
                builder: (context) => AlarmStop(),
              ),
            );
          },
        )
      ],
    ),
  );
}

setAlarm10minSnooze() async {
  Alarm alarm = await getAlarm();
  if (alarm.stopSnooze == false) {
    DateTime now = DateTime.now();
    DateTime time = DateTime(
        now.year, now.month, now.day, alarm.time.hour, alarm.time.minute);
    List<int> list = [];
    time.add(new Duration(minutes: 10));
    Alarm snoozeAlarm = new Alarm(
        id: alarmList.length,
        alarmId: alarm.alarmId + 1,
        time: TimeOfDay.fromDateTime(time),
        description: alarm.description + 'のスヌーズ',
        repeat: list,
        vibration: alarm.vibration,
        qrCodeMode: alarm.qrCodeMode,
        stopSnooze: false);
    setAlarm10minSnoozeSchedule(snoozeAlarm);
    print('set snooze at ${time.hour} : ${time.minute}');
  }
}

stopAlarm10minSnooze() async* {
  Alarm alarm = await getAlarm();
  Workmanager.cancelByUniqueName((alarm.alarmId + 1).toString());
  canselAlarm(alarm.alarmId + 1);
  if (alarm.repeat.isEmpty) {
    deleteAlarm(alarm);
  } else {
    alarm.stopSnooze = false;
    setAlarmWeeklySchedule(alarm);
    deleteAlarmData();
    saveAlarmData(alarmList);
  }
  print('stop snooze');
}

startRingAlarm({bool vibrate = true}) async {
  Alarm alarm = await getAlarm();
  if (alarm.vibration == false) vibrate = false;
  if (vibrate) {
    Vibration.vibrate(pattern: [500, 500, 500, 500], repeat: 2);
  }
  //volumeを設定項目から取ってくる
  FlutterRingtonePlayer.playAlarm(looping: true, asAlarm: true, volume: 1.0);
}

void stopRingAlarm() {
  FlutterRingtonePlayer.stop();
  Vibration.cancel();
}

import 'package:alarm_clock/main.dart';
import 'package:alarm_clock/module/alarm.dart';
import 'package:alarm_clock/module/alarm_list.dart';
import 'package:alarm_clock/module/shared_prefs.dart';
import 'package:alarm_clock/module/user_setting.dart';
import 'package:alarm_clock/screen/alarmstop.dart';
import 'package:alarm_clock/val/string.dart';
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

//バックグラウンド処理の予約をする
setBackgroundTimer(tz.TZDateTime time) {
  DateTime now = DateTime.now();
  //バックグラウンド処理の開始までラグがあるときがあるので要調整
  //現在時間と登録された時間までを引いた時間を指定する（Durationじゃないといけないのがやっかい）
  Duration setTime = time.difference((now));
  print('バックグラウンド処理は ${setTime.toString()}　後に動作します');
  return setTime;
}

//アラームに曜日のくり返しが無い場合は直近のその時間に鳴らす（当日か翌日に鳴る）
setAlarmOnceSchedule(Alarm alarm) async {
  Workmanager.registerOneOffTask(alarm.alarmId.toString(), 'alarm',
      tag: 'alarm',
      initialDelay: setBackgroundTimer(_nextInstanceTime(alarm)),
      inputData: {
        'int': alarm.alarmId,
        'vibration': alarm.vibration,
        'hour': alarm.time.hour,
        'minute': alarm.time.minute
      });

  tz.TZDateTime scheduledDate = _nextInstanceTime(alarm);
  await flutterLocalNotificationsPlugin.zonedSchedule(
      alarm.alarmId,
      '${alarm.description}',
      'アラームの時間になりました！',
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
      matchDateTimeComponents: DateTimeComponents.time,
      payload: '$scheduledDate');
  setSettingAlarmId(alarm, _nextInstanceTime(alarm));
}

//アラームに曜日のくり返しがある場合に使う
setAlarmWeeklySchedule(Alarm alarm) async {
  print('曜日登録開始');
  tz.TZDateTime scheduledDate = _nextInstanceWeek(alarm);
  Workmanager.registerOneOffTask(alarm.alarmId.toString(), 'alarm',
      tag: 'alarm',
      initialDelay: setBackgroundTimer(_nextInstanceWeek(alarm)),
      inputData: {
        'int': alarm.alarmId,
        'vibration': alarm.vibration,
        'hour': alarm.time.hour,
        'minute': alarm.time.minute
      });
  print('バックグランド登録完了');

  await flutterLocalNotificationsPlugin.zonedSchedule(
      alarm.alarmId,
      '${alarm.description}',
      'アラームの時間になりました！',
      _nextInstanceWeek(alarm),
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
      matchDateTimeComponents: DateTimeComponents.time,
      payload: '$scheduledDate');
  setSettingAlarmId(alarm, _nextInstanceWeek(alarm));
  print('通知登録完了');
}

//SnoozeのIDは元のAlarmIDに+1している
setAlarm10minSnoozeSchedule(Alarm alarm) async {
  tz.TZDateTime scheduledDate = _nextInstanceTime(alarm);
  Workmanager.registerOneOffTask(alarm.alarmId.toString(), 'snooze',
      tag: 'snooze',
      initialDelay: setBackgroundTimer(_nextInstanceTime(alarm)),
      inputData: {
        'int': alarm.alarmId - 1,
        'vibration': alarm.vibration,
        'hour': alarm.time.hour,
        'minute': alarm.time.minute
      });

  await flutterLocalNotificationsPlugin.zonedSchedule(
      alarm.alarmId,
      '${alarm.description}',
      '${alarm.description}のスヌーズ',
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
      matchDateTimeComponents: DateTimeComponents.time,
      payload: '$scheduledDate');
  print('scheduled notification ID : ${alarm.alarmId}');

  setSettingAlarmId(alarm, _nextInstanceTime(alarm));
}

//現在が、目的の時間より前か
tz.TZDateTime _nextInstanceTime(Alarm alarm) {
  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month,
      now.day, alarm.time.hour, alarm.time.minute);

  //もし現在時刻がアラームを鳴らす時間を過ぎていれば1日足して翌日にする
  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }

  return scheduledDate;
}

//現在が、目的の曜日であるか
tz.TZDateTime _nextInstanceWeek(Alarm alarm) {
  tz.TZDateTime scheduledDate = _nextInstanceTime(alarm);
  print('予定時刻:$scheduledDate');
  //当日とアラームの曜日リストが一致しても鳴らす時間が過ぎていれば翌日の曜日になっている
  //nowは意味としては違うけど適当なのが思いつかなかったので保留
  int nowWeekDay = scheduledDate.weekday;
  int i;
  int setWeekday = 10;

  //アラームの曜日リストと直近の鳴らす時間の曜日が一致するか
  for (i = 0; i < alarm.repeat.length; i++) {
    if (nowWeekDay == alarm.repeat[i]) {
      setWeekday = alarm.repeat[i];
      break;
    }
  }

  print('リスト内一致検証の動作後：$i');

  //アラームの曜日リストが一致しないでforが終わった場合の処理

  //リスト内の最後の曜日より鳴らす曜日の方が進んでいたら
  //リスト内の最初の曜日を指定する
  if (i == alarm.repeat.length && nowWeekDay > alarm.repeat[i - 1]) {
    setWeekday = alarm.repeat[0];
  }
  //リスト内の最後の曜日の方が現在より後だった場合
  //リスト内で鳴らす曜日より直ぐ後の曜日を探す
  else if (i == alarm.repeat.length && nowWeekDay < alarm.repeat[i - 1]) {
    for (i = 0; i < alarm.repeat.length; i++) {
      if (nowWeekDay < alarm.repeat[i]) {
        setWeekday = alarm.repeat[i];
        break;
      }
    }
  }

  //指定された曜日まで日を足していく
  while (scheduledDate.weekday != setWeekday) {
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

//ここが動作しているのを見たことがない
Future onDidReceiveLocalNotification(
    int id, String title, String body, String payload) async {
  // display a dialog with the notification details, tap ok to go to another page
  BuildContext context;
  Alarm alarm = await getAlarm();
  alarmedId = appSetting.movingAlarmId;
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

//
setAlarm10minSnooze() async {
  Alarm alarm = await getAlarm();
  print('スヌーズの登録');
  print('元のアラーム【${alarm.alarmId}】${alarm.description}');
  if (alarm.stopSnooze == false) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    List<int> list = [];

    //下の時間をテスト時にコメントアウトで切り替えて下さい
    //テスト用　minutesの後の数字を書き換えればOK
    //DateTime time = now.add(Duration(minutes: 5));
    //本番用の10分
    DateTime time = now.add(Duration(minutes: 10));
    //スヌーズ用にアラームを作成する
    //alarmListに加えていないのでホーム画面で表示されないし、端末に保存されない
    Alarm snoozeAlarm = new Alarm(
        id: alarmList.length,
        alarmId: (alarm.alarmId + 1),
        time: TimeOfDay.fromDateTime(time),
        description: alarm.description + 'のスヌーズ',
        repeat: list,
        vibration: alarm.vibration,
        qrCodeMode: alarm.qrCodeMode,
        stopSnooze: false);
    await setAlarm10minSnoozeSchedule(snoozeAlarm);
    print('set snooze at ${time.hour} : ${time.minute}');
    alarmedId = alarm.alarmId;
  }
}

stopAlarm10minSnooze() async {
  Alarm alarm = await getAlarm();
  int id = alarm.alarmId + 1;
  //スヌーズ用の通知とバックグラウンド処理をキャンセル
  Workmanager.cancelByUniqueName(id.toString());
  await flutterLocalNotificationsPlugin.cancel(id);
  print('cansel snooze schedule ID:$id');

  //もし単発のアラームであれば削除する
  //alarmListと端末からも消える　ホーム画面でも消える
  if (alarm.repeat.length == 0) {
    deleteAlarm(alarm);
    print('delete alarm');
  } else {
    //曜日のくり返しが登録されているアラームである場合
    //アラームの中のスヌーズ解除チェック用変数を更新
    alarm.stopSnooze = false;
    //念の為一度アラームの通知とバックグラウンド処理の予約をキャンセルする
    //実行済みだが、同じalarmIdで通知などを登録する為エラーを回避する
    await flutterLocalNotificationsPlugin.cancel(alarm.alarmId);
    Workmanager.cancelByUniqueName(alarm.alarmId.toString());
    //再度アラームの通知とバックグラウンド処理を登録（予約）する
    setAlarmWeeklySchedule(alarm);
    //端末内のアラームリストを一度消し、チェック用変数が更新されたもので保存しなおす
    await deleteAlarmData();
    await saveAlarmData(alarmList);
    print('set weekly alarm');
  }

  print('stop snooze');
}

setSettingAlarmId(Alarm alarm, tz.TZDateTime scheduledDate) async {
  if (appSetting.movingAlarmId == 0 ||
      appSetting.feastAlarmTime == initDateTime) {
    appSetting.movingAlarmId = alarm.alarmId;
    appSetting.feastAlarmTime = scheduledDate;

    print('直近のアラーム情報が設定されました。\nID:${alarm.alarmId} Time:${scheduledDate}');
  } else {
    //設定データに登録されている時間よりも新規アラームの方が早い時
    if (appSetting.feastAlarmTime.isAfter(scheduledDate)) {
      appSetting.feastAlarmTime = scheduledDate;
      appSetting.movingAlarmId = alarm.alarmId;
      print(
          '直近のアラーム情報が更新されました。\nID:${appSetting.feastAlarmTime} Time:${appSetting.movingAlarmId}');
    } else {
      print('直近のアラーム情報の更新は必要ありません');
    }
  }
  deleteSettingData();
  saveSettingData(appSetting);
}

startRingAlarm({bool vibrate = true}) async {
  Alarm alarm = await getAlarm();
  loadSettingData();
  //登録されているアラームのバイブレーションがオンになっていれば振動もさせる
  if (alarm.vibration == false) vibrate = false;
  if (vibrate) {
    Vibration.vibrate(pattern: [500, 500, 500, 500], repeat: 2);
  }
  FlutterRingtonePlayer.playAlarm(
      looping: true, asAlarm: true, volume: appSetting.volume);
}

void stopRingAlarm() {
  FlutterRingtonePlayer.stop();
  Vibration.cancel();
}

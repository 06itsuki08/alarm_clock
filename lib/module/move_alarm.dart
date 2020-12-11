import 'package:alarm_clock/main.dart';
import 'package:alarm_clock/module/alarm.dart';
import 'package:alarm_clock/module/alarm_list.dart';
import 'package:alarm_clock/module/shared_prefs.dart';
import 'package:alarm_clock/module/user_setting.dart';
import 'package:alarm_clock/screen/alarmstop.dart';
import 'package:alarm_clock/screen/home.dart';
import 'package:alarm_clock/val/string.dart';
import 'package:auto_size_text/auto_size_text.dart';
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
IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails(
    presentAlert: true, presentBadge: true, presentSound: true);

//バックグラウンド処理の予約をする
setBackgroundTimer(tz.TZDateTime time) {
  print('------バックグラウンドタイマー時間取得-----');
  DateTime now = DateTime.now();
  //バックグラウンド処理の開始までラグがあるときがあるので要調整
  //現在時間と登録された時間までを引いた時間を指定する（Durationじゃないといけないのがやっかい）
  Duration setTime = time.difference((now));
  print('バックグラウンド処理は ${setTime.toString()}　後に動作します');
  return setTime;
}

//アラームに曜日のくり返しが無い場合は直近のその時間に鳴らす（当日か翌日に鳴る）
setAlarmOnceSchedule(Alarm alarm) async {
  print('----------------バックグラウンド処理登録開始--------------');
  Workmanager.registerOneOffTask(alarm.alarmId.toString(), 'alarm',
      tag: 'alarm',
      initialDelay: setBackgroundTimer(_nextInstanceTime(alarm)),
      inputData: {
        'int': alarm.alarmId,
        'vibration': alarm.vibration,
        'hour': alarm.time.hour,
        'minute': alarm.time.minute,
        'volume': appSetting.volume,
      });

  print('----------------バックグラウンド処理登録完了--------------');

  print('----------------通知登録開始--------------');
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
          ),
          iOS: iosNotificationDetails),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: '$scheduledDate');

  print('----------------通知登録完了--------------');
  setSettingAlarmId(alarm, _nextInstanceTime(alarm));
}

//アラームに曜日のくり返しがある場合に使う
setAlarmWeeklySchedule(Alarm alarm) async {
  print('曜日アラーム登録開始');

  print('----------------バックグラウンド処理登録開始--------------');
  tz.TZDateTime scheduledDate = _nextInstanceWeek(alarm);
  Workmanager.registerOneOffTask(alarm.alarmId.toString(), 'alarm',
      tag: 'alarm',
      initialDelay: setBackgroundTimer(_nextInstanceWeek(alarm)),
      inputData: {
        'int': alarm.alarmId,
        'vibration': alarm.vibration,
        'hour': alarm.time.hour,
        'minute': alarm.time.minute,
        'volume': appSetting.volume,
      });

  print('----------------バックグラウンド処理登録完了--------------');

  print('----------------通知登録開始--------------');
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
          ),
          iOS: iosNotificationDetails),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: '$scheduledDate');

  print('----------------通知登録完了--------------');
  setSettingAlarmId(alarm, _nextInstanceWeek(alarm));
  print('曜日アラーム登録完了');
}

//SnoozeのIDは元のAlarmIDに+1している
setAlarm10minSnoozeSchedule(Alarm alarm) async {
  print('スヌーズアラーム登録開始');

  print('----------------バックグラウンド処理登録開始--------------');
  tz.TZDateTime scheduledDate = _nextInstanceTime(alarm);
  Workmanager.registerOneOffTask(alarm.alarmId.toString(), 'snooze',
      tag: 'snooze',
      initialDelay: setBackgroundTimer(_nextInstanceTime(alarm)),
      inputData: {
        'int': alarm.alarmId - 1,
        'vibration': alarm.vibration,
        'hour': alarm.time.hour,
        'minute': alarm.time.minute,
        'volume': appSetting.volume,
      });

  print('----------------バックグラウンド処理登録完了--------------');
  print('----------------通知登録開始--------------');
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
          ),
          iOS: iosNotificationDetails),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: '$scheduledDate');

  print('----------------通知登録完了--------------');
  setSettingAlarmId(alarm, _nextInstanceTime(alarm));
}

//現在が、目的の時間より前か
tz.TZDateTime _nextInstanceTime(Alarm alarm) {
  print('アラームの直近の時間取得開始');
  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month,
      now.day, alarm.time.hour, alarm.time.minute);

  //もし現在時刻がアラームを鳴らす時間を過ぎていれば1日足して翌日にする
  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }
  print('予定時刻:$scheduledDate');
  print('アラームの直近の時間取得完了');
  return scheduledDate;
}

//現在が、目的の曜日であるか
tz.TZDateTime _nextInstanceWeek(Alarm alarm) {
  print('アラームの直近の曜日取得開始');
  tz.TZDateTime scheduledDate = _nextInstanceTime(alarm);

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

  print('予定時刻:$scheduledDate');
  print('アラームの直近の曜日取得完了');
  return scheduledDate;
}

cancelAlarm(int id) async {
  await flutterLocalNotificationsPlugin.cancel(id);
}

cancelAllAlarm() async {
  await flutterLocalNotificationsPlugin.cancelAll();
}

// iOSでのフォアグランドでの動作
Future onDidReceiveLocalNotification(
    int id, String title, String body, String payload) async {
  // display a dialog with the notification details, tap ok to go to another page
  BuildContext context;
  Alarm alarm = await getAlarm();
  startRingAlarm();
  showDialog(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: AutoSizeText(alarm.description),
      content: AutoSizeText('${alarm.description}の時間になりました'),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          child: AutoSizeText('アラームを停止する'),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, "/", (_) => false);
          },
        )
      ],
    ),
  );
}

//
setAlarm10minSnooze() async {
  print('スヌーズ登録処理開始');
  Alarm alarm = await getAlarm();

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

  print('スヌーズ登録処理完了');
}

stopAlarm10minSnooze() async {
  print('スヌーズ解除処理開始');
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
    print('くり返しのないアラームの削除完了');
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
    print('くり返しのあるアラームの再設定完了');
  }

  print('スヌーズ解除処理完了');
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
      print('直近のアラーム情報の更新は必要ありませんでした。');
    }
  }
  deleteSettingData();
  saveSettingData(appSetting);
}

startRingAlarm(
    {bool vibrate = true,
    double volume = -1.0,
    bool vibrateGet = false}) async {
  print('音と振動ON！');
  if (!vibrateGet) {
    Alarm alarm = await getAlarm();
    vibrate = alarm.vibration;
  }
  if (volume < 0) {
    loadSettingData();
    volume = appSetting.volume;
  }
  //登録されているアラームのバイブレーションがオンになっていれば振動もさせる

  if (vibrate) {
    Vibration.vibrate(pattern: [500, 500, 500, 500], repeat: 2);
  }
  //Androidのみ
  FlutterRingtonePlayer.playAlarm(looping: true, asAlarm: true, volume: volume);
}

void stopRingAlarm() {
  print('音と振動OFF！');
  FlutterRingtonePlayer.stop();
  Vibration.cancel();
}

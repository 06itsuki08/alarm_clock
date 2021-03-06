import 'dart:io';
import 'dart:ui';

import 'package:alarm_clock/module/alarm_list.dart';
import 'package:alarm_clock/module/shared_prefs.dart';
import 'package:alarm_clock/module/user_setting.dart';
import 'package:alarm_clock/screen/alarmsetting.dart';
import 'package:alarm_clock/module/move_alarm.dart';
import 'package:alarm_clock/screen/alarmstop.dart';
import 'package:alarm_clock/screen/help.dart';
import 'package:alarm_clock/screen/home.dart';
import 'package:alarm_clock/screen/mainmenu.dart';
import 'package:alarm_clock/screen/setting.dart';
import 'package:alarm_clock/screen/snoozestop.dart';
import 'package:alarm_clock/val/color.dart';
import 'package:alarm_clock/val/string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';
import 'dart:isolate';

import 'module/alarm.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const MethodChannel platform = MethodChannel('alarm_clock');
final navKey = new GlobalKey<NavigatorState>();

bool runNotification = false;
String sendPortName = "alarmclock_send_port";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final ReceivePort receivePort = ReceivePort();

  receivePort.listen((message) {
    alarmedId = message[0];
    if (message[1]) {
      startRingAlarm(volume: message[2], vibrate: message[3], vibrateGet: true);
    } else {
      stopRingAlarm();
    }
    print('change Ring');
    //receivePort.close();
  });
  IsolateNameServer.removePortNameMapping(sendPortName);
  IsolateNameServer.registerPortWithName(receivePort.sendPort, sendPortName);

  //set timezone
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Tokyo'));

// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  Workmanager.initialize(callbackDispatcher, isInDebugMode: false);

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@drawable/notification_icon');
  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
          onDidReceiveLocalNotification: onDidReceiveLocalNotification,
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
          defaultPresentAlert: true,
          defaultPresentSound: true);
  final MacOSInitializationSettings initializationSettingsMacOS =
      MacOSInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
          defaultPresentAlert: true,
          defaultPresentSound: true);
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
    moveAlarm = true;
    if (moveAlarm != true) moveAlarm = true;
    loadSettingData();
    BuildContext context;
    Navigator.pushNamedAndRemoveUntil(context, "/", (_) => false);
  });

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
    //設定データを読み込み

    loadSettingData();

    return MaterialApp(
      title: title,
      //右上のデバッグモードって帯を消す
      debugShowCheckedModeBanner: false,
      //テーマ　アプリの基本色を決めたりする
      theme: appTheme,
      navigatorKey: navKey,
      routes: <String, WidgetBuilder>{
        '/': (context) => Home(),
        '/mainmenu': (context) => MainMenu(),
        '/alarmsetting': (context) => AlarmSetting(),
        '/setting': (context) => Setting(),
        '/alarmstop': (context) => AlarmStop(),
        '/snoozestop': (context) => SnoozeStop(),
        '/help': (context) => Help(),
      },
    );
  }
}

//バックグラウンドでの処理主にサイレントマナーモードでの通知音・バイブ用
void callbackDispatcher() async {
  Workmanager.executeTask((taskName, inputData) async {
    switch (taskName) {
      case Workmanager.iOSBackgroundTask:
        break;
      case 'alarm':
        if (moveAlarm != true) moveAlarm = true;
        alarmedId = inputData['int'];
        print('Ring! Alarm id ${inputData['int']}');
        List<dynamic> list = [
          inputData['int'],
          true,
          inputData['volume'],
          inputData['vibration']
        ];
        final SendPort send = IsolateNameServer.lookupPortByName(sendPortName);

        send?.send(list);
        break;
      case 'snooze':
        if (moveAlarm != true) moveAlarm = true;
        alarmedId = inputData['int'];
        print('Ring! Snooze id ${inputData['int']}');
        List<dynamic> list = [
          inputData['int'],
          true,
          inputData['volume'],
          inputData['vibration']
        ];
        final SendPort send = IsolateNameServer.lookupPortByName(sendPortName);
        send?.send(list);
        break;
    }
    print('call back $taskName');
    return Future.value(true);
  });
}

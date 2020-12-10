import 'dart:io';

import 'package:alarm_clock/screen/alarmstop.dart';
import 'package:alarm_clock/screen/mainmenu.dart';
import 'package:alarm_clock/val/string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);
  _Home createState() => _Home();
}

class _Home extends State<Home> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    //もしmoveAlarmがnullだったときはfalseにしてとりあえずメイン画面に移動させる
    if (moveAlarm != true) moveAlarm = false;
    //アプリがバックグラウンドから復帰したときなどの状態をとれる
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //もしアプリがバックグラウンドがら戻ってきたら、画面を更新させる。
    //アラーム登録後にアプリを落とさないで、アラームが鳴ってアプリに戻ってきた場合などに動作する
    if (state == AppLifecycleState.resumed) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      //アラームが鳴っているときはアラーム停止画面に遷移、違う場合はメイン画面に遷移
      if (moveAlarm) {
        return AlarmStop();
      } else {
        return MainMenu();
      }
    } else {
      return OSisIOS();
    }
  }
}

class OSisIOS extends StatefulWidget {
  OSisIOS({Key key}) : super(key: key);
  @override
  IosPage createState() => IosPage();
}

class IosPage extends State<OSisIOS> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            height: size.height,
            width: size.width,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background.png"),
                fit: BoxFit.fill,
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AutoSizeText('Sorry!!\niOSは、OSの制約によりサポートされていません。'),
                ],
              ),
            )));
  }
}

import 'package:alarm_clock/module/alarm_list.dart';
import 'package:alarm_clock/module/move_alarm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:alarm_clock/val/string.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:vibration/vibration.dart';

class Setting extends StatefulWidget {
  Setting({Key key}) : super(key: key);
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  String text = '設定画面';
  String yotei = '設定項目';
  FlutterRingtonePlayer _ringtonePlayer = FlutterRingtonePlayer();
  Vibration _vibration = Vibration();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    stopRingAlarm();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //AppBarはアプリのタイトルとかを表示してくれる領域のこと
      appBar: AppBar(
        title: Text(setting),
      ),
      //body アプリのメイン画面
      //Column 子供になるパーツが全部縦に並んでくれる　子供はchildren にいれる
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(text),
          Text(yotei),
          RaisedButton(
            onPressed: () => startRingAlarm(),
            child: Text('サウンドテスト'),
          ),
          RaisedButton(
            onPressed: () => stopRingAlarm(),
            child: Text('テスト終了'),
          ),
        ],
      ),
    );
  }
}

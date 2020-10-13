import 'package:alarm_clock/screen/alarmsetting.dart';
import 'package:alarm_clock/screen/mainmenu.dart';
import 'package:alarm_clock/screen/setting.dart';
import 'package:alarm_clock/val/string.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      //右上のデバッグモードって帯を消す
      debugShowCheckedModeBanner: false,
      //テーマ　アプリの基本色を決めたりする
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MainMenu(),
        '/alarmsetting': (context) => AlarmSetting(),
        '/setting': (context) => Setting(),
      },
    );
  }
}

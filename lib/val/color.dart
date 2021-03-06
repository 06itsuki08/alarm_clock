//アプリ内で共通の使用色や文字のテーマ等はここに宣言しておく
//ボタンの色とか　文字の色とか 文字の大きさ　フォント
//final Color 名前 =Colors.blue;
// -> https://api.flutter.dev/flutter/material/Colors-class.html
//final Color.fromRGBO(255,255,255,0);
// -> RGBと透明度で指定するタイプ

import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  primaryColor: Colors.amber[800],
  accentColor: Colors.amber[700],
  brightness: Brightness.light,
  fontFamily: 'MPLUSRounded',
);

final TextStyle itemName =
    TextStyle(fontWeight: FontWeight.bold, fontFamily: 'MPLUSRounded');

final TextStyle alarmItem = TextStyle(fontSize: 18, fontFamily: 'MPLUSRounded');

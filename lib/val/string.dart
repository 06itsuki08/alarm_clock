//アプリ内でよく使用する文字はここに宣言する
//final 型 名前="";

import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final String title = "カメラde目覚まし📷";
final String alarmSetting = "アラーム設定";
final String setting = "設定";
final String alarmstop = "アラーム停止";
final String snoozestop = "スヌーズ解除";
final String alartCaution = "注意";
final String alartConfirmation = "確認";
final String alartDeleteAlarm = "このアラームを削除します";
final String cansel = "cansel";
final String ok = "ok";
final String delete = "delete";
final String qrcodeText = 'Nekonokai'; //QRコード内の文字列
final tz.TZDateTime initDateTime = tz.TZDateTime(tz.local, 2020, 1, 1, 0, 0);
Size size;
bool moveAlarm;

SizedBox widthSpacer({double width = 5.0}) {
  return SizedBox(width: width);
}

SizedBox heightSpacer({double height = 5.0}) {
  return SizedBox(height: height);
}

BoxDecoration borderLine = BoxDecoration(
  border: Border(
      bottom: BorderSide(
    width: 0.5,
    color: Colors.grey,
    style: BorderStyle.solid,
  )),
);

/*
円形ボタンのstyle
CircleBorder circleButton = CircleBorder(
    side: BorderSide(
  color: Colors.greenAccent,
  width: 1.0,
  style: BorderStyle.solid,
));*/

//アプリ内でよく使用する文字はここに宣言する
//final 型 名前="";

import 'package:flutter/material.dart';

final String title = "カメラde目覚まし📷";
final String alarmSetting = "アラーム設定";
final String setting = "設定";
final TextStyle itemName = TextStyle(fontWeight: FontWeight.w600, fontSize: 20);

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

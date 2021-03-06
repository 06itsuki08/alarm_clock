import 'dart:convert';

import 'package:alarm_clock/module/alarm.dart';
import 'package:alarm_clock/module/alarm_list.dart';
import 'package:alarm_clock/module/quiz.dart';
import 'package:alarm_clock/module/user_setting.dart';
import 'package:alarm_clock/val/string.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

saveAlarmData(List<Alarm> list) async {
  //await pref.set型("key",val);
  SharedPreferences pref = await SharedPreferences.getInstance();
  list.sort((a, b) => b.time.toString().compareTo(a.time.toString()));
  List<String> alarms = list.map((f) => json.encode(f.toJson())).toList();
  await pref.setStringList('alarms', alarms);
  print('アラームリスト保存完了');
}

loadAlarmData({bool needReturn = false}) async {
  List<Alarm> list = List<Alarm>();
  //await pref.get型("key");
  SharedPreferences pref = await SharedPreferences.getInstance();
  var result = pref.getStringList('alarms');
  if (result != null) {
    list = result.map((f) => Alarm.fromJson(json.decode(f))).toList();
  }
  alarmList = list;
  print('アラームリストロード完了');
  if (needReturn == true) {
    return list;
  }
}

deleteAlarmData() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  await pref.remove('alarms');
  print('アラームリスト削除完了');
}

saveSettingData(UserSetting setting) async {
  //await pref.set型("key",val);
  SharedPreferences pref = await SharedPreferences.getInstance();
  String settings = json.encode(setting.toJson());
  await pref.setString('settings', settings);
  print('設定データ保存完了');
}

loadSettingData({bool needReturn = false}) async {
  UserSetting settings = UserSetting();
  //await pref.get型("key");
  SharedPreferences pref = await SharedPreferences.getInstance();
  var result = pref.getString('settings');
  if (result != null) {
    settings = UserSetting.fromJson(json.decode(result));
    print('設定データ読み込み成功');
  } else {
    List<bool> intList = [];
    for (int i = 0; i < quizList.length; i++) {
      intList.add(true);
    }
    settings = UserSetting(
        movingAlarmId: 0,
        feastAlarmTime: initDateTime,
        volume: 1.0,
        useQuiz: intList,
        quizClearCount: 3,
        colorCodeQuiz: false);
    print('設定データ読み込み失敗');
  }
  appSetting = settings;
  print('直近のアラームID：${appSetting.movingAlarmId}');
  print('設定データ読み込み完了');
}

deleteSettingData() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  await pref.remove('settings');
  print("設定データ削除完了");
}

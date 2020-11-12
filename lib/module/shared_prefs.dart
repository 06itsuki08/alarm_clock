import 'dart:convert';

import 'package:alarm_clock/module/alarm.dart';
import 'package:alarm_clock/module/alarm_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

saveAlarmData(List<Alarm> list) async {
  //await pref.set型("key",val);
  SharedPreferences pref = await SharedPreferences.getInstance();
  list.sort((a, b) => b.time.toString().compareTo(a.time.toString()));
  List<String> alarms = alarmList.map((f) => json.encode(f.toJson())).toList();
  await pref.setStringList('alarms', alarms);
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
  if (needReturn == true) {
    return list;
  }
}

deleteAlarmData() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  await pref.remove('alarms');
}

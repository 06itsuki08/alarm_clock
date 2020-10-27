import 'dart:convert';

import 'package:alarm_clock/module/alarm.dart';
import 'package:alarm_clock/module/alarm_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

saveData(List<Alarm> list) async {
  //await pref.set型("key",val);
  SharedPreferences pref = await SharedPreferences.getInstance();
  list.sort((a, b) => b.time.toString().compareTo(a.time.toString()));
  List<String> alarms = alarmList.map((f) => json.encode(f.toJson())).toList();
  await pref.setStringList('alarms', alarms);
}

loadData({bool needReturn = false}) async {
  alarmList = List<Alarm>();
  //await pref.get型("key");
  SharedPreferences pref = await SharedPreferences.getInstance();
  var result = pref.getStringList('alarms');
  if (result != null) {
    if (alarmList.isNotEmpty) alarmList.clear();
    alarmList = result.map((f) => Alarm.fromJson(json.decode(f))).toList();
  } else {
    alarmList.clear();
  }
  if (needReturn == true) {
    return alarmList;
  }
}

deleteData() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  await pref.remove('alarms');
}

reloadData() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  await pref.reload();
}

import 'package:alarm_clock/module/alarm.dart';
import 'package:alarm_clock/module/alarm_list.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

saveData(List<Alarm> list) async {
  //await pref.set型("key",val);
  SharedPreferences pref = await SharedPreferences.getInstance();
  await pref.setInt('AlarmCount', list.length);
  for (int i = 0; i < list.length; i++) {
    Alarm alarm = list[i];
    await pref.setInt("Id", i + 1);
    await pref.setString("Time",
        '${alarm.time.hour.toString()}:${alarm.time.minute.toString()}');
    await pref.setString("Description", alarm.description);
    if (alarm.repeat.length > 0) {
      List<String> repeatList = [];
      for (int j = 0; j < alarm.repeat.length; j++) {
        repeatList.add(alarm.repeat[j].toString());
      }
      await pref.setStringList("RepeatList", repeatList);
    } else {
      await pref.setStringList("RepeatList", null);
    }
    await pref.setBool("Vibration", alarm.vibration);
    await pref.setBool("QRCodeMode", alarm.qrCodeMode);
  }
}

loadData(List<Alarm> list) async {
  //await pref.get型("key");
  SharedPreferences pref = await SharedPreferences.getInstance();
  int listlength;
  try {
    listlength = pref.getInt('AlarmCount');

    for (int i = 0; i < listlength; i++) {
      int id = pref.getInt("Id");
      TimeOfDay time = TimeOfDay(
          hour: int.parse(pref.getString('Time').split(":")[0]),
          minute: int.parse(pref.getString('Time').split(":")[1]));
      String text = pref.getString('Description');

      List<int> repeat = [];
      if (pref.getStringList('RepeatList') != null) {
        repeat = (pref.getStringList('RepeatList')).cast<int>();
      }
      bool vibration = pref.getBool('Vibration');
      bool qrCodeMode = pref.getBool('QRCodeMode');
      Alarm alarm = new Alarm(
          id: id,
          time: time,
          description: text,
          repeat: repeat,
          vibration: vibration,
          qrCodeMode: qrCodeMode);
      list.add(alarm);
    }
  } on NoSuchMethodError {
    return null;
  }
  return list;
}

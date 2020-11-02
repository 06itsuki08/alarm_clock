import 'package:flutter/material.dart';

class Alarm {
  int id;
  int alarmId;
  TimeOfDay time;
  String description = '未登録';
  //String soundPath; Path取得未実装
  List<int> repeat;
  bool vibration;
  bool qrCodeMode;
  bool stopSnooze;

  Alarm(
      {this.id,
      this.alarmId,
      this.time,
      this.description,
      this.repeat,
      this.vibration,
      this.qrCodeMode,
      this.stopSnooze});

  Map toJson() => {
        'id': id,
        'alarmid': alarmId,
        'time': '${time.hour.toString()}:${time.minute.toString()}',
        'description': description,
        'repeat': repeat,
        'vibration': vibration,
        'qrCodeMode': qrCodeMode
      };

  Alarm.fromJson(Map json)
      : id = json['id'],
        alarmId = json['alarmid'],
        time = TimeOfDay(
            hour: int.parse(json['time'].split(":")[0]),
            minute: int.parse(json['time'].split(":")[1])),
        description = json['description'],
        repeat = json['repeat'].cast<int>(),
        vibration = json['vibration'],
        qrCodeMode = json['qrCodeMode'];
}

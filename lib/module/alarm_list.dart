import 'package:alarm_clock/module/alarm.dart';
import 'package:alarm_clock/module/shared_prefs.dart';
import 'package:alarm_clock/val/string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

List<Alarm> alarmList;

void addAlarm(Alarm alarm) {
  alarmList.add(alarm);
}

void updateAlarm(Alarm alarm, int i) {
  alarmList[i] = alarm;
  saveData(alarmList);
}

void relodeAlarmList() {
  alarmList.clear();
  loadData();
}

void deleteAlarm(Alarm alarm) {
  alarmList.remove(alarm);
  deleteData();
  saveData(alarmList);
}

buildListItem(
  Alarm alarm,
) {
  return Card(
    margin: const EdgeInsets.all(10.0),
    child: Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
                '${alarm.time.hour.toString().padLeft(2, '0')}:${alarm.time.minute.toString().padLeft(2, '0')}'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            buildSnoozeIcon(alarm.vibration),
            widthSpacer(width: size.width * 0.01),
            buildCameraIcon(alarm.qrCodeMode),
          ],
        ),
        Text('${alarm.description}'),
        checkRepeat(alarm.repeat),
      ],
    ),
  );
}

buildCameraIcon(bool check) {
  if (check == false) {
    return Icon(Icons.block);
  } else {
    return Icon(Icons.camera_alt);
  }
}

Icon buildSnoozeIcon(bool check) {
  if (check == false) {
    return Icon(Icons.notifications_off);
  } else {
    return Icon(Icons.notifications_active);
  }
}

checkRepeat(List<int> list) {
  if (list.length < 1 || list.length == null) {
    return Text(' ');
  } else {
    return buildRepeatIcon(list);
  }
}

Text buildRepeatIcon(List<int> list) {
  String youbi = '';
  for (int i = 0; i < list.length; i++) {
    switch (list[i]) {
      case 0:
        youbi += '日';
        break;
      case 1:
        youbi += '月';
        break;
      case 2:
        youbi += '火';
        break;
      case 3:
        youbi += '水';
        break;
      case 4:
        youbi += '木';
        break;
      case 5:
        youbi += '金';
        break;
      case 6:
        youbi += '土';
        break;
      default:
        break;
    }
    if (i < list.length - 1 && i >= 0) {
      youbi += ' , ';
    }
  }
  Text text = Text('$youbi');
  return text;
}

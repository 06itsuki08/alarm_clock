import 'package:alarm_clock/module/alarm.dart';
import 'package:alarm_clock/module/move_alarm.dart';
import 'package:alarm_clock/module/shared_prefs.dart';
import 'package:alarm_clock/val/string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

List<Alarm> alarmList;

void addAlarm(Alarm alarm) {
  alarmList.add(alarm);
}

//まだ実装中
void updateAlarm(Alarm alarm, int i) {
  alarmList[i] = alarm;
  //Todo:通知類の再登録を実装
  deleteAlarmData();
  saveAlarmData(alarmList);
}

void relodeAlarmList() async {
  //アラームリストを全消し
  alarmList.clear();
  //端末に保存してあるアラームリストを読み込み
  List<Alarm> list = await loadAlarmData(needReturn: true);
  alarmList = list;
  print('reloadfin alarmList Item num is ${alarmList.length}');
}

Future<Alarm> getAlarm() async {
  int i = 0;
  Alarm alarm;
  List<Alarm> list = await loadAlarmData(needReturn: true);
  print('load fin List item size is ${alarmList.length}');
  for (i = 0; i < list.length; i++) {
    if (alarmedId == list[i].alarmId) {
      break;
    }
  }
  if (i != list.length) {
    alarm = list[i];
    return alarm;
  } else {
    List<int> list = [];
    alarm = new Alarm(
        id: list.length,
        alarmId: 0,
        time: TimeOfDay.now(),
        description: 'アラーム取得失敗',
        repeat: list,
        vibration: true,
        qrCodeMode: true,
        stopSnooze: false);
    return alarm;
  }
}

void deleteAlarm(Alarm alarm) {
  //バックグラウンド処理の予定のキャンセル
  Workmanager.cancelByUniqueName(alarm.alarmId.toString());
  //アラームの通知を解除
  canselAlarm(alarm.alarmId);
  //アラームリストからアラームを除外
  alarmList.remove(alarm);
  //端末に書き込んだ削除前のアラームリストを一回消去
  deleteAlarmData();
  //アラームを除外されたアラームリストを書き込み
  saveAlarmData(alarmList);
}

buildListItem(Alarm alarm) {
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

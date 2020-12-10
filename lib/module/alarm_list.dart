import 'package:alarm_clock/main.dart';
import 'package:alarm_clock/module/alarm.dart';
import 'package:alarm_clock/module/move_alarm.dart';
import 'package:alarm_clock/module/shared_prefs.dart';
import 'package:alarm_clock/module/user_setting.dart';
import 'package:alarm_clock/val/color.dart';
import 'package:alarm_clock/val/string.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

List<Alarm> alarmList;

void addAlarm(Alarm alarm) {
  alarmList.add(alarm);
  print('アラーム追加完了');
}

//まだ実装中
void updateAlarm(Alarm alarm, int i) {
  print('----------------アラームアップデート開始--------------');
  alarmList[i] = alarm;
  //Todo:通知類の再登録を実装
  deleteAlarmData();
  saveAlarmData(alarmList);

  print('----------------アラームアップデート終了--------------');
}

void relodeAlarmList() async {
  print('----------------アラームリロード開始--------------');
  //アラームリストを全消し
  alarmList.clear();
  //端末に保存してあるアラームリストを読み込み
  List<Alarm> list = await loadAlarmData(needReturn: true);
  alarmList = list;
  print('reloadfin alarmList Item num is ${alarmList.length}');

  print('----------------アラームリロード終了--------------');
}

Future<Alarm> getAlarm() async {
  print('----------------アラーム取得開始--------------');
  int i = 0;
  Alarm alarm;
  List<Alarm> _alarmlist = await loadAlarmData(needReturn: true);
  await loadSettingData();
  alarmedId = appSetting.movingAlarmId;
  print('load fin List item size is ${alarmList.length}');
  print('AlarmedID is $alarmedId');
  for (i = 0; i < _alarmlist.length; i++) {
    if (appSetting.movingAlarmId == _alarmlist[i].alarmId) {
      break;
    }
  }

  if (i < _alarmlist.length) {
    alarm = _alarmlist[i];
    print('----------------アラーム取得完了--------------');
    return alarm;
  } else {
    List<int> list = [];
    alarm = new Alarm(
        id: 0,
        alarmId: appSetting.movingAlarmId,
        time: TimeOfDay.now(),
        description: 'アラーム',
        repeat: list,
        vibration: true,
        qrCodeMode: true,
        stopSnooze: false);

    print('----------------アラーム取得失敗・仮アラーム返却完了--------------');
    return alarm;
  }
}

Future<void> deleteAlarm(Alarm alarm) async {
  print('----------------アラーム削除開始--------------');

  //バックグラウンド処理の予定のキャンセル
  Workmanager.cancelByUniqueName(alarm.alarmId.toString());
  Workmanager.cancelByUniqueName((alarm.alarmId + 1).toString());
  print('-----バックグラウンド処理解除--------');

  //アラームの通知を解除
  canselAlarm(alarm.alarmId);
  canselAlarm(alarm.alarmId + 1);
  print('-----通知解除--------');

  //アラームリストからアラームを除外
  alarmList.remove(alarm);
  //端末に書き込んだ削除前のアラームリストを一回消去
  deleteAlarmData();
  //アラームを除外されたアラームリストを書き込み
  saveAlarmData(alarmList);
  print('-----アラームリストから削除--------');
  print('-----最新アラーム情報更新開始--------');
  final List<PendingNotificationRequest> pendingNotificationRequests =
      await flutterLocalNotificationsPlugin.pendingNotificationRequests();
  if (pendingNotificationRequests.isEmpty ||
      pendingNotificationRequests.length == 0) {
    appSetting.feastAlarmTime = initDateTime;
    appSetting.movingAlarmId = 0;
  } else {
    appSetting.feastAlarmTime = initDateTime;
    appSetting.movingAlarmId = 0;
    pendingNotificationRequests.forEach((element) {
      tz.TZDateTime elementTime =
          tz.TZDateTime.parse(tz.local, element.payload);
      if (appSetting.feastAlarmTime == initDateTime) {
        appSetting.feastAlarmTime = elementTime;
        appSetting.movingAlarmId = element.id;
      } else if (appSetting.feastAlarmTime.isAfter(elementTime)) {
        appSetting.feastAlarmTime = elementTime;
        appSetting.movingAlarmId = element.id;
        print('直近のアラーム情報が再設定されました。\nID:${element.id} Time:${elementTime}');
      }
    });
  }
  deleteSettingData();
  saveSettingData(appSetting);
  print('-----最新アラーム情報更新完了--------');

  print('----------------アラーム削除完了--------------');
}

buildListItem(Alarm alarm) {
  return Card(
    //カード間を周囲10ポイント？空ける
    margin: const EdgeInsets.all(10.0),
    //標高ってでてきたけど完全透明(color:Colors.transナンチャラ)にする際はこれが必要らしい
    elevation: 0,
    //カードの背景色を白かつ透明度を0.85にする
    color: Colors.white.withOpacity(0.85),
    child: Padding(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Column(
        children: <Widget>[
          //1行目
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              //時間
              AutoSizeText(
                '${alarm.time.hour.toString().padLeft(2, '0')}:${alarm.time.minute.toString().padLeft(2, '0')}',
                style: TextStyle(

                    //新たに追加したフォント
                    fontFamily: 'MPLUSRounded',
                    //フォントを太字にする
                    fontWeight: FontWeight.bold),
                minFontSize: 40,
              ),
            ],
          ),

          //2行目
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //アイコン
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  //バイブレーションの有無のアイコン
                  buildSnoozeIcon(alarm.vibration),
                  //アイコンの間のスペース
                  widthSpacer(width: size.width * 0.025),
                  //ＱＲコードモードのアイコン
                  buildCameraIcon(alarm.qrCodeMode),
                ],
              ),
              if (alarm.repeat.length > 0)
                //曜日　この先でもフォントサイズとか弄っている
                checkRepeat(alarm.repeat),
            ],
          ),
          //3行目
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              //アラームの説明
              Expanded(
                child: AutoSizeText(
                  alarm.description,
                  style: TextStyle(
                    //今回新たに追加したフォント Googleフォントで下の名前のである
                    fontFamily: 'MPLUSRounded',
                  ),
                  //最大2行
                  maxLines: 1,
                  //溢れたら...で丸める
                  overflow: TextOverflow.ellipsis,
                  //ソフト改行で分割するか（多分入力時に改行されたら）
                  softWrap: true,
                  //テキストの表示位置　上のRowのmainAxisのcenterが効かなかったのでここでも指定
                  textAlign: TextAlign.center,
                  minFontSize: 20,
                ),
              ),
            ],
          ),
        ],
      ),
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
  if (list.length > 0 || list.length != null) {
    return Row(
      children: [
        //アイコンと曜日の文字のスペース
        widthSpacer(width: size.width * 0.05),
        buildRepeatIcon(list),
      ],
    );
  }
  /*
  元々elseでスペースを返していた
    //全ての曜日を選択した場合のスペースはこれ「　　　　　　　      」
    //return AutoSizeText('　　　　　　　      ',style: TextStyle(fontSize: 18, fontFamily: 'MPLUSRounded'));
  */
}

AutoSizeText buildRepeatIcon(List<int> list) {
  String youbi = '';
  for (int i = 0; i < list.length; i++) {
    switch (list[i]) {
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
      case 7:
        youbi += '日';
        break;
      default:
        break;
    }
    //複数かつ最後の曜日じゃないときに','を入れる
    if (i < list.length - 1 && i >= 0) {
      youbi += ' , ';
    }
  }
  AutoSizeText text = AutoSizeText(
    '$youbi',
    style: TextStyle(
        fontSize: 20, fontFamily: 'MPLUSRounded', fontWeight: FontWeight.bold),
  );

  return text;
}

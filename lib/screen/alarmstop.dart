import 'dart:isolate';
import 'dart:ui';

import 'package:alarm_clock/module/alarm.dart';
import 'package:alarm_clock/module/alarm_list.dart';
import 'package:alarm_clock/module/move_alarm.dart';
import 'package:alarm_clock/module/shared_prefs.dart';
import 'package:alarm_clock/val/string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:vibration/vibration.dart';

import '../main.dart';

class AlarmStop extends StatefulWidget {
  @override
  _AlarmStopState createState() => _AlarmStopState();
}

class _AlarmStopState extends State<AlarmStop> {
  int stopCount;
  Alarm alarm;
  bool qrCodeFin;

  @override
  void initState() {
    super.initState();
    stopCount = 0;
    qrCodeFin = false;
    //↓はテスト用に飛んだ時用
    if (moveAlarm == false) startRingAlarm();
  }

  @override
  void dispose() {
    stopRingAlarm();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: Text(alarmstop),
        ),
        body: switchStopPage());
  }

  switchStopPage() {
    if (stopCount < 5) {
      return alarmMode();
    } else if (alarm.qrCodeMode && qrCodeFin == false) {
      checkAlarmRing();
      return alarmStopOnQRCode();
    } else {
      qrCodeFin = true;
      stopRingAlarm();
      checkAlarmRing();
      return snoozeStopMode();
    }
  }

  checkAlarmRing() async {
    if (moveAlarm) {
      final SendPort send = IsolateNameServer.lookupPortByName(sendPortName);
      List<dynamic> list = [alarmedId, false];
      send?.send(list);
      setState(() {
        moveAlarm = false;
        stopRingAlarm();
      });
    } else {
      setState(() {
        moveAlarm = false;
      });
    }
    //Todo:10分スヌーズ発動
  }

  Widget alarmMode() {
    return FutureBuilder(
        future: getAlarm(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            alarm = snapshot.data;
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                heightSpacer(height: size.height * 0.05),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      '${DateTime.now().month}月${DateTime.now().day}日',
                      style:
                          TextStyle(fontWeight: FontWeight.w400, fontSize: 30),
                    ),
                    widthSpacer(width: size.width * 0.1),
                  ],
                ),
                heightSpacer(height: size.height * 0.05),
                Text(
                    '${alarm.time.hour.toString().padLeft(2, '0')} : ${alarm.time.minute.toString().padLeft(2, '0')}',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 50)),
                heightSpacer(height: size.height * 0.025),
                Text('${alarm.description}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    )),
                heightSpacer(height: size.height * 0.05),
                Text(
                  'あと${5 - stopCount}回タップ！',
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 30),
                ),
                heightSpacer(height: size.height * 0.025),
                RaisedButton(
                  onPressed: () {
                    setState(() {
                      stopCount++;
                    });
                  },
                  child: Text('TAP!'),
                )
              ],
            );
          } else {
            return Text('Alarm get failed');
          }
        });
  }

  alarmStopOnQRCode() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text('QRcodeを映りこませる'),
            ]),
        heightSpacer(height: size.height * 0.1),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
                height: size.height * 0.1,
                width: size.width / 2,
                child: RaisedButton(
                  onPressed: () {
                    setState(() {
                      qrCodeFin = true;
                    });
                  },
                  child: Icon(
                    Icons.camera_alt,
                    size: 50,
                  ),
                )),
          ],
        ),
        heightSpacer(height: size.height * 0.1),
      ],
    );
  }

  snoozeStopMode() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text('質問'),
        Text('回答'),
      ],
    );
  }

  //movealarm=false;
  //reSuchedule
  //flagOff
}

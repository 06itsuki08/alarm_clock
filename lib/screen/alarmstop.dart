import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:alarm_clock/module/alarm.dart';
import 'package:alarm_clock/module/alarm_list.dart';
import 'package:alarm_clock/module/move_alarm.dart';
import 'package:alarm_clock/val/string.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        body: Container(
            height: size.height,
            width: size.width,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background.png"),
                fit: BoxFit.fill,
              ),
            ),
            child: switchStopPage()));
  }

  switchStopPage() {
    //５回ボタンを押すまではボタンを押す画面
    if (stopCount < 5) {
      return alarmMode();
    } else if (alarm.qrCodeMode && qrCodeFin == false) {
      //５回ボタンを押した後でアラームがQRコードモードをオンにしている場合
      return alarmStopOnQRCode();
    } else {
      //５回ボタンを押して、ＱＲコードモードがオフ若しくは、
      qrCodeFin = true;
      checkAlarmRing();
      return snoozeStopMode();
    }
  }

  checkAlarmRing() async {
    //アラームが動作（鳴って）している場合
    if (moveAlarm) {
      //アラーム音を停止させる
      final SendPort send = IsolateNameServer.lookupPortByName(sendPortName);
      List<dynamic> list = [alarmedId, false];
      send?.send(list);

      //10分スヌーズを起動する
      await setAlarm10minSnooze();
      //アラームを停止(音止めた)させた
      if (qrCodeFin == true) {
        setState(() {
          moveAlarm = false;
        });
      }
    }
  }

  //５回ボタンを押させる画面
  Widget alarmMode() {
    return FutureBuilder(
        //今鳴らしているアラームの情報を取得する
        future: getAlarm(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          //アラーム情報の取得が出来たらボタンの画面を出す
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

  //QRcodeでスヌーズを止めさせる
  //実装中
  alarmStopOnQRCode() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                '専用のQRコードをスキャンしてください',
                style: TextStyle(fontSize: 20),
              ),
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
                    getQRCode();
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

  //クイズ？をやらせる（ここで10分スヌーズを解除する）
  snoozeStopMode() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text('質問'),
        Text('回答'),
        //Test用
        Text('Snooze解除'),
        SizedBox(
            height: size.height * 0.1,
            width: size.width / 2,
            child: RaisedButton(
              onPressed: () {
                setState(() async {
                  await stopAlarm10minSnooze();
                  Navigator.pushNamedAndRemoveUntil(context, "/", (_) => false);
                });
              },
              child: Icon(
                Icons.alarm,
                size: 50,
              ),
            )),
      ],
    );
  }

  getQRCode() async {
    String scanResult;
    checkAlarmRing();
    try {
      var result = await BarcodeScanner.scan();
    } on PlatformException catch (e) {
      var result = ScanResult(
        type: ResultType.Error,
        format: BarcodeFormat.unknown,
      );

      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          result.rawContent = 'カメラへのアクセスが許可されていません!';
        });
      } else {
        result.rawContent = 'エラー：$e';
      }
      setState(() {
        scanResult = result.rawContent;
      });
    }

    if (scanResult == qrcodeText) {
      print('QRコードが一致しました');
      setState(() {
        qrCodeFin = true;
      });
    } else {
      print('一致しませんでした。');
      setState(() {
        qrCodeFin = true;
      });
    }
  }
}

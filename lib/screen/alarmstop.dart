import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:alarm_clock/module/alarm.dart';
import 'package:alarm_clock/module/alarm_list.dart';
import 'package:alarm_clock/module/move_alarm.dart';
import 'package:alarm_clock/module/quiz.dart';
import 'package:alarm_clock/screen/snoozestop.dart';
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
  int stopCount; //５回タップ用カウンター
  Alarm alarm;
  bool qrCodeFin; //QRコードが正確に読み取れたか
  bool qrCodeFalse; //QRコードの取得が失敗したらtrue
  TextEditingController textCtrl;
  bool pushQRQuiz; //QRコード代わりのクイズが選択されたか
  List<int> numQuiz; //QRコード代わりのクイズ
  bool quizIncorrectAnswer; //クイズが不正解だとtrue

  @override
  void initState() {
    super.initState();
    stopCount = 0;
    qrCodeFin = false;
    qrCodeFalse = false;
    pushQRQuiz = false;
    textCtrl = TextEditingController();
    numQuiz = randomNumAdd(3);
    quizIncorrectAnswer = false;
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
        resizeToAvoidBottomInset: false,
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
    } else if (alarm.qrCodeMode && pushQRQuiz && qrCodeFin == false) {
      //QRコードが読み超えないときに代わりに問題を解く
      return falseQRCode();
    } else if (alarm.qrCodeMode && qrCodeFin == false) {
      //５回ボタンを押した後でアラームがQRコードモードをオンにしている場合
      return alarmStopOnQRCode();
    } else {
      //５回ボタンを押して、ＱＲコードモードがオフ若しくは、QRコードを読み終えた（クイズを解いた）
      qrCodeFin = true;
      checkAlarmRing();
      return quizStart();
    }
  }

  checkAlarmRing() async {
    //アラームが動作（鳴って）している場合
    if (moveAlarm) {
      //アラーム音を停止させる
      final SendPort send = IsolateNameServer.lookupPortByName(sendPortName);
      List<dynamic> list = [alarmedId, false];
      send?.send(list);

      //アラームを停止(音止めた)させた
      if (qrCodeFin == true) {
        //10分スヌーズを起動する
        await setAlarm10minSnooze();
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ]),
        heightSpacer(height: size.height * 0.3),
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
        if (qrCodeFalse)
          RaisedButton(
            onPressed: () {
              setState(() {
                pushQRQuiz = true;
              });
            },
            child: Text(
              'QRコードが読み込めない場合はこちら',
              style: TextStyle(color: Colors.black),
            ),
          ),
        heightSpacer(height: size.height * 0.1),
      ],
    );
  }

  getQRCode() async {
    String scanResult = '';
    checkAlarmRing();
    ScanResult result;
    try {
      result = await BarcodeScanner.scan();
    } on PlatformException catch (e) {
      result = ScanResult(
        type: ResultType.Error,
        format: BarcodeFormat.unknown,
      );

      if (e.code == BarcodeScanner.cameraAccessDenied) {
        result.rawContent = 'カメラへのアクセスが許可されていません!';
      } else {
        result.rawContent = 'エラー：$e';
      }
    }
    scanResult = result.rawContent;
    print('QRコードの読み取り結果：$scanResult');

    if (scanResult == qrcodeText) {
      print('QRコードが一致しました');
      setState(() {
        qrCodeFin = true;
      });
    } else {
      print('一致しませんでした。');
      setState(() {
        qrCodeFalse = true;
        qrCodeFin = false;
      });
    }
  }

  falseQRCode() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            widthSpacer(width: size.width * 0.05),
            Expanded(
              child: Text(
                'Q.下の足し算に回答してアラームを停止',
                style: TextStyle(fontSize: 20),
                maxLines: 3,
                softWrap: true,
              ),
            ),
            widthSpacer(width: size.width * 0.05),
          ],
        ),
        heightSpacer(height: size.height * 0.1),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${numQuiz[0]}＋${numQuiz[1]}＋${numQuiz[2]}＝？',
              style: TextStyle(fontSize: 30),
            ),
          ],
        ),
        heightSpacer(height: size.height * 0.05),
        if (quizIncorrectAnswer)
          Text(
            '不正解',
            style: TextStyle(color: Colors.red, fontSize: 18),
          ),
        SizedBox(
          width: size.width * 0.2,
          child: TextField(
            enabled: true,
            controller: textCtrl,
            cursorColor: Colors.amber,
            keyboardType: TextInputType.number,
            maxLines: 1,
          ),
        ),
        heightSpacer(height: size.height * 0.05),
        RaisedButton(
          onPressed: () {
            if (int.parse(textCtrl.text) == numQuiz[3]) {
              setState(() {
                qrCodeFin = true;
                quizIncorrectAnswer = false;
                pushQRQuiz = false;
              });
            } else {
              setState(() {
                quizIncorrectAnswer = true;
              });
            }
          },
          child: Text('答え合わせ'),
        ),
      ],
    );
  }

  //クイズ開始画面
  quizStart() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        heightSpacer(height: size.height * 0.1),
        Text(
          '10分後にスヌーズが鳴ります。\nクイズに答えてスヌーズを解除しましょう！',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        heightSpacer(height: size.height * 0.1),
        SizedBox(
          height: size.height * 0.1,
          width: size.width / 2,
          child: RaisedButton(
            onPressed: () {
              setState(() {
                Navigator.pushNamed(context, '/snoozestop');
              });
            },
            child: Text(
              'クイズ開始',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

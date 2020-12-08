import 'package:alarm_clock/module/alarm_list.dart';
import 'package:alarm_clock/module/move_alarm.dart';
import 'package:alarm_clock/module/shared_prefs.dart';
import 'package:alarm_clock/val/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:alarm_clock/val/string.dart';
import 'package:alarm_clock/module/alarm.dart';

// ignore: must_be_immutable
class AlarmSetting extends StatefulWidget {
  AlarmSetting({Key key}) : super(key: key);

  @override
  _AlarmSettingState createState() => _AlarmSettingState();
}

class _AlarmSettingState extends State<AlarmSetting> {
  String text = 'アラーム設定画面';
  String yotei = 'アラーム設定項目';
  TimeOfDay setTime;
  bool vibration;
  bool qrCodeMode;
  TextEditingController textCtrl;
  List<bool> isSelected;
  Alarm alarm;

  @override
  void initState() {
    super.initState();
    isSelected = [false, false, false, false, false, false, false];
    setTime = TimeOfDay.now();
    vibration = false;
    qrCodeMode = true;
    textCtrl = new TextEditingController();
  }

  @override
  void dispose() {
    textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      extendBodyBehindAppBar: true,
      //body アプリのメイン画面
      //Column 子供になるパーツが全部縦に並んでくれる　子供はchildren にいれる
      body: Container(
        height: size.height,
        width: size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: Container(
          color: Colors.white.withOpacity(0.7),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      heightSpacer(height: size.height * 0.05),

                      //時間取得
                      Container(
                        child: SizedBox(
                          child: Column(children: <Widget>[
                            heightSpacer(height: 5),
                            Text(
                              '${setTime.hour.toString().padLeft(2, '0')}:${setTime.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(fontSize: 90),
                            ),
                            SizedBox(height: 5),
                            RaisedButton(
                              onPressed: () => selectTime(context),
                              child: new Text(
                                '時間選択',
                                style: TextStyle(fontSize: 30),
                              ),
                              //color: Colors.amber[100],
                              //textColor: Colors.amber[700],
                            ),
                          ]),
                        ),
                      ),
                      heightSpacer(height: 20),
                      //説明
                      Container(
                        decoration: borderLine,
                        child: SizedBox(
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  widthSpacer(width: size.width * 0.1),
                                  SizedBox(
                                    child: Text(
                                      'アラームの説明',
                                      style: itemName,
                                    ),
                                  ),
                                ],
                              ),
                              //入力欄
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(
                                    width: size.width * 0.8,
                                    child: TextField(
                                      enabled: true,
                                      controller: textCtrl,
                                      cursorColor: Colors.amber,
                                      keyboardType: TextInputType.multiline,
                                      maxLines: 1,
                                      decoration: InputDecoration(
                                        hintText: 'アラーム一覧や動作時に表示される文字です。',
                                        hintStyle: TextStyle(fontSize: 15),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              heightSpacer(height: size.height * 0.025),
                            ],
                          ),
                        ),
                      ),

                      //繰り返し
                      Container(
                        decoration: borderLine,
                        child: Column(
                          children: <Widget>[
                            heightSpacer(height: size.height * 0.025),
                            SizedBox(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  heightSpacer(height: size.height * 0.025),
                                  widthSpacer(width: size.width / 10),
                                  Text(
                                    "くり返し",
                                    style: itemName,
                                  ),
                                  widthSpacer(width: size.width * 0.025),
                                  Expanded(
                                    child: Text(
                                      "選択した曜日でくり返します。\n未選択だとくり返されません。",
                                      maxLines: 2,
                                      softWrap: true,
                                    ),
                                  ),
                                  widthSpacer(width: size.width / 10),
                                ],
                              ),
                            ),
                            heightSpacer(height: size.height * 0.025),
                            SizedBox(
                              child: ToggleButtons(
                                selectedColor: Colors.orange,
                                fillColor: Colors.amber[50],
                                children: <Widget>[
                                  Text('日'),
                                  Text('月'),
                                  Text('火'),
                                  Text('水'),
                                  Text('木'),
                                  Text('金'),
                                  Text('土')
                                ],
                                onPressed: (int index) {
                                  setState(() {
                                    isSelected[index] = !isSelected[index];
                                  });
                                },
                                isSelected: isSelected,
                                textStyle: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                            ),
                            widthSpacer(width: size.width / 10),
                            heightSpacer(height: size.height * 0.025),
                          ],
                        ),
                      ),

                      //バイブ
                      Container(
                        decoration: borderLine,
                        child: SizedBox(
                          child: SwitchListTile(
                            value: vibration,
                            title: Text(
                              'バイブレーション',
                              style: itemName,
                            ),
                            onChanged: (bool value) {
                              setState(() {
                                vibration = value;
                              });
                            },
                          ),
                        ),
                      ),

                      //QRコードモード
                      Container(
                        decoration: borderLine,
                        child: SizedBox(
                          child: SwitchListTile(
                            value: qrCodeMode,
                            title: Text(
                              'QRコードモード',
                              style: itemName,
                            ),
                            onChanged: (bool value) {
                              setState(() {
                                qrCodeMode = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ]),

                //ボタン
                Container(
                  //decoration: borderLine,
                  child: SizedBox(
                    child: Column(
                      children: <Widget>[
                        heightSpacer(height: size.height * 0.025),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            RaisedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('Cancel',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700)),
                            ),
                            widthSpacer(width: size.width * 0.25),
                            RaisedButton(
                              onPressed: () {
                                createAlarmButton();
                              },
                              child: Text(
                                'OK',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        heightSpacer(height: size.height * 0.025),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> selectTime(BuildContext context) async {
    final TimeOfDay t =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if (t != null) {
      setState(() {
        setTime = t;
      });
    }
  }

  void createAlarmButton() {
    //Alarmの設定
    List<int> list = [];
    for (int i = 0; i < isSelected.length; i++) {
      if (isSelected[i] == true) {
        //DateTimeの曜日が月曜の1から始まり、日曜の7で終わる
        //登録画面では日曜始まりなので後の通知処理の為ここで修正しておく
        if (i == 0) {
          list.add(7);
        } else {
          list.add(i);
        }
      }
    }
    if (list.length > 0) list.sort();
    DateTime now = DateTime.now();
    String nowTime = '${now.hour}${now.minute}${now.microsecond}';
    String text = "アラーム";
    if (textCtrl.text != null && textCtrl.text.length > 0) {
      text = textCtrl.text.toString();
    }
    setState(() {
      alarm = new Alarm(
        id: alarmList.length,
        alarmId: int.parse(nowTime),
        time: setTime,
        description: text,
        repeat: list,
        vibration: vibration,
        qrCodeMode: qrCodeMode,
        stopSnooze: false,
      );
      if (list.length > 0) {
        setAlarmWeeklySchedule(alarm);
        print('setWeekAlarm');
      } else {
        setAlarmOnceSchedule(alarm);
        print('setAlarm');
      }
      addAlarm(alarm);
      saveAlarmData(alarmList);
    });
    Navigator.of(context).pop('savefin');
  }
}

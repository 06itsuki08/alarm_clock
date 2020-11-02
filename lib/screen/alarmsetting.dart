import 'package:alarm_clock/module/alarm_list.dart';
import 'package:alarm_clock/module/move_alarm.dart';
import 'package:alarm_clock/module/shared_prefs.dart';
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
      //body アプリのメイン画面
      //Column 子供になるパーツが全部縦に並んでくれる　子供はchildren にいれる
      body: SingleChildScrollView(
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
                      height: MediaQuery.of(context).size.height / 4,
                      child: Column(children: <Widget>[
                        SizedBox(height: 10),
                        Text(
                          '${setTime.hour.toString().padLeft(2, '0')}:${setTime.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(fontSize: 80),
                        ),
                        SizedBox(height: 5),
                        RaisedButton(
                            onPressed: () => selectTime(context),
                            child: new Text(
                              '時間選択',
                              style: TextStyle(fontSize: 30),
                            )),
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                width: size.width * 0.8,
                                child: Text(
                                  '説明',
                                  style: itemName,
                                ),
                              ),
                            ],
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(
                                  width: size.width * 0.8,
                                  child: TextField(
                                    enabled: true,
                                    controller: textCtrl,
                                  ),
                                ),
                              ]),
                          heightSpacer(height: size.height * 0.025),
                        ],
                      ),
                    ),
                  ),

                  //音 は一時的に未実装
                  /*
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(child: Text('音')),
                RaisedButton(
                    onPressed: () => selectFile(), child: new Text('サウンドを選択')),
                //filePicker?
              ],
            ),
            */

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
                            ],
                          ),
                        ),
                        heightSpacer(height: size.height * 0.025),
                        SizedBox(
                          child: ToggleButtons(
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
                                  fontSize: 16, fontWeight: FontWeight.w700)),
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

/* ファイルパス取得
 Future<void> selectFile() async {
    FilePickerResult result = await FilePicker.platform.pickFiles();
    //todo 例外のcatch処理
    if (result != null) {
      filePath = result.files.single.path;
    }
  }
*/

  void createAlarmButton() {
    //Alarmの設定
    List<int> list = [];
    for (int i = 0; i < isSelected.length; i++) {
      if (isSelected[i] == true) {
        list.add(i);
      }
    }
    DateTime now = DateTime.now();
    String nowTime = '${now.hour}${now.minute}${now.microsecond}';
    setState(() {
      alarm = new Alarm(
          id: alarmList.length,
          alarmId: int.parse(nowTime),
          time: setTime,
          description: textCtrl.text.toString(),
          repeat: list,
          vibration: vibration,
          qrCodeMode: qrCodeMode);
      if (list.length >= 1) {
        setAlarmWeeklySchedule(alarm);
      } else {
        setAlarmFirstSchedule(alarm);
      }
      addAlarm(alarm);
      saveData(alarmList);
    });
    Navigator.of(context).pop('savefin');
  }
}

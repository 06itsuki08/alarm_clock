import 'dart:async';

import 'package:alarm_clock/module/move_alarm.dart';
import 'package:alarm_clock/module/quiz.dart';
import 'package:alarm_clock/module/shared_prefs.dart';
import 'package:alarm_clock/module/user_setting.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:alarm_clock/val/string.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class Setting extends StatefulWidget {
  Setting({Key key}) : super(key: key);
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  double value = 0.0;
  List<bool> isSelected = [];
  bool quizChecker;

  @override
  void initState() {
    super.initState();
    value = appSetting.volume;
    quizChecker = true;
    //クイズの選択を読み込み
    for (int i = 0; i < quizList.length; i++) {
      isSelected.add(appSetting.useQuiz[i]);
    }
    //クイズがどれも選択されてなかったら成りたたないので無理や乱数足し算をオンにしておく
    int checkedQuizOn = checkQuizCheckBox();
    if (checkedQuizOn < 1) {
      isSelected[0] = true;
    }
  }

  @override
  void dispose() {
    stopRingAlarm();
    super.dispose();
  }

  checkQuizCheckBox() {
    int flg = 0;
    isSelected.forEach((element) {
      if (element) {
        flg++;
      }
    });
    return flg;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //AppBarはアプリのタイトルとかを表示してくれる領域のこと
      appBar: AppBar(
        title: Text(setting),
      ),
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              heightSpacer(height: size.height * 0.1),
              Text('アラームの音量',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Slider(
                label: '$value',
                value: value,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                inactiveColor: Colors.white,
                activeColor: Colors.amber,
                onChanged: (e) {
                  setState(() {
                    value = e;
                    changeVolume(e);
                  });
                },
              ),
              heightSpacer(height: size.height * 0.05),
              SizedBox(
                width: size.width * 0.6,
                height: size.height * 0.07,
                child: RaisedButton(
                  onPressed: () => startRingAlarm(),
                  child: Text(
                    'サウンドテスト',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
              ),
              heightSpacer(height: size.height * 0.05),
              SizedBox(
                width: size.width * 0.6,
                height: size.height * 0.07,
                child: RaisedButton(
                  onPressed: () => stopRingAlarm(),
                  child: Text('サウンドテスト終了',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                ),
              ),
              heightSpacer(height: size.height * 0.05),
              Text('スヌーズ解除時のクイズの種類',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              if (quizChecker == false)
                Text('クイズは1つ以上ONにしてください',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red)),
              buildQuizCheckBox(),
            ],
          ),
        ),
      ),
    );
  }

  changeVolume(double e) {
    setState(() {
      appSetting.volume = e;
    });

    deleteSettingData();
    saveSettingData(appSetting);

    FlutterRingtonePlayer.playAlarm(
        looping: true, asAlarm: true, volume: appSetting.volume);
    Timer(const Duration(seconds: 5), () {
      FlutterRingtonePlayer.stop();
    });

    /*
      */
  }

  buildQuizCheckBox() {
    return Column(
      children: [
        for (int i = 0; i < quizList.length; i++)
          SizedBox(
            height: size.height * 0.1,
            child: CheckboxListTile(
                activeColor: Colors.amber,
                checkColor: Colors.white,
                title: Text(
                  '${quizList[i]}',
                  style: TextStyle(fontSize: 20),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                value: isSelected[i],
                onChanged: (bool value) async {
                  isSelected[i] = value;

                  int flg = await checkQuizCheckBox();
                  setState(
                    () {
                      //2つ以上オンならオフにしてもOK
                      if (flg >= 1) {
                        appSetting.useQuiz[i] = isSelected[i];
                        deleteSettingData();
                        saveSettingData(appSetting);
                        quizChecker = true;
                      } //1つしかオンじゃなければオフにさせない
                      else {
                        isSelected[i] = !value;
                        quizChecker = false;
                      }
                    },
                  );
                }),
          ),
      ],
    );
  }
}

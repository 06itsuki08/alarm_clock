import 'dart:async';

import 'package:alarm_clock/module/move_alarm.dart';
import 'package:alarm_clock/module/quiz.dart';
import 'package:alarm_clock/module/user_setting.dart';
import 'package:alarm_clock/val/string.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class SnoozeStop extends StatefulWidget {
  @override
  _SnoozeStopState createState() => _SnoozeStopState();
}

class _SnoozeStopState extends State<SnoozeStop> {
  bool quizMistake; //クイズを間違えたか
  bool quizStart;
  TextEditingController controller;
  //int quizClearCount;
  bool quizClear;
  Timer quizTimer;
  int _second;
  String quizStartText;

  @override
  void initState() {
    super.initState();
    quizMistake = false;
    controller = TextEditingController();
    //quizClearCount = 0;
    quizClear = false;
    quizStart = false;
    _second = 15;
    quizStartText = 'クイズが開始されます。\n${_second}秒経過するか間違えた回答をすると別の問題に切り替わります。';
    //表示バグで問題が出ないときがあるので複数問題をいったん除外
    //\n問題は全部で${appSetting.quizClearCount}問
  }

  @override
  void dispose() {
    quizTimer.cancel();
    countTimer().cancel();
    super.dispose();
  }

  Timer countTimer() {
    return Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        if (_second < 1) {
          timer.cancel();
          setState(() {});
        } else {
          _second = _second - 1;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(snoozestop),
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
            child: switchStopSnoozePage()));
  }

  switchStopSnoozePage() {
    if (quizStart == false) {
      return buildQuizStart();
    } else if (quizStart && !quizClear) {
      //} else if (quizStart && quizClearCount < appSetting.quizClearCount) {
      //クイズ画面
      _second = 15;
      quizTimer = countTimer();
      return randomQuizSelect();
      //} else if (quizClearCount == appSetting.quizClearCount) {
    } else if (quizClear) {
      //スヌーズ解除完了画面
      quizTimer.cancel();
      countTimer().cancel();
      return quizClearScreen();
    }
  }

  buildQuizStart() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        heightSpacer(height: size.height * 0.1),
        Container(
          width: size.width,
          child: Text(
            '$quizStartText',
            style: TextStyle(fontSize: 20),
            softWrap: true,
          ),
        ),
        heightSpacer(height: size.height * 0.1),
        RaisedButton(
          onPressed: () {
            setState(() {
              quizStart = true;
            });
          },
          child: Text(
            'スタート',
            style: TextStyle(fontSize: 20),
          ),
        )
      ],
    );
  }

  //クイズ画面

  randomQuizSelect() {
    int selectedQuiz = 0;
    var random;
    List<int> randomNum;
    Map<String, Color> randomColor;
    String ranString;

    random = new math.Random();
    selectedQuiz = random.nextInt(quizType);
    //乱数で選択された問題が設定画面でオンにされているか。違ったら乱数再生成
    while (appSetting.useQuiz[selectedQuiz] != true) {
      selectedQuiz = random.nextInt(quizType);
    }

    switch (selectedQuiz) {
      case 0:
        randomNum = randomNumAdd(quizAnserNum);

        return buildRandomNumAdd(randomNum);
        break;
      case 1:
        randomColor = randomColorSelsect(quizAnserNum);
        Color trueColor;
        var values = randomColor.keys.toList();
        var element = values[random.nextInt(values.length)];
        trueColor = randomColor['$element'];
        return buildRandomColorSelect(randomColor, trueColor);
        break;
      case 2:
        ranString = randomString(5);
        return buildRandomString(ranString);
        break;
      default:
        print('問題生成エラーが発生しました');
        break;
    }
  }

  //クイズ正解後スヌーズ解除画面
  quizClearScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        heightSpacer(height: size.height * 0.1),
        Text(
          '問題に正解しました！\n下のボタンからスヌーズ解除が出来ます',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        heightSpacer(height: size.height * 0.3),
        //Test用
        SizedBox(
            height: size.height * 0.1,
            width: size.width / 2,
            child: RaisedButton(
              onPressed: () async {
                await stopAlarm10minSnooze();
                setState(() {
                  Navigator.pushNamedAndRemoveUntil(context, "/", (_) => false);
                });
              },
              child: Text(
                'Snooze解除',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            )),
      ],
    );
  }

//乱数の足し算の画面
  buildRandomNumAdd(List<int> randomNumQuiz) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        /*
        //残り問題数表示
        Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'あと${(appSetting.quizClearCount - quizClearCount)}問',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              widthSpacer(width: size.width * 0.1),
            ]),
            */
        heightSpacer(height: size.height * 0.05),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            widthSpacer(width: size.width * 0.05),
            Expanded(
              child: Text(
                'Q.$quizAnserNum つの乱数の足し算',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
              '${randomNumQuiz[0]}＋${randomNumQuiz[1]}＋${randomNumQuiz[2]}＋${randomNumQuiz[3]}＋${randomNumQuiz[4]}＝？',
              style: TextStyle(fontSize: 30),
            ),
          ],
        ),
        heightSpacer(height: size.height * 0.05),
        if (quizMistake)
          Text(
            '不正解',
            style: TextStyle(color: Colors.red, fontSize: 18),
          ),
        SizedBox(
          width: size.width * 0.2,
          child: TextField(
            enabled: true,
            controller: controller,
            cursorColor: Colors.amber,
            keyboardType: TextInputType.number,
            maxLines: 1,
          ),
        ),
        heightSpacer(height: size.height * 0.05),
        RaisedButton(
          onPressed: () {
            if (int.parse(controller.text) == randomNumQuiz[quizAnserNum]) {
              setState(() {
                quizTimer.cancel();
                quizClear = true;
                //quizClearCount += 1;
                quizMistake = false;
              });
            } else {
              setState(() {
                quizMistake = true;
              });
            }
          },
          child: Text('答え合わせ'),
        ),
      ],
    );
  }

  buildRandomColorSelect(
    Map<String, Color> randomcolor,
    Color trueColor,
  ) {
    List<String> randomColorName = randomcolor.keys.toList();
    List<Color> randomColor = randomcolor.values.toList();
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          heightSpacer(height: size.height * 0.05),
          /*
          Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('あと${(appSetting.quizClearCount - quizClearCount)}問',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    )),
                widthSpacer(width: size.width * 0.1),
              ]),
              */
          heightSpacer(height: size.height * 0.05),
          Text(
            'Q.下の四角形の色を答えてください',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          heightSpacer(height: size.height * 0.05),
          //色の枠
          SizedBox(
            width: 100,
            height: 100,
            child: Container(
              decoration: BoxDecoration(color: trueColor),
            ),
          ),
          heightSpacer(height: size.height * 0.05),
          if (quizMistake)
            Text(
              '不正解',
              style: TextStyle(color: Colors.red, fontSize: 18),
            ),
          for (int i = 0; i < randomcolor.length; i++)
            SizedBox(
              width: size.width * 0.5,
              child: RaisedButton(
                onPressed: () {
                  if (randomColor[i] == trueColor) {
                    setState(() {
                      quizTimer.cancel();
                      //quizClearCount += 1;
                      quizClear = true;
                      quizMistake = false;
                    });
                  } else {
                    setState(() {
                      quizMistake = true;
                    });
                  }
                },
                child: Text('${randomColorName[i]}',
                    style: TextStyle(fontSize: 20)),
              ),
            ),
        ]);
  }

  //ランダム文字列
  buildRandomString(String randomString) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        heightSpacer(height: size.height * 0.1),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              widthSpacer(width: size.width * 0.05),
              Expanded(
                child: Text(
                  'Q.下に表示されている文字列と同じものを入力して下さい',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              widthSpacer(width: size.width * 0.05),
            ]),
        heightSpacer(height: size.height * 0.1),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '$randomString',
              style: TextStyle(fontSize: 30),
            ),
          ],
        ),
        heightSpacer(height: size.height * 0.05),
        if (quizMistake)
          Text(
            '不正解',
            style: TextStyle(color: Colors.red, fontSize: 18),
          ),
        SizedBox(
          width: size.width * 0.2,
          child: TextField(
            enabled: true,
            controller: controller,
            cursorColor: Colors.amber,
            keyboardType: TextInputType.number,
            maxLines: 1,
          ),
        ),
        heightSpacer(height: size.height * 0.05),
        RaisedButton(
          onPressed: () {
            if (controller.text == randomString) {
              setState(() {
                quizTimer.cancel();
                quizClear = true;
                //quizClearCount += 1;
                quizMistake = false;
              });
            } else {
              setState(() {
                quizMistake = true;
              });
            }
          },
          child: Text('答え合わせ'),
        ),
      ],
    );
  }
}

import 'package:alarm_clock/module/move_alarm.dart';
import 'package:alarm_clock/module/quiz.dart';
import 'package:alarm_clock/val/string.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class SnoozeStop extends StatefulWidget {
  @override
  _SnoozeStopState createState() => _SnoozeStopState();
}

class _SnoozeStopState extends State<SnoozeStop> {
  bool quizMistake; //クイズを間違えたか
  bool quizClear; //クイズが正解したか
  TextEditingController controller;

  @override
  void initState() {
    super.initState();
    quizClear = false;
    quizMistake = false;
    controller = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
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
    if (quizClear == false) {
      //クイズ画面
      print('call build quizScreen');
      return randomQuizSelect();
    } else if (quizClear) {
      //スヌーズ解除完了画面
      return quizClearScreen();
    }
  }

  //クイズ画面

  randomQuizSelect() {
    var random = new math.Random();
    int selectedQuiz = random.nextInt(quizType);

    switch (selectedQuiz) {
      case 0:
        List<int> randomNum = randomNumAdd(quizAnserNum);
        return buildRandomNumAdd(randomNum);
        break;
      case 1:
        Map<String, Color> randomColor = randomColorSelsect(quizAnserNum);
        Color trueColor;
        var values = randomColor.keys.toList();
        var element = values[random.nextInt(values.length)];
        trueColor = randomColor['$element'];
        return buildRandomColorSelect(randomColor, trueColor);
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
            if (int.parse(controller.text) == randomNumQuiz[5]) {
              setState(() {
                quizClear = true;
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
          heightSpacer(height: size.height * 0.1),
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
                      quizClear = true;
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
}

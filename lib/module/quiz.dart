import 'dart:math' as math;

import 'package:alarm_clock/val/color.dart';
import 'package:alarm_clock/val/string.dart';
import 'package:flutter/material.dart';

//memo randomの範囲
//int next(int min, int max) => min + _random.nextInt(max - min);

int quizType = 4; //クイズの種類の数

int quizAnserNum = 5; //クイズの選択の数
List<String> quizList = ['乱数足し算', 'ランダムカラー', 'ランダム文字列', '画像内の数'];

//1~10の乱数の足し算　maxnum=>乱数の数
List<int> randomNumAdd(int maxnum) {
  List<int> nums = new List<int>();
  int add = 0;
  var random = new math.Random();
  for (int i = 0; i < maxnum; i++) {
    //todo 1~10に変える
    int l = 1 + random.nextInt(10 - 1);
    nums.add(l);
    add += l;
  }
  nums.add(add);
  return nums;
}

final List<Color> colorList = <Color>[
  Colors.pink[500],
  Colors.red[500],
  Colors.deepOrange[500],
  Colors.orange[500],
  Colors.amber[500],
  Colors.yellow[500],
  Colors.lime[500],
  Colors.lightGreen[500],
  Colors.green[500],
  Colors.teal[500],
  Colors.cyan[500],
  Colors.lightBlue[500],
  Colors.blue[500],
  Colors.indigo[500],
  Colors.purple[500],
  Colors.deepPurple[500],
  Colors.blueGrey[500],
  Colors.brown[500],
  Colors.grey[500],
];

List<String> colorNameList = [
  'Pink',
  'Red',
  'DeepOrange',
  'Orange',
  'Amber',
  'Yellow',
  'Lime',
  'LightGreen',
  'Green',
  'Teal',
  'Cyan',
  'LightBlue',
  'Blue',
  'Indigo',
  'Purple',
  'DeepPurple',
  'BlueGrey',
  'Brown',
  'Grey'
];

// RandomColor
randomColorSelsect(int colorNum) {
  print('----------------ランダムカラー作成--------------');
  var random = new math.Random();
  Map<String, Color> randomColors = {};
  List<int> selectedInt = [];

  int selectedColorId;
  //既にリストにあるのと同じ色が追加されていないかチェック
  for (int l = 0; l < colorNum; l++) {
    selectedColorId = random.nextInt(colorList.length);
    print('乱数：$selectedColorId');
    for (int m = 0; m < selectedInt.length; m++) {
      if (selectedInt[m] == selectedColorId) {
        selectedColorId = random.nextInt(colorList.length);
        //再生成した乱数がちゃんと被っていないか始めからチェックする
        //なぜか再生成後に最初からのチェックが入らず問題の選択数が減る
        m = 0;
        print('再生成乱数：$selectedColorId');
      }
    }
    print('追加：$selectedColorId');
    selectedInt.add(selectedColorId);
  }
  //生成した乱数のリストを使用してランダムな色を選択する
  selectedInt.forEach((element) {
    randomColors[colorNameList[element]] = colorList[element];
  });
  print('----------------ランダムカラー作成終了--------------');
  return randomColors;
}

// RandomString
String randomChar =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890';
int randomCharlength = randomChar.length;
String randomString(int length) {
  var random = new math.Random();
  String generatedString = '';
  for (int i = 0; i < length; i++) {
    int l = random.nextInt(randomCharlength);
    generatedString += randomChar[l];
  }
  return generatedString;
}

// ImageQuiz
List<String> imageObjectName = [
  'りんご',
  'バナナ',
  'ぶどう',
  'もも',
  'みかん',
  '英単語',
  'ひらがな',
  '英字',
  'いらすと',
  '果物の種類'
];
List<int> imageObjectNum = [1, 2, 1, 3, 1, 2, 3, 14, 2, 5];

Map<String, List<int>> randomImage(int objectNum) {
  var random = new math.Random();
  List<int> ansInt = [];
  String ansString;
  int ran = random.nextInt(imageObjectName.length);
  ansString = imageObjectName[ran];
  ansInt.add(imageObjectNum[ran]);
  for (int i = 0; i < objectNum - 1; i++) {
    ran = random.nextInt(imageObjectName.length);
    ansInt.add(imageObjectNum[ran]);
  }
  Map<String, List<int>> imageObjectAnser = {ansString: ansInt};
  return imageObjectAnser;
}

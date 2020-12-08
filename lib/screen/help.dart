import 'dart:async';
import 'dart:io';

import 'package:alarm_clock/module/alarm.dart';
import 'package:alarm_clock/module/alarm_list.dart';
import 'package:alarm_clock/screen/alarmsetting.dart';
import 'package:alarm_clock/screen/alarmstop.dart';
import 'package:alarm_clock/val/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:alarm_clock/val/string.dart';
import 'package:alarm_clock/module/shared_prefs.dart';
import 'package:alarm_clock/module/move_alarm.dart';

class Help extends StatefulWidget {
  Help({Key key}) : super(key: key);
  @override
  _HelpState createState() => _HelpState();
}

class _HelpState extends State<Help> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'ヘルプ',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w800, fontSize: 25),
          ),
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
            child: SingleChildScrollView(
                child: Column(
              children: <Widget>[
                HelpHome(),
              ],
            ))));
  }
}

//ホーム画面のヘルプ
class HelpHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        heightSpacer(height: size.height * 0.05),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
          ),
          child: Padding(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Text(
                '各種ボタンの説明',
                style: TextStyle(
                  fontSize: 20,
                ),
              )),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.alarm_add,
                        size: 25,
                      ),
                      Text('：アラームの新規追加画面に移動します。',
                          style: TextStyle(
                            fontSize: 16,
                          )),
                    ],
                  ),
                  heightSpacer(height: size.height * 0.025),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.settings,
                        size: 25,
                      ),
                      Text('：設定画面やヘルプ画面に移動します。',
                          style: TextStyle(
                            fontSize: 16,
                          )),
                    ],
                  ),
                  heightSpacer(height: size.height * 0.025),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('アラームを長押しすると削除することができます。',
                          style: TextStyle(
                            fontSize: 16,
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Text(
              'アラームに関する各種アイコンの説明',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
        ),
        Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                ),
                child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Column(children: [
                      Text('振動の有無',
                          style: TextStyle(
                            fontSize: 18,
                          )),
                      heightSpacer(height: size.height * 0.02),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off,
                            size: 25,
                          ),
                          Text('：振動あり',
                              style: TextStyle(
                                fontSize: 16,
                              )),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_active,
                            size: 25,
                          ),
                          Text('：振動なし',
                              style: TextStyle(
                                fontSize: 16,
                              )),
                        ],
                      ),
                    ])))),
        Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                ),
                child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Column(children: [
                      Text('QRコードによる停止機能',
                          style: TextStyle(
                            fontSize: 18,
                          )),
                      heightSpacer(height: size.height * 0.01),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_active,
                            size: 25,
                          ),
                          Text('：QRコードによる停止機能ON',
                              style: TextStyle(
                                fontSize: 16,
                              )),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.block,
                            size: 25,
                          ),
                          Text('：QRコードによる停止機能OFF',
                              style: TextStyle(
                                fontSize: 16,
                              )),
                        ],
                      ),
                    ])))),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Text(
              'クレジット',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
        ),
        Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                ),
                child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Column(children: [
                      Text(
                        '製作',
                        style: TextStyle(fontSize: 20),
                      ),
                      Text('猫の会', style: TextStyle(fontSize: 18)),
                      Text('岩尾 実柚紀 志和 樹 櫻井 千晶',
                          style: TextStyle(
                            fontSize: 16,
                          )),
                      heightSpacer(height: size.height * 0.01),
                      Text(
                        'フォント',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      Text(
                          'MPLUSRounded1c\nきろ字(kilo)\nRounded-X Mgen+ 1c black\n游ゴシック Regular',
                          style: TextStyle(
                            fontSize: 16,
                          )),
                      heightSpacer(height: size.height * 0.01),
                      Text(
                        'クイズイラスト',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      Text('いらすとや',
                          style: TextStyle(
                            fontSize: 16,
                          )),
                    ]))))
      ],
    );
  }
}

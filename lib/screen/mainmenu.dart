import 'dart:async';
import 'dart:io';

import 'package:alarm_clock/module/alarm.dart';
import 'package:alarm_clock/module/alarm_list.dart';
import 'package:alarm_clock/module/url_launcher.dart';
import 'package:alarm_clock/screen/alarmsetting.dart';
import 'package:alarm_clock/screen/alarmstop.dart';
import 'package:alarm_clock/val/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:alarm_clock/val/string.dart';
import 'package:alarm_clock/module/shared_prefs.dart';
import 'package:alarm_clock/module/move_alarm.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class MainMenu extends StatefulWidget {
  MainMenu({Key key}) : super(key: key);
  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  //画面描画の前、最初に動作するとこ初期化とかここでおこなったりする
  @override
  void initState() {
    if (moveAlarm != true) moveAlarm = false;
    if (alarmedId == null) alarmedId = 0;

    if (alarmList != null) alarmList.clear();
    loadAlarmData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      //AppBarはアプリのタイトルとかを表示してくれる領域のこと
      appBar: AppBar(
        title: AutoSizeText(
          title,
          maxFontSize: 30,
          maxLines: 1,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: <Widget>[
          //アイコンをそのままボタンにしてくれるWidget
          //アイコン一覧は↓
          //https://api.flutter.dev/flutter/material/Icons-class.html
          IconButton(
            icon: Icon(Icons.alarm_add),
            iconSize: 35,
            color: Colors.white,
            //onPressed そのまんま押された時の動作を宣言するとこ
            //setState 値を変更して画面を更新するよみたいな感じ
            //画面の更新をかけないと表示上の数値は変わらない
            onPressed: () async {
              Navigator.push(
                context,
                new MaterialPageRoute(builder: (context) => new AlarmSetting()),
              ).then(onGoBack);
            }, //
          ),
          PopupMenuButton<int>(
            color: Colors.white.withOpacity(0.9),
            icon: Icon(
              Icons.settings,
              color: Colors.white,
              size: 35,
            ),
            onSelected: (int i) {
              switch (i) {
                //設定ボタン
                case 0:
                  Navigator.pushNamed(context, '/setting');
                  break;
                case 1:
                  launchURL(
                      'https://sites.google.com/gn.iwasaki.ac.jp/nekonokai/%E3%83%80%E3%82%A6%E3%83%B3%E3%83%AD%E3%83%BC%E3%83%89?authuser=0');
                  break;
                //ヘルプボタン
                case 2:
                  Navigator.pushNamed(context, '/help');
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              PopupMenuItem(
                value: 0,
                child: Text(
                  '設定',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              PopupMenuItem(
                value: 1,
                child: Text('QRコードの入手', style: TextStyle(fontSize: 20)),
              ),
              PopupMenuItem(
                value: 2,
                child: Text('ヘルプ', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ],
      ),
      //body アプリのメイン画面
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
          child: FutureBuilder(
              //端末に保存したアラームリストを取得する
              future: loadAlarmData(needReturn: true),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                //アラームリストが取得できた場合
                //まだ何も保存されていなくても空っぽのアラームリストが返ってきている
                if (snapshot.hasData) {
                  return alarmList.length > 0
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            /*クイズ検証用ショトカ下のボタンをコメントアウトから戻してね
                            RaisedButton(
                              child: Text('QuizTest'),
                              onPressed: () {
                                Navigator.pushNamed(context, '/snoozestop');
                              },
                            ), */
                            heightSpacer(height: size.height * 0.01),
                            Container(
                              color: Colors.white.withOpacity(0.5),
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                child: AutoSizeText(
                                  'アラーム登録数：${alarmList.length}',
                                  style: TextStyle(
                                    fontFamily: 'MPLUSRounded',
                                  ),
                                  minFontSize: 30,
                                ),
                              ),
                            ),
                            heightSpacer(height: size.height * 0.01),

                            //アラームのリストを表示する。
                            //表示させるリストの項目は'alarmlist.dart'にある'buildListItem'にある
                            ListView.builder(
                                shrinkWrap: true,
                                reverse: true,
                                physics: ScrollPhysics(),
                                itemCount: alarmList.length,
                                scrollDirection: Axis.vertical,
                                itemBuilder: (BuildContext context, int i) {
                                  return GestureDetector(
                                    child: buildListItem(alarmList[i]),
                                    //アラームの削除は、リスト項目を長押しすると出る
                                    onLongPress: () {
                                      deleteAlarmMode(alarmList[i]);
                                    },
                                  );
                                })
                          ],
                        )
                      : Center(
                          child: Card(
                            //カード間を周囲10ポイント？空ける
                            margin: const EdgeInsets.fromLTRB(10, 20.0, 10, 10),
                            //標高ってでてきたけど完全透明(color:Colors.transナンチャラ)にする際はこれが必要らしい
                            elevation: 0,
                            //カードの背景色を白かつ透明度を0.85にする
                            color: Colors.white.withOpacity(0.85),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AutoSizeText(
                                    'アラーム未登録',
                                    style: TextStyle(fontSize: 40),
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      AutoSizeText(
                                        '上の',
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      Icon(Icons.alarm_add),
                                      AutoSizeText(
                                        'からアラームを追加',
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                } else {
                  //取得失敗した場合
                  return AutoSizeText("同期失敗");
                }
              }),
        ),
      ),
    );
  }

  FutureOr onGoBack(dynamic value) {
    setState(() {
      relodeAlarmList();
    });
  }

  deleteAlarmMode(Alarm alarm) async {
    Text title = Text(alartConfirmation);
    Text content = Text(alartDeleteAlarm);
    Text _cancel = Text(cancel);
    Text _delete = Text(delete);
    await showDialog(
        context: context,
        builder: (_) {
          if (Platform.isIOS) {
            return CupertinoAlertDialog(
              title: title,
              content: content,
              actions: <Widget>[
                CupertinoDialogAction(
                  child: _cancel,
                  onPressed: () => Navigator.pop(context),
                ),
                CupertinoDialogAction(
                  child: _delete,
                  isDestructiveAction: true,
                  onPressed: () {
                    deleteAlarm(alarm);
                    Navigator.of(context).pop();
                    setState(() {});
                  },
                ),
              ],
            );
          } else {
            return AlertDialog(
              title: title,
              content: content,
              actions: <Widget>[
                FlatButton(
                  child: _cancel,
                  onPressed: () => Navigator.pop(context),
                ),
                FlatButton(
                  child: _delete,
                  onPressed: () {
                    deleteAlarm(alarm);
                    Navigator.of(context).pop();
                    setState(() {});
                  },
                ),
              ],
            );
          }
        });
  }
}

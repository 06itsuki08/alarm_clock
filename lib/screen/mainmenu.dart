import 'dart:async';

import 'package:alarm_clock/module/alarm.dart';
import 'package:alarm_clock/module/alarm_list.dart';
import 'package:alarm_clock/screen/alarmsetting.dart';
import 'package:flutter/material.dart';
import 'package:alarm_clock/val/string.dart';
import 'package:alarm_clock/module/shared_prefs.dart';

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
    setState(() {
      if (alarmList != null) alarmList.clear();
      loadData();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      //AppBarはアプリのタイトルとかを表示してくれる領域のこと
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          //アイコンをそのままボタンにしてくれるWidget
          //アイコン一覧は↓
          //https://api.flutter.dev/flutter/material/Icons-class.html
          IconButton(
            icon: Icon(Icons.alarm_add),
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
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/setting');
            },
          )
        ],
      ),
      //body アプリのメイン画面
      //Column 子供になるパーツが全部縦に並んでくれる　子供はchildren にいれる
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            heightSpacer(height: size.height * 0.01),
            Text('アラーム登録数：${alarmList.length}'),
            alarmList.length > 0
                ? ListView.builder(
                    shrinkWrap: true,
                    reverse: true,
                    physics: ScrollPhysics(),
                    itemCount: alarmList.length,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (BuildContext context, int i) {
                      return buildListItem(alarmList[i]);
                    })
                : Center(child: Card(child: Text('アラーム未登録')))
          ],
        ),
      ),
    );
  }

  FutureOr onGoBack(dynamic value) {
    setState(() {
      loadData();
    });
  }

  void removeAlarm(Alarm alarm) async {
    setState(() {
      alarmList.remove(alarm);
      saveData(alarmList);
    });
  }
}

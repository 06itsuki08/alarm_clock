import 'package:alarm_clock/module/alarm.dart';
import 'package:alarm_clock/module/alarm_list.dart';
import 'package:alarm_clock/screen/alarmsetting.dart';
import 'package:flutter/material.dart';
import 'package:alarm_clock/val/string.dart';
import 'package:alarm_clock/module/shared_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    super.initState();
    setState(() {
      alarmList = List<Alarm>();
      loadData(alarmList);
    });
  }

  @override
  void dispose() {
    super.dispose();
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
              Navigator.pushNamed(context, '/alarmsetting');
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text('アラーム登録数：${alarmList.length}'),
          ListView.builder(
              shrinkWrap: true,
              itemCount: alarmList.length,
              scrollDirection: Axis.vertical,
              itemBuilder: (BuildContext context, int i) {
                if (alarmList.length <= 0) {
                  return Card(
                    child: Text('アラーム未登録'),
                  );
                } else {
                  return buildListItem(alarmList[i]);
                }
              })
        ],
      ),
    );
  }

  void removeAlarm(Alarm alarm) async {
    setState(() {
      alarmList.remove(alarm);
      saveData(alarmList);
    });
  }
}

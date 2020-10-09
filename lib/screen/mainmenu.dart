import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:alarm_clock/val/string.dart';

class MainMenu extends StatefulWidget {
  MainMenu({Key key}) : super(key: key);
  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  String text = 'ホーム画面';
  String yotei = 'ListViewを置いて、設定済みのアラームを表示する';
  @override
  Widget build(BuildContext context) {
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
            onPressed: () {
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
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(text),
          Text(yotei),
        ],
      ),
    );
  }
}

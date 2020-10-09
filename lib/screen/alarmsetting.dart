import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:alarm_clock/val/string.dart';
import 'package:file_picker/file_picker.dart';

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
  String filePath;
  TextEditingController textCtrl;
  Size size;
  List<String> checkRepeat = ['日', '月', '火', '水', '木', '金', '土'];
  List<bool> isSelected = [false, false, false, false, false, false, false];

  @override
  void initState() {
    super.initState();
    setTime = TimeOfDay.now();
    filePath = '';
    vibration = false;
    textCtrl = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      //AppBarはアプリのタイトルとかを表示してくれる領域のこと
      appBar: AppBar(
        title: Text(alarmSetting),
      ),
      //body アプリのメイン画面
      //Column 子供になるパーツが全部縦に並んでくれる　子供はchildren にいれる
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
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
                    heightSpacer(),
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
                  SizedBox(
                    height: size.height / 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        widthSpacer(width: size.width / 10),
                        Text(
                          "くり返し",
                          style: itemName,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    child: ToggleButtons(
                      children: <Widget>[
                        Icon(Icons.vibration),
                        Icon(Icons.android),
                        Icon(Icons.apps),
                        Icon(Icons.archive),
                        Icon(Icons.error),
                        Icon(Icons.mail),
                        Icon(Icons.save)
                      ],
                      onPressed: (int index) {
                        setState(() {
                          isSelected[index] = !isSelected[index];
                        });
                      },
                      isSelected: isSelected,
                    ),
                  ),
                  widthSpacer(width: size.width / 10),
                  heightSpacer(),
                ],
              ),
            ),

            //バイブ
            Container(
              decoration: borderLine,
              child: SizedBox(
                height: size.height / 10,
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

  Future<void> selectFile() async {
    FilePickerResult result = await FilePicker.platform.pickFiles();
    //todo 例外のcatch処理
    if (result != null) {
      filePath = result.files.single.path;
    }
  }

  void createAlarm() {
    //Alarmの設定
  }
}

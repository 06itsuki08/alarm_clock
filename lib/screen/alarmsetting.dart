import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:alarm_clock/val/string.dart';
import 'package:file_picker/file_picker.dart';


class AlarmSetting extends StatefulWidget{

  AlarmSetting({Key key}):super(key:key);
  @override
  _AlarmSettingState createState()=>_AlarmSettingState();
}

class _AlarmSettingState extends State<AlarmSetting>{
  String text='アラーム設定画面';
  String yotei='アラーム設定項目';
  TimeOfDay setTime;
  bool vibration;
  String filePath;

  @override
  void initState() {
    super.initState();
    setTime=TimeOfDay.now();
    filePath='';
    vibration=false;
  }


  @override
  Widget build(BuildContext context){
    return Scaffold(
      //AppBarはアプリのタイトルとかを表示してくれる領域のこと
      appBar:AppBar(
        title:Text(alarmSetting),
      ),
      //body アプリのメイン画面
      //Column 子供になるパーツが全部縦に並んでくれる　子供はchildren にいれる
      body:Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          //時間取得
          SizedBox(
            height: MediaQuery.of(context).size.height/4,
            child:
          Text('${setTime.hour.toString().padLeft(2,'0')}:${setTime.minute.toString().padLeft(2,'0')}',style: TextStyle(fontSize: 50),),
          ),
         RaisedButton(onPressed: ()=>selectTime(context),child:new Text('時間選択')),
          //説明
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
            Text('説明'),
            //TextField(enabled: true,),
            ],
            ),
          //音
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
            Container(child:
            Text('音')),
            RaisedButton(onPressed: ()=>selectFile(),child:new Text('サウンドを選択')),
            //filePicker?
          ],),
          //繰り返し
          Row(children: <Widget>[
            Text("くり返し"),

          ],),
          //バイブ
          SwitchListTile(value: vibration,title: Text('バイブレーション'),onChanged: (bool value){
            setState(() {
              vibration=value;
            });
          },),
        ],
      ),
    );
  }

  Future<void> selectTime(BuildContext context) async{
    final TimeOfDay t =await showTimePicker(context: context, initialTime:TimeOfDay.now());

    if(t!=null){
      setState((){
      setTime=t;
      });
    }
  }

  Future<void> selectFile() async{
    FilePickerResult result=await FilePicker.platform.pickFiles();
    //todo 例外のcatch処理
    if(result!=null){
      filePath=result.files.single.path;
    }
  }

  void createAlarm(){
    //Alarmの設定
  }

}
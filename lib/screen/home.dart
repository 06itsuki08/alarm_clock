import 'package:alarm_clock/screen/alarmstop.dart';
import 'package:alarm_clock/screen/mainmenu.dart';
import 'package:alarm_clock/val/string.dart';
import 'package:flutter/cupertino.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);
  _Home createState() => _Home();
}

class _Home extends State<Home> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    //もしmoveAlarmがnullだったときはfalseにしてとりあえずメイン画面に移動させる
    if (moveAlarm != true) moveAlarm = false;
    //アプリがバックグラウンドから復帰したときなどの状態をとれる
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //もしアプリがバックグラウンドがら戻ってきたら、画面を更新させる。
    //アラーム登録後にアプリを落とさないで、アラームが鳴ってアプリに戻ってきた場合などに動作する
    if (state == AppLifecycleState.resumed) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    //アラームが鳴っているときはアラーム停止画面に遷移、違う場合はメイン画面に遷移
    if (moveAlarm) {
      return AlarmStop();
    } else {
      return MainMenu();
    }
  }
}

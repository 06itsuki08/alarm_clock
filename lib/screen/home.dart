import 'package:alarm_clock/screen/alarmstop.dart';
import 'package:alarm_clock/screen/mainmenu.dart';
import 'package:alarm_clock/val/string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);
  _Home createState() => _Home();
}

class _Home extends State<Home> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    if (moveAlarm != true) moveAlarm = false;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (moveAlarm) {
      return AlarmStop();
    } else {
      return MainMenu();
    }
  }
}

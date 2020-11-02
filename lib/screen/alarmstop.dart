import 'package:alarm_clock/module/alarm.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class AlarmStop extends StatefulWidget {
  Alarm alarm;
  AlarmStop(this.alarm);
  @override
  _AlarmStopState createState() => _AlarmStopState();
}

class _AlarmStopState extends State<AlarmStop> {
  int stopCount;
  @override
  void initState() {
    super.initState();
    stopCount = 0;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (stopCount > 5) {
      return alarmMode();
    } else if (widget.alarm.qrCodeMode) {
      return alarmStopOnQRCode();
    } else {
      return snoozeStopMode();
    }
  }

  Widget alarmMode() {
    return Scaffold(
        body: Column(
      children: <Widget>[
        Text('日付'),
        Text('${widget.alarm.time.hour} : ${widget.alarm.time.minute}'),
        Text('あと${stopCount.toString()}回タップ'),
        RaisedButton(
          onPressed: () {
            setState(() {
              stopCount++;
            });
          },
          child: Text('TAP!'),
        )
      ],
    ));
  }

  alarmStopOnQRCode() {
    return Scaffold(
        body: Column(
      children: <Widget>[
        Text('QRcodeを映りこませる'),
        RaisedButton(
          onPressed: () {
            setState(() {});
          },
          child: Icon(Icons.camera_alt),
        )
      ],
    ));
  }

  snoozeStopMode() {
    return Scaffold(
        body: Column(
      children: <Widget>[
        Text('質問'),
        Text('回答'),
      ],
    ));
  }
}

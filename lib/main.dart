import 'package:alarm_clock/val/string.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainPage(),
      routes: <String, WidgetBuilder> {
        '/home': (BuildContext context) => new MainPage(),
        '/addalarm': (BuildContext context) => new Addalarm(),
        '/settings' : (BuildContext context) => new Settings()

      },
    );
  }
}
class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title:Text(title),
        actions: <Widget>[
          IconButton(
            icon:Icon(Icons.alarm_add),
              onPressed: () => Navigator.of(context).pushNamed("/addalarm"),

          ),

          IconButton(
            icon:Icon(Icons.settings),
            onPressed: () => Navigator.of(context).pushNamed("/settings"),
          )
        ]
      ),
    );
  }
}
class Addalarm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Navigator'),
      ),
      body: new Container(
        padding: new EdgeInsets.all(32.0),
        child: new Center(
          child: new Column(
            children: <Widget>[
              Text('アラーム追加'),
              RaisedButton(onPressed: () => Navigator.of(context).pop(), child: new Text('戻る'),)
            ],
          ),
        ),
      ),
    );
  }
}

class Settings extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Navigator'),
      ),
      body: new Container(
        padding: new EdgeInsets.all(32.0),
        child: new Center(
          child: new Column(
            children: <Widget>[
              Text('設定画面'),
              RaisedButton(onPressed: () => Navigator.of(context).pop(), child: new Text('戻る'),)
            ],
          ),
        ),
      ),
    );
  }
}
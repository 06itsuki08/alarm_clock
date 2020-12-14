import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class UserSetting {
  int movingAlarmId;
  tz.TZDateTime feastAlarmTime;
  //アラームのボリューム
  double volume = 1.0;
  //スヌーズ解除で使うクイズ一覧
  //[0:randomNumAdd,1:randomColor]適宜増加
  List<bool> useQuiz;
  //スヌーズ解除の為の問題の数
  int quizClearCount = 3;
  //ランダムカラーの選択肢がカラーコードか否か
  bool colorCodeQuiz;

  UserSetting(
      {this.movingAlarmId,
      this.feastAlarmTime,
      this.volume,
      this.useQuiz,
      this.quizClearCount,
      this.colorCodeQuiz});

  Map toJson() => {
        'movingAlarmId': movingAlarmId,
        'feastAlarmTime': '$feastAlarmTime',
        'volume': volume,
        'useQuiz': useQuiz,
        'quizClearCount': quizClearCount,
        'colorCodeQuiz': colorCodeQuiz
      };

  UserSetting.fromJson(Map json)
      : movingAlarmId = json['movingAlarmId'],
        feastAlarmTime = tz.TZDateTime.parse(tz.local, json['feastAlarmTime']),
        volume = json['volume'],
        useQuiz = json['useQuiz'].cast<bool>() as List<bool>,
        quizClearCount = json['quizClearCount'],
        colorCodeQuiz = json['colorCodeQuiz'];
}

UserSetting appSetting;

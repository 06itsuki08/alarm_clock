class UserSetting {
  double volume = 1.0;

  UserSetting({this.volume});

  Map toJson() => {
        'volume': volume,
      };

  UserSetting.fromJson(Map json) : volume = json['volume'].cast<double>();
}

UserSetting appSetting;

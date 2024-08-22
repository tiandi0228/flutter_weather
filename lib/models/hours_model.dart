import 'dart:convert';

HoursResponse hoursModelFromJson(String str) =>
    HoursResponse.fromJson(json.decode(str));

String hoursModelToJson(HoursResponse data) => json.encode(data.toJson());

class HoursResponse {
  String? code;
  List<HoursModel>? hourly;

  HoursResponse({
    this.code,
    this.hourly,
  });

  factory HoursResponse.fromJson(Map<String, dynamic> json) => HoursResponse(
        code: json['code'],
        hourly: json['code'] == 200
            ? List<HoursModel>.from(
                json["hourly"].map(
                  (x) => HoursModel.fromJson(x),
                ),
              )
            : [],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "hourly": List<dynamic>.from(hourly!.map((x) => x.toJson())),
      };
}

class HoursModel {
  HoursModel({
    this.text,
    this.fxTime,
    this.temp,
    this.icon,
  });

  String? text;

  String? fxTime;

  String? temp;

  String? icon;

  HoursModel.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    fxTime = json['fxTime'];
    temp = json['temp'];
    icon = json['icon'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    data['fxTime'] = fxTime;
    data['temp'] = temp;
    data['icon'] = icon;
    return data;
  }
}

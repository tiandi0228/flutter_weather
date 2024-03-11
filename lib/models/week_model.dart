import 'dart:convert';

WeekResponse hoursModelFromJson(String str) =>
    WeekResponse.fromJson(json.decode(str));

String hoursModelToJson(WeekResponse data) => json.encode(data.toJson());

class WeekResponse {
  String? code;
  List<WeekModel>? daily;

  WeekResponse({
    this.code,
    this.daily,
  });

  factory WeekResponse.fromJson(Map<String, dynamic> json) => WeekResponse(
        code: json['code'],
        daily: List<WeekModel>.from(
          json["daily"].map(
            (x) => WeekModel.fromJson(x),
          ),
        ),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "daily": List<dynamic>.from(daily!.map((x) => x.toJson())),
      };
}

class WeekModel {
  WeekModel({
    this.fxDate,
    this.iconDay,
    this.iconNight,
    this.tempMin,
    this.tempMax,
    this.humidity,
    this.uvIndex,
  });

  String? fxDate;
  String? iconDay;
  String? iconNight;
  String? tempMin;
  String? tempMax;
  String? humidity;
  String? uvIndex;

  WeekModel.fromJson(Map<String, dynamic> json) {
    fxDate = json['fxDate'];
    tempMin = json['tempMin'];
    tempMax = json['tempMax'];
    iconDay = json['iconDay'];
    iconNight = json['iconNight'];
    humidity = json['humidity'];
    uvIndex = json['uvIndex'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['fxDate'] = fxDate;
    data['tempMin'] = tempMin;
    data['tempMax'] = tempMax;
    data['iconDay'] = iconDay;
    data['iconNight'] = iconNight;
    data['humidity'] = humidity;
    data['uvIndex'] = uvIndex;
    return data;
  }
}

import 'dart:convert';

NowResponse hoursModelFromJson(String str) =>
    NowResponse.fromJson(json.decode(str));

String hoursModelToJson(NowResponse data) => json.encode(data.toJson());

class NowResponse {
  String? code;
  String? updateTime;
  NowModel? now;

  NowResponse({
    this.code,
    this.updateTime,
    this.now,
  });

  NowResponse.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    updateTime = json['updateTime'];
    now = json['now'] != null ? NowModel.fromJson(json['now']) : null;
  }

  Map<String, dynamic> toJson() => {
        "code": code,
        "now": now,
        "updateTime": updateTime,
      };
}

class NowModel {
  NowModel({
    this.text,
    this.windDir,
    this.windScale,
    this.temp,
    this.pressure,
    this.humidity,
    this.updateTime,
    this.category,
    this.level,
    this.uvIndex,
  });

  String? text;
  String? windDir;
  String? windScale;
  String? temp;
  String? pressure;
  String? humidity;
  String? updateTime;
  String? category;
  String? level;
  String? uvIndex;

  NowModel.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    windDir = json['windDir'];
    windScale = json['windScale'];
    temp = json['temp'];
    pressure = json['pressure'];
    humidity = json['humidity'];
    updateTime = json['updateTime'];
    category = json['category'];
    level = json['level'];
    uvIndex = json['uvIndex'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    data['windDir'] = windDir;
    data['windScale'] = windScale;
    data['temp'] = temp;
    data['pressure'] = pressure;
    data['humidity'] = humidity;
    data['updateTime'] = updateTime;
    data['category'] = category;
    data['level'] = level;
    data['uvIndex'] = uvIndex;
    return data;
  }
}

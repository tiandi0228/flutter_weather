import 'dart:convert';

LocationResponse locationModelFromJson(String str) =>
    LocationResponse.fromJson(json.decode(str));

String locationModelToJson(LocationResponse data) => json.encode(data.toJson());

class LocationResponse {
  String? code;
  List<LocationModel>? location;

  LocationResponse({
    this.code,
    this.location,
  });

  factory LocationResponse.fromJson(Map<String, dynamic> json) =>
      LocationResponse(
        code: json['code'],
        location: json['code'] == 200
            ? List<LocationModel>.from(
                json["location"].map(
                  (x) => LocationModel.fromJson(x),
                ),
              )
            : [],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "location": List<dynamic>.from(location!.map((x) => x.toJson())),
      };
}

class LocationModel {
  String? name;
  String? id;
  String? lat;
  String? lon;

  LocationModel({
    this.name,
    this.id,
    this.lat,
    this.lon,
  });

  LocationModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    id = json['id'];
    lat = json['lat'];
    lon = json['lon'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['id'] = id;
    data['lat'] = lat;
    data['lon'] = lon;
    return data;
  }
}

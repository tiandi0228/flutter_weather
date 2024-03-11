class CityModel {
  CityModel({
    this.name,
    this.lng,
    this.lat,
    this.id,
    this.isLocation,
  });

  String? name;
  String? lng;
  String? lat;
  String? id;
  bool? isLocation;

  CityModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    lng = json['lng'];
    lat = json['lat'];
    isLocation = json['isLocation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['lng'] = lng;
    data['lat'] = lat;
    data['isLocation'] = isLocation;
    return data;
  }
}

import 'dart:async';
import 'dart:ui';

import 'package:flutter_weather/models/hours_model.dart';
import 'package:flutter_weather/models/location_model.dart';
import 'package:flutter_weather/models/now_model.dart';
import 'package:flutter_weather/models/week_model.dart';
import 'package:flutter_weather/network/network_manager.dart';
import 'package:ftoast/ftoast.dart';
import 'package:hive/hive.dart';

var box = Hive.box('Box');

// 获取城市名称
Future<LocationResponse> getGeoLocation(Map<String, dynamic> params) async {
  var res = await NetworkManager()
      .get(url: 'https://geoapi.qweather.com/v2/city/lookup', params: params);
  if (res == null) return LocationResponse();
  return LocationResponse.fromJson(res);
}

// 获取24小时天气
Future<HoursResponse> getHours() async {
  var res = await NetworkManager().get(
      url: 'https://devapi.qweather.com/v7/weather/24h',
      isCityLocation: true,
      params: {});
  if (res == null) return HoursResponse();
  return HoursResponse.fromJson(res);
}

// 获取7天天气
Future<WeekResponse> getWeek() async {
  var res = await NetworkManager().get(
      url: 'https://devapi.qweather.com/v7/weather/7d',
      isCityLocation: true,
      params: {});
  if (res == null) return WeekResponse();
  return WeekResponse.fromJson(res);
}

// 获取当前天气
Future<NowResponse> getNow() async {
  var res = await NetworkManager().get(
      url: 'https://devapi.qweather.com/v7/weather/now',
      isCityLocation: true,
      params: {});
  if (res == null) return NowResponse();
  return NowResponse.fromJson(res);
}

// 获取当天空气质量
Future<NowResponse> getAir() async {
  var res = await NetworkManager().get(
      url: 'https://devapi.qweather.com/v7/air/now',
      isCityLocation: true,
      params: {});
  if (res == null) return NowResponse();
  return NowResponse.fromJson(res);
}

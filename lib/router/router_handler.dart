import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_weather/screens/city/city_screen.dart';
import 'package:flutter_weather/screens/home/home_screen.dart';
import 'package:flutter_weather/screens/settings/settings_screen.dart';

var homeScreenHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const HomeScreen();
});

var cityScreenHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const CityScreen();
});

var settingsScreenHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const SettingsScreen();
});

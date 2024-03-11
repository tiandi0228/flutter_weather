import 'dart:developer' as developer;

import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_weather/router/router_handler.dart';

class MyRouter {
  static FluroRouter router = FluroRouter();
  static String homeScreen = '/home';
  static String cityScreen = '/city';
  static String settingsScreen = '/settings';

  static void configureRoutes(FluroRouter router) {
    router.notFoundHandler = Handler(
        handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      developer.log("ROUTE WAS NOT FOUND !!!");
      return;
    });
    router.define(
      homeScreen,
      handler: homeScreenHandler,
      transitionType: TransitionType.inFromLeft,
    );
    router.define(
      cityScreen,
      handler: cityScreenHandler,
      transitionType: TransitionType.inFromLeft,
    );
    router.define(
      settingsScreen,
      handler: settingsScreenHandler,
      transitionType: TransitionType.inFromLeft,
    );
  }
}

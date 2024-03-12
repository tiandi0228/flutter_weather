import 'dart:async';
import 'dart:io';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_weather/config/constants.dart';
import 'package:flutter_weather/models/now_model.dart';
import 'package:flutter_weather/network/api.dart';
import 'package:flutter_weather/screens/home/widgets/body.dart';
import 'package:hive/hive.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:uni_platform/uni_platform.dart';
import 'package:window_manager/window_manager.dart';

class Popup extends StatefulWidget {
  const Popup({super.key});

  @override
  State<StatefulWidget> createState() => _PopupState();
}

class _PopupState extends State<Popup>
    with WidgetsBindingObserver, TrayListener, WindowListener {
  Brightness _brightness = Brightness.light;
  var box = Hive.box('Box');

  late TimerUtil mTimerUtil;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    if (isDesktop) {
      trayManager.addListener(this);
      windowManager.addListener(this);
    }
    _init();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (isDesktop) {
      trayManager.removeListener(this);
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    Brightness newBrightness =
        WidgetsBinding.instance.window.platformBrightness;
    if (newBrightness != _brightness) {
      _brightness = newBrightness;
      if (isDesktop) {
        _initTray();
      }
      setState(() {});
    }
  }

  // 初始化
  Future<void> _init() async {
    await _initTray();
    await _initWindow();
    await _notification();
    setState(() {});
  }

  // 初始化Tray
  Future<void> _initTray() async {
    String trayIcon = 'assets/tray/tray_dark.png';
    if (_brightness == Brightness.dark) {
      trayIcon = 'assets/tray/tray_light.png';
    }

    await trayManager.destroy();
    await trayManager.setIcon(
      trayIcon,
      isTemplate: UniPlatform.isMacOS ? true : false,
    );
    await Future.delayed(const Duration(milliseconds: 10));
  }

  // 初始化窗口
  Future<void> _initWindow() async {
    await windowManager.ensureInitialized();
    const size = Size(350, 563);
    await Future.any([
      windowManager.setSize(size),
      windowManager.setSkipTaskbar(true),
      windowManager.setTitleBarStyle(
        TitleBarStyle.hidden,
        windowButtonVisibility: false,
      ),
    ]);
    await Future<void>.delayed(const Duration(milliseconds: 200));
    await windowManager.hide();
  }

  // 设置定时消息通知
  Future<void> _notification() async {
    mTimerUtil = TimerUtil(mInterval: 1800000); // 定时半小时
    if (!mTimerUtil.isActive()) {
      mTimerUtil.startTimer();
      print('启动');
    }
    mTimerUtil.setOnTimerTickCallback((int tick) {
      debugPrint('tick : ${tick}');
      getWeatherNow();
      getAirNow();
    });
  }

  // 风速显示对应提示
  String _getWinScaleMessage(int windScale) {
    switch (windScale) {
      case 6:
        return '当前是6级强风, 风速22-27节（10.8-13.8米/秒）';
      case 7:
        return '当前是7级疾风, 风速28-33节（13.9-17.1米/秒）';
      case 8:
        return '当前是8级大风, 风速34-40节（17.2-20.7米/秒）';
      case 9:
        return '当前是9级烈风, 风速41-47节（20.8-24.4米/秒）';
      case 10:
        return '当前是10级狂风, 风速48-55节（24.5-28.4米/秒）';
      case 11:
        return '当前是11级暴风, 风速56-63节（28.5-32.6米/秒）';
      case 12:
        return '当前是12级台风, 风速大于63节（大于32.7米/秒）';
      default:
        return "";
    }
  }

  // 获取实时天气
  Future<void> getWeatherNow() async {
    NowResponse res = await getNow();
    if (res.code == null) return;
    int windScale = int.parse(res.now!.windScale ?? '0');
    String message = _getWinScaleMessage(windScale);
    if (windScale < 6) return;
    LocalNotification notification = LocalNotification(
      title: "风速提醒",
      body: message,
    );
    notification.show();
  }

  // 空气质量显示对应提示
  String _getAirMessage(int windScale) {
    switch (windScale) {
      case 3:
        return '当前空气质量轻度污染';
      case 4:
        return '当前空气质量中度污染';
      case 5:
        return '当前空气质量重度污染';
      case 6:
        return '当前空气质量严重污染';
      default:
        return "";
    }
  }

  // 获取实时空气质量
  Future<void> getAirNow() async {
    NowResponse res = await getAir();
    if (res.code == null) return;
    int level = int.parse(res.now!.level ?? '0');
    String message = _getAirMessage(level);
    if (level < 3) return;
    LocalNotification notification = LocalNotification(
      title: "空气质量提醒",
      body: message,
    );
    notification.show();
  }

  // 隐藏窗口
  Future<void> _windowHide() async {
    await windowManager.hide();
  }

  // 显示窗口
  Future<void> _windowShow() async {
    if (isDesktop) {
      Rect? trayIconBounds = await trayManager.getBounds();
      Size windowSize = await windowManager.getSize();
      if (trayIconBounds != null) {
        Size trayIconSize = trayIconBounds.size;
        Offset trayIconPosition = trayIconBounds.topLeft;
        Offset newPosition = Offset(
          trayIconPosition.dx - ((windowSize.width - trayIconSize.width) / 2),
          trayIconPosition.dy,
        );
        windowManager.setPosition(newPosition);
      }
    }

    await Future.delayed(const Duration(milliseconds: 300));
    bool isVisible = await windowManager.isVisible();
    if (!isVisible) {
      await windowManager.show();
    } else {
      await windowManager.focus();
    }
  }

  @override
  Future<void> onTrayIconMouseDown() async {
    // debugPrint('鼠标按下');
    _windowShow();
  }

  @override
  Future<void> onWindowBlur() async {
    debugPrint('窗口失去焦点');
    await Future.delayed(const Duration(milliseconds: 100));
    _windowHide();
  }

  @override
  Future<void> onWindowClose() async {
    debugPrint('窗口关闭');
    await trayManager.destroy();
    await Hive.close();
    mTimerUtil.cancel();
    exit(0);
  }

  @override
  Widget build(BuildContext context) {
    return const Body();
  }
}

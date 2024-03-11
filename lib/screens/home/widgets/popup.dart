import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_weather/config/constants.dart';
import 'package:flutter_weather/screens/home/widgets/body.dart';
import 'package:hive/hive.dart';
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
    exit(0);
  }

  @override
  Widget build(BuildContext context) {
    return const Body();
  }
}

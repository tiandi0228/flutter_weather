import 'package:flutter/material.dart';
import 'package:uni_platform/uni_platform.dart';

const backgroundColor = Color(0xFF1B1B1D); // 全局背景色
const cardColor = Color(0xFF333334); // 卡片背景色
const buttonColor = Color(0xFF2E2E2E); // 按钮背景色
const buttonHoverColor = Color(0xFF383838); // 按钮hover背景色
const textColor = Color(0xFFFFFFFF); // 文本颜色
const secondaryTextColor = Color(0xFFC2C2C2); // 次级文本颜色
const borderColor = Color(0xFF363B42); // 边框颜色
const baseUrl = "https://api.syc.im/api/v1/expire/";
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final bool isDesktop = (UniPlatform.isMacOS || UniPlatform.isWindows);

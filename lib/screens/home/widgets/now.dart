import 'dart:async';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_weather/config/constants.dart';
import 'package:flutter_weather/models/location_model.dart';
import 'package:flutter_weather/models/now_model.dart';
import 'package:flutter_weather/models/week_model.dart';
import 'package:flutter_weather/network/api.dart';
import 'package:geolocator/geolocator.dart';

class Now extends StatefulWidget {
  Function? onChangeCity;
  bool? isRefresh;

  Now({super.key, this.onChangeCity, this.isRefresh});

  @override
  State<StatefulWidget> createState() => _NowState();
}

class _NowState extends State<Now> {
  late NowModel now = NowModel();

  bool get refresh => widget.isRefresh!;

  @override
  void initState() {
    super.initState();
    setState(() {
      now = NowModel();
    });
    getAllData();
  }

  @override
  void didUpdateWidget(covariant Now oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint('now update: ${refresh}');
    setState(() {
      now = NowModel();
    });
    if (refresh) {
      _initLocation();
      getAllData();
    }
  }

  // 获取当前位置信息
  Future<void> _initLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low);
    Map<String, dynamic> params = {
      'location': '${position.longitude},${position.latitude}',
    };

    LocationResponse location = await getGeoLocation(params);

    if (location.code == null) {
      return;
    }

    box.put('location', {
      'name': location.location![0].name,
      'lng': location.location![0].lon,
      'lat': location.location![0].lat
    });
  }

  Future<void> getAllData() async {
    await Future.wait<dynamic>([getWeatherNow(), getAirNow(), getWeekWeather()])
        .then((value) {
      if (value.isEmpty) return;
      setState(() {
        now = NowModel(
          text: value[0].text,
          temp: value[0].temp,
          updateTime: value[0].updateTime,
          windDir: value[0].windDir,
          windScale: value[0].windScale,
          humidity: value[0].humidity,
          pressure: value[0].pressure,
          level: value[1].level,
          category: value[1].category,
          uvIndex: value[2].uvIndex,
        );
      });
    }).catchError((error) {
      print('now error: ${error}');
    });
  }

  // 获取实时天气
  Future<NowModel> getWeatherNow() async {
    NowResponse res = await getNow();
    if (res.code == null) return NowModel();
    return NowModel(
      text: res.now?.text,
      temp: res.now?.temp,
      updateTime: res.updateTime,
      windDir: res.now?.windDir,
      windScale: res.now?.windScale,
      humidity: res.now?.humidity,
      pressure: res.now?.pressure,
    );
  }

  // 获取实时空气质量
  Future<NowModel> getAirNow() async {
    NowResponse res = await getAir();
    if (res.code == null) return NowModel();
    return NowModel(
      category: res.now?.category,
      level: res.now?.level,
    );
  }

  // 获取7天天气数据
  Future<WeekModel> getWeekWeather() async {
    WeekResponse res = await getWeek();
    if (res.code == null) return WeekModel();
    return WeekModel(uvIndex: res.daily![0].uvIndex ?? '1');
  }

  // 转换紫外线数值to中文
  String getUvIndex(String str) {
    int num = int.parse(str);
    if (num <= 2) {
      return '最弱';
    } else if (num > 2 && num <= 4) {
      return '较弱';
    } else if (num > 4 && num <= 6) {
      return '中等';
    } else if (num > 6 && num <= 9) {
      return '强';
    } else {
      return '极强';
    }
  }

  // 空气质量转换颜色
  Color getAirToColor(String level) {
    switch (level) {
      case '1':
        return Colors.lightGreenAccent;
      case '2':
        return Colors.limeAccent;
      case '3':
        return Colors.yellowAccent;
      case '4':
        return Colors.amberAccent;
      case '5':
        return Colors.deepOrangeAccent;
      case '6':
        return Colors.redAccent;
      default:
        return Colors.lightGreenAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(top: 20),
      decoration: const BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(
                TextSpan(
                  text: box.get('select-city') != null
                      ? box.get('select-city')['name']
                      : box.get('location') != null
                          ? box.get('location')['name']
                          : '',
                  style: const TextStyle(color: textColor, fontSize: 12),
                  children: [
                    TextSpan(
                      text: ' 切换',
                      style: const TextStyle(
                          color: secondaryTextColor, fontSize: 12),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          debugPrint('切换');
                          Navigator.pushNamed(context, '/city').then((value) {
                            if (value != null) {
                              widget.onChangeCity?.call(true);
                              getAllData();
                            }
                          });
                        },
                    )
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  text: DateUtil.formatDateStr(now.updateTime ?? '',
                      format: DateFormats.h_m, isUtc: false),
                  style:
                      const TextStyle(color: secondaryTextColor, fontSize: 12),
                  children: const [
                    TextSpan(
                      text: ' 更新',
                      style: TextStyle(color: secondaryTextColor, fontSize: 12),
                    )
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                '${now.temp ?? ''}°',
                style: const TextStyle(color: textColor, fontSize: 40),
              ),
              const Padding(padding: EdgeInsets.only(left: 20)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    now.text ?? '',
                    style: const TextStyle(color: textColor, fontSize: 12),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 5)),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 1, horizontal: 2),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: getAirToColor(now.level ?? '1'),
                          ),
                        ),
                        child: Text(
                          'QAI ${now.category ?? ' '}',
                          style: TextStyle(
                              color: getAirToColor(now.level ?? '1'),
                              fontSize: 12),
                        ),
                      ),
                      const Padding(padding: EdgeInsets.only(right: 5)),
                      Text(
                        '${now.windDir ?? ''}${now.windScale ?? ''}级',
                        style: const TextStyle(color: textColor, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(
                TextSpan(
                  text: '湿度 ',
                  style:
                      const TextStyle(color: secondaryTextColor, fontSize: 12),
                  children: [
                    TextSpan(
                      text: '${now.humidity ?? ''}%',
                      style: const TextStyle(color: textColor),
                    )
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  text: '紫外线 ',
                  style:
                      const TextStyle(color: secondaryTextColor, fontSize: 12),
                  children: [
                    TextSpan(
                      text: getUvIndex(now.uvIndex ?? '0'),
                      style: const TextStyle(color: textColor),
                    )
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  text: '大气压 ',
                  style:
                      const TextStyle(color: secondaryTextColor, fontSize: 12),
                  children: [
                    TextSpan(
                      text: '${now.pressure ?? ''}Hpa',
                      style: const TextStyle(color: textColor),
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_weather/config/constants.dart';
import 'package:flutter_weather/models/week_model.dart';
import 'package:flutter_weather/network/api.dart';

class Week extends StatefulWidget {
  bool? isRefresh;

  Week({super.key, this.isRefresh});

  @override
  State<StatefulWidget> createState() => _WeekState();
}

class _WeekState extends State<Week> {
  List<WeekModel> list = [];

  bool get refresh => widget.isRefresh!;

  @override
  void initState() {
    super.initState();
    getDayWeather();
  }

  @override
  void didUpdateWidget(covariant Week oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      list = [];
    });
    if (refresh) {
      getDayWeather();
    }
  }

  Future<void> getDayWeather() async {
    WeekResponse res = await getWeek();
    if (res.code == null) return;
    for (var item in res.daily!) {
      list.add(WeekModel(
        tempMin: item.tempMin,
        tempMax: item.tempMax,
        iconDay: item.iconDay,
        iconNight: item.iconNight,
        fxDate: item.fxDate,
        humidity: item.humidity,
      ));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 160,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(top: 0),
      decoration: const BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: list
              .map(
                (WeekModel item) => Container(
                  height: 30,
                  decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: borderColor, width: 1))),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        alignment: Alignment.center,
                        child: Text(
                          DateUtil.isToday(DateTime.parse(item.fxDate ?? '')
                                  .millisecondsSinceEpoch)
                              ? '今天'
                              : DateUtil.getWeekday(
                                  DateTime.parse(item.fxDate ?? ''),
                                  languageCode: 'zh'),
                          style:
                              const TextStyle(color: textColor, fontSize: 12),
                        ),
                      ),
                      const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5)),
                      SvgPicture.asset(
                        "assets/icons/${item.iconDay}.svg",
                        width: 20,
                        height: 20,
                      ),
                      const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5)),
                      Text(
                        '${item.tempMax}°',
                        style: const TextStyle(color: textColor, fontSize: 12),
                      ),
                      const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5)),
                      Container(
                        width: 125,
                        height: 5,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2A92EC), Color(0xFFA9E0F9)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5)),
                      Text(
                        '${item.tempMin}°',
                        style: const TextStyle(color: textColor, fontSize: 12),
                      ),
                      const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5)),
                      SvgPicture.asset(
                        "assets/icons/${item.iconNight}.svg",
                        width: 20,
                        height: 20,
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

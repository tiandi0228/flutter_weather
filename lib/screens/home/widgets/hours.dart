import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_weather/config/constants.dart';
import 'package:flutter_weather/models/hours_model.dart';
import 'package:flutter_weather/network/api.dart';

class Hours extends StatefulWidget {
  bool? isRefresh;

  Hours({super.key, this.isRefresh});

  @override
  State<StatefulWidget> createState() => _HoursState();
}

class _HoursState extends State<Hours> {
  List<HoursModel> list = [];

  bool get refresh => widget.isRefresh!;

  @override
  void initState() {
    super.initState();
    getHoursWeather();
  }

  @override
  void didUpdateWidget(covariant Hours oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      list = [];
    });
    if (refresh) {
      getHoursWeather();
    }
  }

  Future<void> getHoursWeather() async {
    HoursResponse res = await getHours();
    if (res.code == null) return;
    for (var item in res.hourly!) {
      list.add(HoursModel(
        text: item.text,
        temp: item.temp,
        icon: item.icon,
        fxTime: item.fxTime,
      ));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 140,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          children: [
            temp(context),
            bar(context),
            time(),
          ],
        ),
      ),
    );
  }

  Widget temp(BuildContext context) {
    return Row(
      children: list
          .map(
            (HoursModel item) => SizedBox(
              width: 40,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${MediaQuery.of(context).size.height}°',
                    style: const TextStyle(color: textColor, fontSize: 12),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget bar(BuildContext context) {
    return SizedBox(
      height: 65,
      child: Row(
        children: list
            .map(
              (HoursModel item) => SizedBox(
                width: 40,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 8,
                      height: double.parse(item.temp!).abs() * 2 > 50
                          ? 50
                          : double.parse(item.temp!).abs() * 2,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        //   color: Colors.amber,
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFA9E0F9),
                            Color(0xFF2A92EC),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget time() {
    return Row(
      children: list
          .map(
            (HoursModel item) => SizedBox(
              width: 40,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SvgPicture.asset(
                    "assets/icons/${item.icon}.svg",
                    width: 20,
                    height: 20,
                  ),
                  Text(
                    '${DateUtil.formatDateStr(
                      item.fxTime ?? '',
                      format: 'HH',
                      isUtc: false,
                    )}时',
                    style: const TextStyle(
                        color: secondaryTextColor, fontSize: 11),
                  )
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

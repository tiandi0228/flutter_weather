import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_weather/config/constants.dart';
import 'package:flutter_weather/screens/home/widgets/hours.dart';
import 'package:flutter_weather/screens/home/widgets/now.dart';
import 'package:flutter_weather/screens/home/widgets/week.dart';
import 'package:ftoast/ftoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class Weather extends StatefulWidget {
  const Weather({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _WeatherState();
}

class _WeatherState extends State<Weather> with TrayListener {
  bool isRefresh = false;
  var box = Hive.box('Box');

  @override
  void initState() {
    super.initState();
    if (isDesktop) {
      trayManager.addListener(this);
    }
  }

  @override
  void dispose() {
    if (isDesktop) {
      trayManager.removeListener(this);
    }
    super.dispose();
  }

  @override
  Future<void> onTrayIconMouseDown() async {
    debugPrint('鼠标按下');
    // box.delete('key');
    // box.delete('location');
    // box.delete('select-city');
    if (box.get('key') == null) {
      FToast.toast(
        context,
        duration: 2800,
        msg: '请点击右上角进行配置',
        msgStyle: const TextStyle(
          color: Colors.white,
        ),
      );
    } else {
      setState(() {
        isRefresh = true;
      });
    }
    await _determinePosition();
  }

  // 校验定位权限
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low);

    return position;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                  backgroundColor: MaterialStateProperty.all(buttonColor),
                  overlayColor: MaterialStateProperty.all(buttonHoverColor),
                  shape: MaterialStateProperty.all(
                    const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                ),
                onPressed: () {
                  windowManager.close();
                },
                child: SvgPicture.asset(
                  "assets/icons/quit.svg",
                  width: 20,
                  height: 20,
                ),
              ),
              ElevatedButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                  backgroundColor: MaterialStateProperty.all(buttonColor),
                  overlayColor: MaterialStateProperty.all(buttonHoverColor),
                  shape: MaterialStateProperty.all(
                    const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    isRefresh = false;
                  });
                  Navigator.pushNamed(context, '/settings').then((value) {
                    if (value != null) {
                      setState(() {
                        isRefresh = true;
                      });
                    }
                  });
                },
                child: SvgPicture.asset(
                  "assets/icons/setting.svg",
                  width: 20,
                  height: 20,
                ),
              ),
            ],
          ),
          Now(
            isRefresh: isRefresh,
            onChangeCity: (val) {
              if (val) {
                setState(() {
                  isRefresh = true;
                });
              }
            },
          ),
          Hours(isRefresh: isRefresh),
          Week(isRefresh: isRefresh),
        ],
      ),
    );
  }
}

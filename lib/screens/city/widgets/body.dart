import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_weather/config/constants.dart';
import 'package:flutter_weather/models/city_model.dart';
import 'package:flutter_weather/models/location_model.dart';
import 'package:flutter_weather/network/api.dart';
import 'package:flutter_weather/widgets/input_widget.dart';
import 'package:hive/hive.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<StatefulWidget> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final List<CityModel> hot = [];
  List<CityModel> cities = [];
  String keyword = '';
  var box = Hive.box('Box');

  @override
  void initState() {
    super.initState();
    String name =
        box.get('location') != null ? box.get('location')['name'] : '';
    String lng =
        box.get('location') != null ? box.get('location')['lng'] : '0.0';
    String lat =
        box.get('location') != null ? box.get('location')['lat'] : '0.0';
    hot.add(CityModel(name: name, lng: lng, lat: lat, isLocation: true));
    getHotData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // 获取热门城市
  Future<void> getHotData() async {
    String jsonString = await rootBundle.loadString('assets/json/cities.json');
    final jsonResult = json.decode(jsonString);

    List hotList = jsonResult['indexCities']['hot'];

    for (var item in hotList) {
      hot.add(CityModel(name: item['name']));
    }

    setState(() {});
  }

  // 搜索城市
  Future<void> getCityData(String keyword) async {
    String jsonString = await rootBundle.loadString('assets/json/cities.json');
    final jsonResult = json.decode(jsonString);

    List cityList = jsonResult['indexCities']['city'];
    Iterable cityArr = cityList.where((e) => e['name'].startsWith(keyword));
    for (var item in cityArr) {
      cities.add(CityModel(name: item['name']));
    }
    setState(() {});
  }

  // 选择城市
  Future<void> _changeCity(String name, BuildContext context) async {
    if (name.isEmpty) return;
    Map<String, dynamic> params = {
      'location': name,
    };

    LocationResponse location = await getGeoLocation(params);

    if (location.code == null) {
      return;
    }

    box.put('select-city', {
      'name': location.location![0].name,
      'lng': location.location![0].lon,
      'lat': location.location![0].lat
    });

    setState(() {
      cities = [];
    });

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                    Navigator.pop(context);
                  },
                  child: SvgPicture.asset(
                    "assets/icons/back.svg",
                    width: 20,
                    height: 20,
                  ),
                ),
                HCInput(
                  width: 260,
                  hintText: '请输入需要搜索的城市名',
                  onFieldSubmitted: (value) {
                    // debugPrint(value);
                    getCityData(value);
                  },
                  onChanged: (value) {
                    Future.delayed(const Duration(milliseconds: 10));
                    setState(() {
                      keyword = value;
                    });
                  },
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
            if (keyword.isEmpty) _hotCity(context),
            if (keyword.isNotEmpty) _cityList(context)
          ],
        ),
      ),
    );
  }

  Widget _hotCity(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: hot
          .map(
            (CityModel item) => InkWell(
              onTap: () {
                _changeCity(item.name ?? '', context);
              },
              child: Container(
                width: 72,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: item.isLocation ?? false
                      ? Colors.lightBlueAccent
                      : Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (item.isLocation ?? false)
                      SvgPicture.asset(
                        "assets/icons/location.svg",
                        width: 20,
                        height: 20,
                      ),
                    if (item.isLocation ?? false)
                      const Padding(padding: EdgeInsets.only(right: 2)),
                    Text(
                      item.name ?? '',
                      style: TextStyle(
                        color: item.isLocation ?? false
                            ? const Color(0xFF1F4ED6)
                            : Colors.black,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _cityList(BuildContext context) {
    return SizedBox(
      height: 475,
      child: ListView(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        children: cities
            .map(
              (CityModel item) => InkWell(
                onTap: () {
                  debugPrint(item.name);
                  _changeCity(item.name ?? '', context);
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                        bottom: BorderSide(color: borderColor, width: 1)),
                  ),
                  child: ListTile(
                    title: Text(item.name ?? ''),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

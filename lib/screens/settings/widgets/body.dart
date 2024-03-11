import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_weather/config/constants.dart';
import 'package:flutter_weather/widgets/button_widget.dart';
import 'package:flutter_weather/widgets/input_widget.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<StatefulWidget> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final TextEditingController _keyController = TextEditingController();

  var box = Hive.box('Box');

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (await box.get('key') == null) return;
    String key = await box.get('key');
    _keyController.text = key;
  }

  @override
  void dispose() {
    super.dispose();
    _keyController.dispose();
  }

  // 跳转外部浏览器
  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  // 保存
  Future<void> _saveButton(BuildContext context) async {
    String key = _keyController.value.text;
    box.put('key', key);
    debugPrint('保存');
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const Padding(padding: EdgeInsets.only(top: 10)),
          Column(
            children: [
              Row(
                children: [
                  HCInput(
                    controller: _keyController,
                    width: 270,
                    hintText: '请输入和风天气key',
                  ),
                  const Padding(padding: EdgeInsets.only(left: 10)),
                  InkWell(
                    onTap: () {
                      final Uri url = Uri.parse('https://dev.qweather.com/');
                      _launchInBrowser(url);
                    },
                    child: const Text(
                      '获取',
                      style: TextStyle(color: secondaryTextColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.only(top: 10)),
          HCButton(
            text: '保存',
            backgroundColor: Colors.blueAccent,
            textColor: textColor,
            onPressed: () => _saveButton(context),
          ),
        ],
      ),
    );
  }
}

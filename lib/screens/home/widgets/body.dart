import 'package:flutter/material.dart';
import 'package:flutter_weather/screens/home/widgets/weather.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<StatefulWidget> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Weather(),
    );
  }
}

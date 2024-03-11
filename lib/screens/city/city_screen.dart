import 'package:flutter/material.dart';
import 'package:flutter_weather/screens/city/widgets/body.dart';

class CityScreen extends StatelessWidget {
  const CityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Body(),
    );
  }
}

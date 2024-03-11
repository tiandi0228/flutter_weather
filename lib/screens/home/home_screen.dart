import 'package:flutter/material.dart';
import 'package:flutter_weather/screens/home/widgets/popup.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Popup(),
    );
  }
}

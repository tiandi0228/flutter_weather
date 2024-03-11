import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_weather/config/constants.dart';
import 'package:flutter_weather/router/router.dart';
import 'package:flutter_weather/screens/home/home_screen.dart';
import 'package:hive_flutter/adapters.dart';

Future<void> _ensureInitialized() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('Box');
}

void main() async {
  await _ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  MyRouter.configureRoutes(MyRouter.router);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '天气查询',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: backgroundColor,
      ),
      onGenerateRoute: MyRouter.router.generator,
      home: const HomeScreen(),
    );
  }
}

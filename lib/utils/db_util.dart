import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class DBUtil {
  static DBUtil? instance;

  late Box box;

  static Future<void> install() async {
    Directory document = await getApplicationDocumentsDirectory();
    Hive.init(document.path);
  }

  static Future<DBUtil?> getInstance() async {
    if (instance == null) {
      instance = DBUtil();
      await Hive.initFlutter();

      instance?.box = await Hive.openBox('Box');
    }
    return instance;
  }
}

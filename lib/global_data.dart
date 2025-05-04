import 'dart:io';
import 'package:path_provider/path_provider.dart';

class GlobalData {
  static bool introSeen = false;

  static Future<void> loadIntroSeen() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/intro_seen.txt');

      if (await file.exists()) {
        final content = await file.readAsString();
        introSeen = content.trim() == 'true';
      } else {
        introSeen = false;
      }
    } catch (e) {
      introSeen = false;
    }
  }

  static Future<void> setIntroSeen() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/intro_seen.txt');
      await file.writeAsString('true');
      introSeen = true;
    } catch (e) {
      // handle if needed
    }
  }
}

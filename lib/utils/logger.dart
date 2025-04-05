import '../config/app_config.dart';

class AppLogger {
  static void log(String message) {
    if (AppConfig.isDebugMode) {
      print('[LOG] $message');
    }
  }
}
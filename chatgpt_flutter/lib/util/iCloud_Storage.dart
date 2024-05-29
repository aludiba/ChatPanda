import 'package:flutter/services.dart';
import 'package:openai_flutter/utils/ai_logger.dart';

mixin iCloudStorage {
  static const MethodChannel _channel = MethodChannel('iCloudStorage');

  static Future<void> set(String key, String value) async {
    try {
      await _channel.invokeMethod('set', {'key': key, 'value': value});
    } on PlatformException catch (e) {
      AILogger.log("Failed to set data to iCloud: '${e.message}'.");
    }
  }

  static Future<String?> get(String key) async {
    try {
      return await _channel.invokeMethod('get', {'key': key});
    } on PlatformException catch (e) {
      AILogger.log("Failed to get data from iCloud: '${e.message}'.");
      return null;
    }
  }
}

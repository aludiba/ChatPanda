import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:openai_flutter/utils/ai_logger.dart';

class JsonStorage {
  static Future<List<dynamic>> loadJsonData(String filePath) async {
    // 从 assets 文件夹中加载 JSON 文件的内容
    String jsonString = await rootBundle.loadString(filePath);
    // 将 JSON 字符串解析为 Dart 对象（数组）
    List<dynamic> jsonArray = json.decode(jsonString);
    // 返回解析后的数组
    return jsonArray;
  }

  static Future<void> saveDataToJson(dynamic data, String filePath) async {
    try {
      // 将数据转换为JSON字符串
      String jsonString = jsonEncode(data);
      // 打开文件并写入JSON字符串
      File file = File(filePath);
      await file.writeAsString(jsonString);
      AILogger.log('Data saved successfully.');
    } catch (e) {
      AILogger.log('Failed to save data: $e');
    }
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:openai_flutter/utils/ai_logger.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';

class JsonStorage {
  // 从工程文件中读取数据
  static Future<List<dynamic>> loadJsonData(String filePath) async {
    // 从 assets 文件夹中加载 JSON 文件的内容
    String jsonString = await rootBundle.loadString(filePath);
    // 将 JSON 字符串解析为 Dart 对象（数组）
    List<dynamic> jsonArray = json.decode(jsonString);
    // 返回解析后的数组
    return jsonArray;
  }

  // 将数据存储到工程文件中
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

  // 保存数据到本地(沙盒)文件
  static Future<void> saveDataToFile(dynamic data, String fileName) async {
    try {
      // 获取应用的文档目录路径
      Directory directory = await getApplicationDocumentsDirectory();
      String filePath = '${directory.path}/$fileName';
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

  // 检查本地(沙盒)文件是否存在
  static Future<dynamic> fileIsExists(String fileName) async {
    // 获取应用的文档目录路径
    Directory directory = await getApplicationDocumentsDirectory();
    String filePath = '${directory.path}/$fileName';
    bool fileExists = await File(filePath).exists();
    return fileExists;
  }

  // 从本地(沙盒)文件加载数据
  static Future<dynamic> loadDataFromFile(String fileName) async {
    try {
      // 获取应用的文档目录路径
      Directory directory = await getApplicationDocumentsDirectory();
      String filePath = '${directory.path}/$fileName';
      // 读取文件内容并解析JSON数据
      File file = File(filePath);
      String jsonString = await file.readAsString();
      dynamic jsonData = jsonDecode(jsonString);
      return jsonData;
    } catch (e) {
      AILogger.log('Failed to load data: $e');
      return null;
    }
  }
}

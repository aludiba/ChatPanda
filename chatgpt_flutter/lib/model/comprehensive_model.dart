import 'package:flutter/material.dart';

/// 聊天分类列表模型
class ComprehensiveModel {
  String title;
  IconData icon;
  Widget? jumpToPage;

  ComprehensiveModel(
      {required this.title, required this.icon, this.jumpToPage});

  factory ComprehensiveModel.fromJson(Map<String, dynamic> json) =>
      ComprehensiveModel(
          title: json['title'],
          icon: json['icon'],
          jumpToPage: json['jumpToPage']);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['icon'] = icon;
    data['jumpToPage'] = jumpToPage;
    return data;
  }
}

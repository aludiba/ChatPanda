import 'package:chatgpt_flutter/model/conversation_model.dart';

/// AI工具列表数据模型
class AIToolModel {
  String? id;
  String? title;
  List<AIToolSubModel>? children;
  bool? isSelect;

  AIToolModel({this.id, this.title, this.children, this.isSelect});

  AIToolModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    if (json['children'] != null) {
      children = List<AIToolSubModel>.empty(growable: true);
      json['children'].forEach((v) {
        children!.add(AIToolSubModel.fromJson(v));
      });
    }
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    if (children != null) {
      data['children'] = children!.map((e) => e.toJson()).toList();
    }
    return data;
  }
}

class AIToolSubModel {
  String? id;
  String? descTitle;
  String? description;
  ConversationModel? conversation;

  AIToolSubModel(
      {this.id, this.descTitle, this.description, this.conversation});

  AIToolSubModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    descTitle = json['descTitle'];
    description = json['description'];
    if (json['conversation'] != null) {
      conversation = ConversationModel.fromJson(json['conversation']);
    }
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['descTitle'] = descTitle;
    data['description'] = description;
    data['conversation'] = conversation?.toJson();
    return data;
  }
}

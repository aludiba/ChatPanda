import 'package:chatgpt_flutter/model/conversation_model.dart';
import 'package:flutter/material.dart';

class AIToolSharedData extends ChangeNotifier {
  // 数据是否有更新
  bool isUpdate = false;
  // 更新过的数据模型
  ConversationModel? updateModel;
  // 数据是否要删除
  bool isDelete = false;
  // 要删除的AI工具列表数据模型
  ConversationModel? deleteAIModel;

  //数据更新方法(发送通知)
  void updateData(bool isOK, ConversationModel? model) {
    isUpdate = isOK;
    updateModel = model;
    // 通知监听状态的Widget进行更新
    notifyListeners();
  }

  //AI工具列表数据删除方法(发送通知)
  void deleteAIToolData(bool isOK, ConversationModel? model) {
    isDelete = isOK;
    deleteAIModel = model;
    // 通知监听状态的Widget进行更新
    notifyListeners();
  }
}

import 'package:chatgpt_flutter/model/conversation_model.dart';
import 'package:flutter/material.dart';

class AIToolSharedData extends ChangeNotifier {
  // 数据是否有更新
  bool isUpdate = false;
  // 更新过的数据模型
  ConversationModel? updateModel;

  //数据更新方法(发送通知)
  void updateData(bool isUpdate, ConversationModel? updateModel) {
    this.isUpdate = isUpdate;
    this.updateModel = updateModel;
    // 通知监听状态的Widget进行更新
    notifyListeners();
  }
}

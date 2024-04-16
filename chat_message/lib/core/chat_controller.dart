import 'dart:async';

import 'package:chat_message/models/message_model.dart';
import 'package:flutter/cupertino.dart';

import '../widget/default_message_widget.dart';

class ChatController implements IChatController {
  ///初始化数据
  final List<MessageModel> initialMessageList;
  final ScrollController scrollController;
  //信息流控件
  final MessageWidgetBuilder? messageWidgetBuilder;

  ///展示时间的间隔，单位秒
  final int timePellet;
  List<int> pelletShow = [];

  ChatController(
      {required this.initialMessageList,
      required this.scrollController,
      required this.timePellet,
      this.messageWidgetBuilder}) {
    for (var message in initialMessageList.reversed) {
      inflateMessage(message);
    }
  }

  StreamController<List<MessageModel>> messageStreamController =
      StreamController();

  void dispose() {
    messageStreamController.close();
    scrollController.dispose();
  }

  void widgetReady() {
    if (!messageStreamController.isClosed) {
      messageStreamController.sink.add(initialMessageList);
    }
    if (initialMessageList.isNotEmpty) scrollToLastMessage();
  }

  void scrollToLastMessage() {
    if (!scrollController.hasClients) {
      return;
    }
    scrollController.animateTo(0,
        duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
  }

  @override
  void addMessage(MessageModel message) {
    if (messageStreamController.isClosed) return;
    inflateMessage(message);
    initialMessageList.insert(0, message);
    messageStreamController.sink.add(initialMessageList);
    scrollToLastMessage();
  }

  @override
  void deleteMessage(MessageModel message) {
    if (messageStreamController.isClosed) return;
    initialMessageList.remove(message);
    pelletShow.clear();
    for (var message in initialMessageList.reversed) {
      inflateMessage(message);
    }
    messageStreamController.sink.add(initialMessageList);
  }

  @override
  void loadMoreData(List<MessageModel> messageList) {
    messageList = List.from(messageList.reversed);
    List<MessageModel> tempList = [...initialMessageList, ...messageList];
    pelletShow.clear();
    for (var message in tempList.reversed) {
      inflateMessage(message);
    }
    initialMessageList.clear();
    initialMessageList.addAll(tempList);
    if (messageStreamController.isClosed) return;
    messageStreamController.sink.add(initialMessageList);
  }

  ///设置消息的时间是否可以展示
  void inflateMessage(MessageModel message) {
    int pellet = (message.createdAt / (timePellet * 1000)).truncate();
    if (!pelletShow.contains(pellet)) {
      pelletShow.add(pellet);
      message.showCreatedTime = true;
    } else {
      message.showCreatedTime = false;
    }
  }
}

abstract class IChatController {
  void addMessage(MessageModel message);
  void loadMoreData(List<MessageModel> messageList);
  void deleteMessage(MessageModel message);
}

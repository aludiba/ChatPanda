import 'package:chat_message/core/chat_controller.dart';
import 'package:chat_message/models/message_model.dart';
import 'package:flutter/material.dart';

import 'default_message_widget.dart';

class ChatList extends StatefulWidget {
  ///ChatList的控制器
  final ChatController chatController;
  final EdgeInsetsGeometry? padding;
  final OnBubbleClick? onBubbleTap;
  final OnBubbleClick? onBubbleLongPress;

  const ChatList(
      {super.key,
      required this.chatController,
      this.padding,
      this.onBubbleTap,
      this.onBubbleLongPress});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  ChatController get chatController => widget.chatController;
  MessageWidgetBuilder? get messageWidgetBuilder =>
      chatController.messageWidgetBuilder;
  ScrollController get scrollController => chatController.scrollController;
  Widget get _chatStreamBuilder => StreamBuilder<List<MessageModel>>(
        stream: chatController.messageStreamController.stream,
        builder:
            (BuildContext context, AsyncSnapshot<List<MessageModel>> snapshot) {
          return snapshot.connectionState == ConnectionState.active
              ? ListView.builder(
                  //配合shrinkWrap: true使用，解决数据少的时候数据底部对齐的问题
                  shrinkWrap: true,
                  reverse: true,
                  padding: widget.padding,
                  controller: scrollController,
                  itemCount: snapshot.data?.length ?? 0,
                  itemBuilder: (BuildContext context, int index) {
                    var model = snapshot.data![index];
                    return DefaultMessageWidget(
                      key: model.key,
                      message: model,
                      messageWidget: messageWidgetBuilder,
                      onBubbleTap: widget.onBubbleTap,
                      onBubbleLongPress: widget.onBubbleLongPress,
                    );
                    // }
                  })
              : const Center(
                  child: CircularProgressIndicator(),
                );
        },
      );

  @override
  Widget build(BuildContext context) {
    //配合shrinkWrap: true使用，解决数据少的时候数据底部对齐的问题
    return Align(
      alignment: Alignment.topCenter,
      child: _chatStreamBuilder,
    );
  }

  @override
  void initState() {
    super.initState();
    chatController.widgetReady();
  }

  @override
  void dispose() {
    chatController.dispose();
    super.dispose();
  }
}

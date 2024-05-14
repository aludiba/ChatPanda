import 'package:flutter/cupertino.dart';

enum OwnerType { receiver, sender }

///枚举类型在数据库保存为string，取出时转成枚举
OwnerType _of(String name) {
  if (name == OwnerType.receiver.toString()) {
    return OwnerType.receiver;
  } else {
    return OwnerType.sender;
  }
}

class MessageModel {
  ///数据库自增id
  final int? id;

  ///本轮对话的标识id(streamId)
  final String? streamId;

  ///为了避免添加数据的时候重新刷新的问题
  final GlobalKey key;

  ///消息发送方和接收方的标识，用于决定消息展示在哪一侧
  final OwnerType ownerType;

  ///消息发送方的名字
  final String? ownerName;

  ///头像url
  final String? avatar;

  ///消息内容
  final String content;

  ///milliseconds since
  final int createdAt;

  ///是否被收藏(设为"精彩")
  bool? isFavorite;

  ///是否在进行语言播报
  bool isVoiceing = false;

  ///是否展示创建时间
  bool showCreatedTime = false;

  MessageModel(
      {this.id, this.streamId, required this.ownerType, this.ownerName, this.avatar, this.isFavorite, required this.content, required this.createdAt})
      : key = GlobalKey();

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
      ownerType: _of(json['ownerType']),
      content: json['content'],
      createdAt: json['createdAt'],
      ownerName: json['ownerName'],
      avatar: json['avatar'],
      streamId: json['streamId'],
      isFavorite: json['isFavorite'] == 1,
      id: json['id']);

  Map<String, dynamic> toJson() => {
        'id': id,
        'streamId': streamId,
        //数据库存储不支持枚举等复合类型
        'ownerType': ownerType.toString(),
        'content': content,
        'createdAt': createdAt,
        'avatar': avatar,
        'ownerName': ownerName,
        'isFavorite': isFavorite
      };
}

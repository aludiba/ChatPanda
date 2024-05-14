import 'dart:convert';
import 'dart:typed_data';

import 'package:chat_message/util/wechat_date_format.dart';
import 'package:chatgpt_flutter/model/favorite_model.dart';
import 'package:chatgpt_flutter/util/padding_extension.dart';
import 'package:flutter/material.dart';
import 'package:openai_flutter/utils/ai_logger.dart';

typedef OnFavoriteImageClick = void Function(
    FavoriteImageModel model, BuildContext ancestor);

///收藏widget
class FavoriteImageWidget extends StatelessWidget {
  final FavoriteImageModel model;
  final OnFavoriteImageClick onTap;

  const FavoriteImageWidget(
      {Key? key, required this.model, required this.onTap})
      : super(key: key);

  get _titleView => Text(
        model.prompt ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      );

  get _bottomLayout => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            WechatDateFormat.format(model.updateAt!),
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          )
        ],
      );

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(model, context),
      child: Card(
        margin: const EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 5),
        child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _thumbnail(context),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_titleView, 20.paddingHeight, _bottomLayout],
                )
              ],
            )),
      ),
    );
  }

  Widget _thumbnail(BuildContext context) {
    String base64Str = model.base64 ?? '';
    try {
      Uint8List bytes = base64Decode(base64Str);
      return Container(
        margin: const EdgeInsets.only(right: 8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.memory(
            bytes,
            width: 65,
            height: 65,
            fit: BoxFit.cover, // 图片适应方式
          ),
        ),
      );
    } catch (e) {
      AILogger.log('Error decoding base64 image: $e');
      return Container();
    }
  }
}

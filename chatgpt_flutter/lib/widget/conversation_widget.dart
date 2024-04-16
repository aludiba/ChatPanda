import 'package:chat_message/util/wechat_date_format.dart';
import 'package:chatgpt_flutter/model/conversation_model.dart';
import 'package:chatgpt_flutter/util/padding_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../util/hi_dialog.dart';

///定义一个带有ConversationModel参数的回调
typedef ConversationCallBack = Function(ConversationModel model);
typedef ConversationStickCallBack = Function(ConversationModel model,
    {required bool isStick});

class ConversationWidget extends StatelessWidget {
  final ConversationModel model;
  final ConversationCallBack? onPressed;
  final ConversationCallBack? onDelete;
  final ConversationStickCallBack? onStick;

  const ConversationWidget(
      {super.key,
      required this.model,
      this.onPressed,
      this.onDelete,
      this.onStick});

  get _itemBackgroundColor =>
      model.stickTime > 0 ? Colors.grey.withOpacity(0.2) : Colors.white;

  get _icon => ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Image.network(model.icon, height: 50, width: 50),
      );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onPressed != null) onPressed!(model);
      },
      // onLongPress: () => _showPopMenu(context),
      child: Container(
        padding: const EdgeInsets.only(left: 10, right: 10),
        color: _itemBackgroundColor,
        height: 76,
        child: Row(
          children: [
            _icon,
            10.paddingWidth,
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    5.paddingHeight,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Text(
                          model.title ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 18),
                        )),
                        Text(
                          WechatDateFormat.format(model.updateAt ?? 0),
                          style:
                              const TextStyle(fontSize: 13, color: Colors.grey),
                        )
                      ],
                    ),
                    Text(
                      '[${model.messageCount}${AppLocalizations.of(context)!.dialogues}] ${model.lastMessage}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    )
                  ],
                ),
                Divider(
                  height: 1,
                  color: Colors.grey.withOpacity(0.6),
                )
              ],
            ))
          ],
        ),
      ),
    );
  }

  ///在item下方弹框，难点如何找到要弹框的坐标位置
  _showPopMenu(BuildContext context) {
    var isStick = model.stickTime > 0 ? true : false;
    var showStick = isStick
        ? AppLocalizations.of(context)!.untop
        : AppLocalizations.of(context)!.top;
    HiDialog.showPopMenu(context, offsetX: -50, items: [
      PopupMenuItem(
        child: Text(showStick),
        onTap: () {
          if (onStick != null) onStick!(model, isStick: !isStick);
        },
      ),
      PopupMenuItem(
        child: Text(AppLocalizations.of(context)!.delete),
        onTap: () {
          if (onDelete != null) onDelete!(model);
        },
      )
    ]);
  }
}

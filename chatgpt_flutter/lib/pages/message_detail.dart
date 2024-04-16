import 'package:chat_message/util/wechat_date_format.dart';
import 'package:chatgpt_flutter/model/favorite_model.dart';
import 'package:chatgpt_flutter/util/hi_selection_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

///展示精彩内容详情
class MessageDetailPage extends StatefulWidget {
  final FavoriteModel model;

  const MessageDetailPage({Key? key, required this.model}) : super(key: key);

  @override
  State<MessageDetailPage> createState() => _MessageDetailPageState();
}

class _MessageDetailPageState extends State<MessageDetailPage> {
  TapDownDetails? details;
  // 定义焦点节点
  late FocusNode _focusNode;

  get _titleView => Column(
        children: [
          Text(
            AppLocalizations.of(context)!.details,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            '${AppLocalizations.of(context)!.from} ${widget.model.ownerName} ${WechatDateFormat.formatYMd(widget.model.createdAt!)}',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      );

  get _listView => ListView(
        padding:
            const EdgeInsets.only(top: 20, bottom: 20, left: 15, right: 15),
        children: [_wrap],
      );

  get _wrap => HiSelectionAreaWidget(
        selectAll: true,
        copy: true,
        transpond: true,
        focusNode: _focusNode,
        child: Text(
          widget.model.content,
          style: const TextStyle(fontSize: 18),
        ),
      );

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    // 释放焦点节点
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _titleView,
      ),
      body: GestureDetector(
        onTap: () {
          // 点击空白区域时取消焦点
          _focusNode.unfocus();
        },
        child: _listView,
      ),
    );
  }
}

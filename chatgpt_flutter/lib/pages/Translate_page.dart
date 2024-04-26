import 'package:chatgpt_flutter/util/padding_extension.dart';
import 'package:flutter/material.dart';
import 'package:openai_flutter/utils/ai_logger.dart';

class TranslatePage extends StatefulWidget {
  const TranslatePage({super.key});

  @override
  State<TranslatePage> createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage>
    with AutomaticKeepAliveClientMixin {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          // 点击空白区域时取消焦点
          _focusNode.unfocus();
          _onSend();
        },
        child: Column(
          children: [
            60.paddingHeight, // 使用SizedBox来创建间距
            _languageSelectionArea(),
            // 20.paddingHeight, // 使用SizedBox来创建间距
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 20.0),
                itemCount: 2,
                itemBuilder: (BuildContext context, int index) =>
                    _translationArea(index),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 语种选择区域
  _languageSelectionArea() {
    return Container(
      height: 60,
      color: Colors.red,
    );
  }

  // 翻译区域
  _translationArea(int index) {
    if (index == 0) {
      return Padding(
          padding: const EdgeInsets.only(right: 8, bottom: 20, left: 8),
          child: Stack(
            children: [
              TextField(
                focusNode: _focusNode,
                controller: _controller,
                textInputAction: TextInputAction.done, // 设置回车键为确定操作
                //回车发送消息
                onSubmitted: (value) {
                  // 当用户点击确定时调用的回调函数
                  AILogger.log('Submitted: $value');
                  _onSend();
                },
                maxLines: null, // 或者设置为大于1的值，这样可以自动换行,
                decoration: const InputDecoration(
                  labelText: 'Enter your text',
                  border: OutlineInputBorder(),
                  // 增加右侧内边距
                  contentPadding: EdgeInsets.only(
                      top: 10.0, bottom: 10.0, left: 10.0, right: 20.0),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                  },
                ),
              )
            ],
          ));
    } else {
      return const Padding(
        padding: EdgeInsets.only(right: 8, left: 8),
        child: Text('已经翻译'),
      );
    }
  }

  // 键盘回车发送消息
  void _onSend() {
    _focusNode.unfocus();
    _onTranslate();
  }

  // TODO:去翻译
  void _onTranslate() {}
}

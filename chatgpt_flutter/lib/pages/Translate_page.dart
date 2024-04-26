import 'package:chatgpt_flutter/util/padding_extension.dart';
import 'package:flutter/material.dart';

class TranslatePage extends StatefulWidget {
  const TranslatePage({super.key});

  @override
  State<TranslatePage> createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage> {
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
        child: TextField(
          controller: _controller,
          maxLines: null, // 或者设置为大于1的值，这样可以自动换行,
          decoration: const InputDecoration(
            labelText: 'Enter your text',
            border: OutlineInputBorder(),
          ),
        ),
      );
    } else {
      return const Padding(
        padding: EdgeInsets.only(right: 8, left: 8),
        child: Text('已经翻译'),
      );
    }
  }
}

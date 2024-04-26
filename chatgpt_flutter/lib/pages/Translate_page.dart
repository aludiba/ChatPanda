import 'package:chatgpt_flutter/provider/theme_provider.dart';
import 'package:chatgpt_flutter/util/padding_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class TranslatePage extends StatefulWidget {
  const TranslatePage({super.key});

  @override
  State<TranslatePage> createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage>
    with AutomaticKeepAliveClientMixin {
  // 键盘焦点
  final FocusNode _focusNode = FocusNode();
  // 编辑框控制器
  final TextEditingController _controller = TextEditingController();
  // 左边选择的语言类型
  String? _selectedLeftValue;
  // 右边选择的语言类型
  String? _selectedRightValue;
  // 左下拉框数据
  late List<String> _dropdownLeftValues;
  // 右下拉框数据
  late List<String> _dropdownRightValues;
  get _themeColor => context.watch<ThemeProvider>().themeColor;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    // 设置左下拉框选项
    _dropdownLeftValues = [
      AppLocalizations.of(context)!.automaticDetection,
      AppLocalizations.of(context)!.english,
      AppLocalizations.of(context)!.simplifiedChinese,
      AppLocalizations.of(context)!.chineseTraditional,
      AppLocalizations.of(context)!.japanese,
      AppLocalizations.of(context)!.korean,
      AppLocalizations.of(context)!.spanishLanguage,
      AppLocalizations.of(context)!.portuguese,
      AppLocalizations.of(context)!.french
    ];
    // 设置右下拉框选项
    _dropdownRightValues = [
      AppLocalizations.of(context)!.english,
      AppLocalizations.of(context)!.simplifiedChinese,
      AppLocalizations.of(context)!.chineseTraditional,
      AppLocalizations.of(context)!.japanese,
      AppLocalizations.of(context)!.korean,
      AppLocalizations.of(context)!.spanishLanguage,
      AppLocalizations.of(context)!.portuguese,
      AppLocalizations.of(context)!.french
    ];
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
    return Row(
      children: [
        Flexible(
            flex: 1,
            child: _dropdownBtn(_dropdownLeftValues, _selectedLeftValue)),
        Column(
          children: [
            Icon(Icons.arrow_back, color: Colors.grey[400]), // 向左指的图标
            Icon(Icons.arrow_forward, color: Colors.grey[400]), // 向右指的图标
          ],
        ),
        Flexible(
            flex: 1,
            child: _dropdownBtn(_dropdownRightValues, _selectedRightValue))
      ],
    );
  }

  _dropdownBtn(List<String> dropdownValues, String? selectedValue) {
    return Padding(
        padding: const EdgeInsets.only(right: 8, left: 8),
        child: DropdownButtonFormField<String>(
          hint: Text(dropdownValues[0], style: const TextStyle(fontSize: 12)),
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            border: const OutlineInputBorder(),
            // 设置获得焦点时的边框颜色
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: _themeColor, // 设置为主题色
              ),
            ),
          ),
          onChanged: (newValue) {
            setState(() {
              selectedValue = newValue;
            });
          },
          items: dropdownValues.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(fontSize: 12)),
            );
          }).toList(),
        ));
  }

  // 翻译区域
  _translationArea(int index) {
    // 获取当前的主题数据
    final ThemeData currentTheme = Theme.of(context);
    if (index == 0) {
      return Theme(
          // 使用copyWith创建当前主题的副本并覆盖特定属性
          data: currentTheme.copyWith(
            inputDecorationTheme: currentTheme.inputDecorationTheme.copyWith(
              // 覆盖labelText获得焦点时的颜色
              floatingLabelStyle: TextStyle(color: _themeColor),
            ),
          ),
          // 仅此TextField的Theme被覆盖
          child: Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 20, left: 8),
              child: Stack(
                children: [
                  TextField(
                    focusNode: _focusNode,
                    controller: _controller,
                    textInputAction: TextInputAction.done, // 设置回车键为确定操作
                    //回车发送消息
                    onSubmitted: (value) {
                      _onSend();
                    },
                    maxLines: null, // 或者设置为大于1的值，这样可以自动换行,
                    textAlignVertical: TextAlignVertical.top, // 确保文字从上方开始
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.inputHint,
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey, // 常规状态下的颜色
                        ),
                      ),
                      // 设置获得焦点时的边框颜色
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: _themeColor, // 设置为主题色
                        ),
                      ),
                      // 增加右侧内边距
                      contentPadding: const EdgeInsets.fromLTRB(10, 20, 20, 20),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 0,
                    child: IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: _themeColor,
                      ),
                      onPressed: () {
                        _controller.clear();
                      },
                    ),
                  )
                ],
              )));
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

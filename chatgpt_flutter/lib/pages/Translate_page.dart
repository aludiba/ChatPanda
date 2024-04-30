import 'package:chatgpt_flutter/dao/completion_dao.dart';
import 'package:chatgpt_flutter/provider/theme_provider.dart';
import 'package:chatgpt_flutter/util/hi_const.dart';
import 'package:chatgpt_flutter/util/padding_extension.dart';
import 'package:chatgpt_flutter/util/preferences_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_langdetect/flutter_langdetect.dart' as langdetect;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:openai_flutter/utils/ai_logger.dart';
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
  get _themeProvider => context.watch<ThemeProvider>();
  get _themeColor => context.watch<ThemeProvider>().themeColor;
  late CompletionDao completionDao;
  // 是否等待翻译中
  bool _isWaitTranslation = false;
  // 已翻译文本
  String? _translatedText;
  // 语音播报对象
  FlutterTts flutterTts = FlutterTts();
  // 是否正在播报
  bool _isBroadcast = false;
  // 文心一言的accessToken
  late String accessToken;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initWenXinConfig();
  }

  void _initWenXinConfig() async {
    completionDao = CompletionDao();
    accessToken = (await PreferencesHelper.loadData(HiConst.accessToken))!;
    if (accessToken == '') {
      accessToken = await CompletionDao.getWenXinToken();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 设置左下拉框选项
    _dropdownLeftValues = [
      AppLocalizations.of(context)!.automaticDetection,
      AppLocalizations.of(context)!.english,
      AppLocalizations.of(context)!.simplifiedChinese,
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

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
    // 释放焦点节点
    _focusNode.dispose();
  }

  ///发送给文心一言进行翻译
  Future<String?> _onWenXinSend() async {
    _selectedRightValue ??= _dropdownRightValues[0];
    completionDao.resetChat();
    String? response = '';
    String inputMessage =
        '请把冒号后面的内容翻译成$_selectedRightValue:${_controller.text}';
    Locale locale = Localizations.localeOf(context);
    String languageCode = locale.languageCode;
    if (languageCode == 'en') {
      // 本地语言是英文
      inputMessage =
          'Please translate the content after the colon into $_selectedRightValue:${_controller.text}';
    }
    try {
      var map = await completionDao.createWenXinCompletions(
          accessToken: accessToken,
          prompt: inputMessage) as Map<String, dynamic>;
      if (map['errorCode'] != null) {
        if (map['errorCode'] == 110) {
          PreferencesHelper.saveData(HiConst.accessToken, '');
          _initWenXinConfig();
          _onWenXinSend();
          return null;
        }
      } else {
        response = map['content'];
        response = response?.replaceAll("**", "");
        return response;
      }
    } catch (e) {
      response = 'no response';
      AILogger.log('TranslatePage:$response');
      return null;
    }
  }

  // 语种选择区域
  _languageSelectionArea() {
    return Row(
      children: [
        Flexible(flex: 1, child: _dropdownBtn(_dropdownLeftValues, true)),
        Column(
          children: [
            Icon(Icons.arrow_back, color: Colors.grey[400]), // 向左指的图标
            Icon(Icons.arrow_forward, color: Colors.grey[400]), // 向右指的图标
          ],
        ),
        Flexible(flex: 1, child: _dropdownBtn(_dropdownRightValues, false)),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: InkWell(
            splashColor: Colors.transparent, // 水波纹颜色透明
            highlightColor: Colors.transparent, // 高亮颜色透明
            onTap: () {
              _focusNode.unfocus();
              _onTranslate();
            },
            child: Container(
              decoration: BoxDecoration(
                color: _themeColor, // 背景颜色
                borderRadius: BorderRadius.circular(4.0), // 圆角
              ),
              padding: const EdgeInsets.all(4.0),
              child: Text(AppLocalizations.of(context)!.translateForBtn,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 16)), // InkWell的子部件
            ),
          ),
        )
      ],
    );
  }

  _dropdownBtn(List<String> dropdownValues, bool isLeft) {
    return Padding(
        padding: const EdgeInsets.only(right: 8, left: 8),
        child: DropdownButtonFormField<String>(
          hint: Text(dropdownValues[0]),
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
              if (isLeft) {
                _selectedLeftValue = newValue;
              } else {
                _selectedRightValue = newValue;
              }
              _onTranslate();
            });
          },
          items: dropdownValues.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
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
                      // _isBroadcast = false;
                      // flutterTts.stop();
                    },
                    onChanged: (text) {
                      AILogger.log('Text changed: $text');
                      if (text == '') {
                        setState(() {
                          _translatedText = null;
                          _isBroadcast = false;
                          flutterTts.stop();
                        });
                      }
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
                      icon: Icon(Icons.clear, color: _themeColor),
                      onPressed: () {
                        setState(() {
                          _controller.clear();
                          _translatedText = null;
                          _isBroadcast = false;
                          flutterTts.stop();
                        });
                      },
                    ),
                  )
                ],
              )));
    } else {
      if (_controller.text != '') {
        return Padding(
          padding: const EdgeInsets.only(right: 8, left: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[350],
              borderRadius: BorderRadius.circular(4), // 设置圆角半径为10
            ),
            padding: const EdgeInsets.fromLTRB(6, 6, 6, 0),
            child: Column(
              children: [
                Text(
                  _isWaitTranslation
                      ? AppLocalizations.of(context)!.waitTranslation
                      : _translatedText ?? '',
                  style: TextStyle(color: _themeColor, fontSize: 16),
                  textAlign: TextAlign.left,
                ),
                Row(
                  children: [
                    Container(
                      width: _themeProvider.screenSize!.width - 66,
                    ),
                    Expanded(
                        child: IconButton(
                      icon: Icon(
                        Icons.volume_up,
                        color:
                            _isBroadcast == true ? Colors.black : _themeColor,
                        size: 16,
                      ),
                      onPressed:
                          !_isBroadcast ? _broadcastTranslatedText : null,
                    ))
                  ],
                )
              ],
            ),
          ),
        );
      } else {
        return Container();
      }
    }
  }

  // 键盘回车发送消息
  void _onSend() {
    _focusNode.unfocus();
    _onTranslate();
  }

  // 翻译
  void _onTranslate() async {
    if (_controller.text != '') {
      setState(() {
        _isWaitTranslation = true;
        _isBroadcast = true;
      });
      _translatedText = await _onWenXinSend();
      setState(() {
        _isWaitTranslation = false;
        _isBroadcast = false;
      });
    }
  }

  // 播报已翻译文本
  _broadcastTranslatedText() {
    /// 语音播报开始
    flutterTts.startHandler = () {
      setState(() {});
    };

    /// 语音播报完成
    flutterTts.completionHandler = () {
      setState(() {
        _isBroadcast = false;
      });
    };

    /// 语音播报报错
    flutterTts.errorHandler = (dynamic message) {
      setState(() {
        _isBroadcast = false;
      });
    };

    _listenMessage();
  }

  //语音播报
  Future _listenMessage() async {
    _isBroadcast = true;
    await langdetect.initLangDetect();
    final language = langdetect.detect(_translatedText ?? '');
    await flutterTts.setLanguage(language); // 设置语言，可以根据需要更改
    await flutterTts.setPitch(1.0); // 设置音调，1.0为正常音调
    await flutterTts.speak(_translatedText ?? '');
  }
}

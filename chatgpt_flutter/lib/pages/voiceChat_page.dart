import 'package:chat_message/models/message_model.dart';
import 'package:chatgpt_flutter/dao/completion_dao.dart';
import 'package:chatgpt_flutter/provider/theme_provider.dart';
import 'package:chatgpt_flutter/util/hi_const.dart';
import 'package:chatgpt_flutter/util/padding_extension.dart';
import 'package:chatgpt_flutter/util/preferences_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_langdetect/flutter_langdetect.dart' as langdetect;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:openai_flutter/http/ai_config.dart';
import 'package:openai_flutter/utils/ai_logger.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceChatPage extends StatefulWidget {
  final String? title;

  const VoiceChatPage({super.key, this.title});

  @override
  State<VoiceChatPage> createState() => _VoiceChatPageState();
}

class _VoiceChatPageState extends State<VoiceChatPage>
    with TickerProviderStateMixin {
  late String speakTips = AppLocalizations.of(context)!.longPressSpeak;
  String speakResult = '';

  /// 等待ChatPanda会话提示语
  String speakWait = '';

  /// 是否正在播报中
  bool _speakIng = false;

  /// 播报动画
  late Animation<double> voiceAnimation;

  /// 播报动画控制器
  late AnimationController voiceController;

  /// 语音输入动画
  late Animation<double> animation;

  /// 语音输入动画控制器
  late AnimationController controller;

  get _themeColor => context.watch<ThemeProvider>().themeColor;

  late stt.SpeechToText _speech;

  late CompletionDao completionDao;
  // 文心一言的accessToken
  late String accessToken;
  // 语音播报对象
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    voiceController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    voiceAnimation =
        CurvedAnimation(parent: voiceController, curve: Curves.easeIn)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              voiceController.reverse();
            } else if (status == AnimationStatus.dismissed) {
              voiceController.forward();
            }
          });

    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    animation = CurvedAnimation(parent: controller, curve: Curves.easeIn)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          controller.forward();
        }
      });
    super.initState();
    _doInit();
    _initConfig();
    _initWenXinConfig();
  }

  void _initConfig() {
    // String? cacheKey = HiCache.getInstance().get(HiConst.keyOpenAi);
    // AIConfigBuilder.init(cacheKey ?? '');
    // 先默认内置，暂时不设置密钥
    AIConfigBuilder.init('');
  }

  _initWenXinConfig() async {
    accessToken = (await PreferencesHelper.loadData(HiConst.accessToken))!;
    AILogger.log('PreferencesHelper_accessToken:$accessToken');
    if (accessToken == '') {
      accessToken = await CompletionDao.getWenXinToken();
      AILogger.log('getWenXinToken_accessToken:$accessToken');
    }
  }

  void _doInit() async {
    _speech = stt.SpeechToText();
    completionDao = CompletionDao(messages: []);

    /// 语音播报开始
    flutterTts.startHandler = () {
      speakWait = '';
      setState(() {});
    };

    /// 语音播报完成
    flutterTts.completionHandler = () {
      setState(() {
        _speakIng = false;
        voiceController.reset();
        voiceController.stop();
        speakTips = AppLocalizations.of(context)!.longPressSpeak;
      });
    };

    /// 语音播报报错
    flutterTts.errorHandler = (dynamic message) {
      setState(() {
        _speakIng = false;
        voiceController.reset();
        voiceController.stop();
        speakTips = AppLocalizations.of(context)!.longPressSpeak;
      });
    };
  }

  @override
  void dispose() {
    voiceController.dispose();
    controller.dispose();
    super.dispose();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(30),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[_topItem(context), _bottomItem()],
          ),
        ),
      ),
    );
  }

  _speakStart() {
    controller.forward();
    setState(() {
      speakTips = AppLocalizations.of(context)!.identifying;
    });
    _listen();
  }

  void _listen() async {
    bool available = await _speech.initialize(
      onStatus: (val) => AILogger.log('speech-onStatus: $val'),
      onError: (val) => AILogger.log('speech-onError: $val'),
    );
    if (available) {
      _speech.listen(
        onResult: (val) => setState(() {
          speakResult = val.recognizedWords;
        }),
      );
    }
  }

  _speakStop() {
    _speakIng = true;
    setState(() {
      speakTips = AppLocalizations.of(context)!.temporarilyUnrecognizable;
    });
    controller.reset();
    controller.stop();
    // AsrManager.stop();
    _speech.stop();
    // _sendForChat(speakResult);
    _sendForWenXin(speakResult);
  }

  /// 向ChatPanda发起对话
  void _sendForChat(final String inputMessage) async {
    setState(() {
      speakWait = 'waiting......';
    });
    voiceController.forward();
    String? response = "";
    try {
      response = await completionDao.createCompletions(prompt: inputMessage);
      response = response?.replaceFirst("\n\n", "");
    } catch (e) {
      response = 'no response';
      debugPrint(e.toString());
    }
    response ??= 'no response';
    _listenMessage(
        _genMessageModel(ownerType: OwnerType.receiver, message: response));
  }

  /// 向文心一言发起对话
  void _sendForWenXin(final String inputMessage) async {
    setState(() {
      speakWait = 'waiting......';
    });
    voiceController.forward();
    String? response = "";
    try {
      var map = await completionDao.createWenXinCompletions(
          accessToken: accessToken,
          prompt: inputMessage) as Map<String, dynamic>;
      if (map['errorCode'] != null) {
        if (map['errorCode'] == 110) {
          PreferencesHelper.saveData(HiConst.accessToken, '');
          _initWenXinConfig();
          _sendForWenXin(inputMessage);
          return;
        }
      } else {
        response = map['content'];
        response = response?.replaceAll("**", "");
        debugPrint('WenXinVoice:$response');
      }
    } catch (e) {
      response = 'no response';
    }
    response ??= 'no response';
    _listenMessage(
        _genMessageModel(ownerType: OwnerType.receiver, message: response));
  }

  //语音播报
  Future _listenMessage(MessageModel message) async {
    await langdetect.initLangDetect();
    final language = langdetect.detect(message.content);
    await flutterTts.setLanguage(language); // 设置语言，可以根据需要更改
    await flutterTts.setPitch(1.0); // 设置音调，1.0为正常音调
    await flutterTts.speak(message.content);
  }

  MessageModel _genMessageModel(
      {required OwnerType ownerType, required String message}) {
    return MessageModel(
        ownerType: ownerType,
        content: message,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        avatar: '',
        ownerName: 'ChatGPT');
  }

  _topItem(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
            padding: const EdgeInsets.fromLTRB(0, 30, 0, 30),
            child: Text(AppLocalizations.of(context)!.asYouMightSay,
                style: const TextStyle(fontSize: 16, color: Colors.black54))),
        Text(AppLocalizations.of(context)!.speakExample,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.grey,
            )),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            speakWait,
            style: TextStyle(color: _themeColor),
          ),
        ),
        Center(
          child: Column(
            children: <Widget>[
              10.paddingHeight,
              Stack(
                children: <Widget>[
                  const SizedBox(
                    //占坑，避免动画执行过程中导致父布局大小变得
                    height: MIC_SIZE,
                    width: MIC_SIZE,
                  ),
                  Center(
                    child: AnimatedMic(
                        title: AppLocalizations.of(context)!.chatPanda,
                        voiceAnimation),
                  )
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  _bottomItem() {
    return FractionallySizedBox(
      widthFactor: 1,
      child: Stack(
        children: <Widget>[
          GestureDetector(
            onTapDown: _speakIng == false
                ? (e) {
                    _speakStart();
                  }
                : null,
            onTapUp: _speakIng == false
                ? (e) {
                    _speakStop();
                  }
                : null,
            onTapCancel: _speakIng == false
                ? () {
                    _speakStop();
                  }
                : null,
            child: Center(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      speakTips,
                      style: TextStyle(color: _themeColor, fontSize: 12),
                    ),
                  ),
                  Stack(
                    children: <Widget>[
                      const SizedBox(
                        //占坑，避免动画执行过程中导致父布局大小变得
                        height: MIC_SIZE,
                        width: MIC_SIZE,
                      ),
                      Center(
                        child: AnimatedMic(
                          iconData: Icons.mic,
                          animation,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.close,
                size: 30,
                color: Colors.grey,
              ),
            ),
          )
        ],
      ),
    );
  }
}

const double MIC_SIZE = 160;

class AnimatedMic extends AnimatedWidget {
  static final _opacityTween = Tween<double>(begin: 1, end: 0.5);
  static final _sizeTween = Tween<double>(begin: MIC_SIZE, end: MIC_SIZE - 20);
  final IconData? iconData;
  final String? title;

  const AnimatedMic(Animation<double> animation,
      {Key? key, this.iconData, this.title})
      : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable as Animation<double>;
    return Opacity(
      opacity: _opacityTween.evaluate(animation),
      child: Container(
          height: _sizeTween.evaluate(animation),
          width: _sizeTween.evaluate(animation),
          decoration: BoxDecoration(
            color: context.watch<ThemeProvider>().themeColor,
            borderRadius: BorderRadius.circular(MIC_SIZE / 2),
          ),
          child: Center(
            child: (title != null && title!.isNotEmpty)
                ? Text(
                    title!,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  )
                : Icon(
                    iconData,
                    color: Colors.white,
                    size: 60,
                  ),
          )),
    );
  }
}

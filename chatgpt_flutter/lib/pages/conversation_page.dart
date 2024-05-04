import 'package:bubble/bubble.dart';
import 'package:chat_message/core/chat_controller.dart';
import 'package:chat_message/models/message_model.dart';
import 'package:chat_message/util/wechat_date_format.dart';
import 'package:chat_message/widget/chat_list_widget.dart';
import 'package:chatgpt_flutter/dao/completion_dao.dart';
import 'package:chatgpt_flutter/db/favorite_dao.dart';
import 'package:chatgpt_flutter/db/hi_db_manager.dart';
import 'package:chatgpt_flutter/db/message_dao.dart';
import 'package:chatgpt_flutter/model/aiTool_model.dart';
import 'package:chatgpt_flutter/model/conversation_model.dart';
import 'package:chatgpt_flutter/model/favorite_model.dart';
import 'package:chatgpt_flutter/provider/theme_provider.dart';
import 'package:chatgpt_flutter/util/aimapping_utils.dart';
import 'package:chatgpt_flutter/util/hi_const.dart';
import 'package:chatgpt_flutter/util/hi_dialog.dart';
import 'package:chatgpt_flutter/util/hi_selection_area.dart';
import 'package:chatgpt_flutter/util/padding_extension.dart';
import 'package:chatgpt_flutter/util/preferences_helper.dart';
import 'package:chatgpt_flutter/widget/message_input_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_langdetect/flutter_langdetect.dart' as langdetect;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:openai_flutter/http/ai_config.dart';
import 'package:openai_flutter/utils/ai_logger.dart';
import 'package:provider/provider.dart';

typedef OnConversationUpdate = void Function(
    ConversationModel conversationModel);

///聊天对话框页面
class ConversationPage extends StatefulWidget {
  final ConversationModel conversationModel;
  final OnConversationUpdate? conversationUpdate;
  // 是否是AI工具
  final bool? isAITool;
  // AI工具的数据模型
  final AIToolSubModel? aiToolModel;

  const ConversationPage(
      {super.key,
      required this.conversationModel,
      this.conversationUpdate,
      this.isAITool,
      this.aiToolModel});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  ///若为新建的对话框，则_pendingUpdate为true
  bool get _pendingUpdate => widget.conversationModel.title == null;
  // 是否有通知聊天列表页更新当前会话
  bool _hadUpdate = false;
  // late Map<String, dynamic> userInfo;
  String _inputMessage = '';
  bool _sendBtnEnable = true;
  // 语音播报对象
  FlutterTts flutterTts = FlutterTts();
  // 是否正在播报
  bool _isBroadcast = false;
  // 文心一言的accessToken
  late String accessToken;
  late MessageDao messageDao;
  late FavoriteDao favoriteDao;
  late ChatController chatController;
  final ScrollController _scrollController = ScrollController();
  late CompletionDao completionDao;
  // 定义焦点节点
  late FocusNode _focusNode;
  // 标题
  late String _title;

  get _aiRole => Padding(
      padding: const EdgeInsets.only(top: 6, right: 30, bottom: 6, left: 30),
      child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: const BorderRadius.all(Radius.circular(6)),
          ),
          child: Text(
            AIMappingToLocalize.getAITitleDesc(
                context, widget.aiToolModel?.description),
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black),
          )));

  get _chatList => Expanded(
          child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: ChatList(chatController: chatController),
      ));

  get _inputWidget {
    return MessageInputWidget(
      hint: AppLocalizations.of(context)!.pleaseEnter,
      enable: _sendBtnEnable,
      onChanged: (text) => _inputMessage = text,
      // onSend: () => _onSend(_inputMessage),
      onSend: () => _onWenXinSend(_inputMessage),
    );
  }

  get _themeColor => context.watch<ThemeProvider>().themeColor;

  get _refreshStream => Container(
        padding: const EdgeInsets.only(right: 10),
        child: InkWell(
          splashColor: Colors.transparent, // 水波纹颜色透明
          highlightColor: Colors.transparent, // 高亮颜色透明
          onTap: () {
            completionDao.resetChat();
            HiDialog.showSnackBar(
                context, AppLocalizations.of(context)!.topicReset);
          },
          child: const Icon(Icons.refresh, size: 30),
        ),
      );

  @override
  void initState() {
    super.initState();
    _doInit();
    _initConfig();
    _initWenXinConfig();
  }

  @override
  void dispose() {
    _updateConversation();
    super.dispose();
    flutterTts.stop();
    // 释放焦点节点
    _focusNode.dispose();
  }

  // 创建主视图
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: GestureDetector(
        onTap: () {
          // 点击空白区域时取消焦点
          _focusNode.unfocus();
        },
        child: Column(
          children: widget.isAITool == true
              ? [_aiRole, _chatList, _inputWidget]
              : [_chatList, _inputWidget],
        ),
      ),
    );
  }

  getTitle() {
    var title = AIMappingToLocalize.getAITitleDesc(
        context, widget.aiToolModel?.descTitle);
    if (title == '') {
      title = AppLocalizations.of(context)!.conversationWithChatPanda;
    }
    _title = _sendBtnEnable
        ? title
        : AppLocalizations.of(context)!.theOtherPartyIsTyping;
  }

  AppBar appBar() {
    getTitle();
    return AppBar(
      title: Text(_title),
      actions: [_refreshStream],
    );
  }

  ///不用_inputMessage是因为在结果回来之前_inputMessage可能会变
  ///发送给ChatGPT
  void _onSend(String inputMessage) async {
    widget.conversationModel.hadChanged = true;
    if (widget.isAITool == true &&
        completionDao.conversationContextHelper.conversationList.isEmpty) {
      String str = AIMappingToLocalize.getAITitleDesc(
          context, widget.aiToolModel?.description);
      inputMessage = '$str\n$inputMessage';
    }
    _addMessage(
        _genMessageModel(ownerType: OwnerType.sender, message: inputMessage));
    setState(() {
      _sendBtnEnable = false;
    });
    String? response = '';
    try {
      response = await completionDao.createCompletions(prompt: inputMessage);
    } catch (e) {
      response = 'no response';
    }
    response ??= 'no response';
    _addMessage(
        _genMessageModel(ownerType: OwnerType.receiver, message: response));
    setState(() {
      _sendBtnEnable = true;
    });
  }

  ///发送给文心一言
  void _onWenXinSend(String inputMessage) async {
    widget.conversationModel.hadChanged = true;
    if (widget.isAITool == true &&
        completionDao.conversationContextHelper.conversationList.isEmpty) {
      String str = AIMappingToLocalize.getAITitleDesc(
          context, widget.aiToolModel?.description);
      inputMessage = '$str\n$inputMessage';
    }
    _addMessage(
        _genMessageModel(ownerType: OwnerType.sender, message: inputMessage));
    setState(() {
      _sendBtnEnable = false;
    });
    String? response = '';
    try {
      var map = await completionDao.createWenXinCompletions(
          accessToken: accessToken,
          prompt: inputMessage) as Map<String, dynamic>;
      if (map['errorCode'] != null) {
        AILogger.log('accessToken过期errorCode:${map['errorCode']}');
        if (map['errorCode'] == 110) {
          PreferencesHelper.saveData(HiConst.accessToken, '');
          _initWenXinConfig();
          _onWenXinSend(inputMessage);
          return;
        }
      } else {
        response = map['content'];
        response = response?.replaceAll("**", "");
      }
    } catch (e) {
      response = 'no response';
    }
    response ??= 'no response';
    _addMessage(
        _genMessageModel(ownerType: OwnerType.receiver, message: response));
    setState(() {
      _sendBtnEnable = true;
    });
  }

  ///通知聊天列表页更新当前会话
  _notifyConversationListUpdate() {
    if (!_hadUpdate && _pendingUpdate && widget.conversationUpdate != null) {
      _hadUpdate = true;
      _updateConversation();
      widget.conversationUpdate!(widget.conversationModel);
    }
  }

  @override
  void setState(VoidCallback fn) {
    // 页面关闭后不再处理消息更新
    if (!mounted) {
      return;
    }
    super.setState(fn);
  }

  MessageModel _genMessageModel(
      {required OwnerType ownerType, required String message}) {
    return MessageModel(
        ownerType: ownerType,
        content: message,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        avatar:
            'https://5b0988e595225.cdn.sohucs.com/images/20200305/198ecedb2023459fa21831804a3162b0.jpeg',
        ownerName: 'ChatPanda');
  }

  void _initConfig() {
    // String? cacheKey = HiCache.getInstance().get(HiConst.keyOpenAi);
    // AIConfigBuilder.init(cacheKey ?? '');
    // 先默认内置,暂时不设置密钥
    AIConfigBuilder.init('');
  }

  void _initWenXinConfig() async {
    accessToken = (await PreferencesHelper.loadData(HiConst.accessToken))!;
    if (accessToken == '') {
      accessToken = await CompletionDao.getWenXinToken();
    }
  }

  //初始化
  void _doInit() async {
    // userInfo = LoginDao.getUserInfo()!;
    chatController = ChatController(
        initialMessageList: [],
        scrollController: _scrollController,
        messageWidgetBuilder: _messageWidget,
        timePellet: 60);
    //下拉触发加载更多
    _scrollController.addListener(() {
      // 滚动到顶部
      if (_scrollController.offset ==
              _scrollController.position.minScrollExtent &&
          !_scrollController.position.outOfRange) {
        setState(() {});
      } else {
        setState(() {});
      }
      // 滚动到底部
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMore(loadMore: true);
      }
    });
    var dbManager =
        await HiDBManager.instance(dbName: HiDBManager.getAccountHash());
    messageDao = MessageDao(dbManager, cid: widget.conversationModel.cid);
    favoriteDao = FavoriteDao(dbManager);
    var list = await _loadMore();
    chatController.loadMoreData(list);
    completionDao = CompletionDao(messages: list);
    _focusNode = FocusNode();
  }

  void _addMessage(MessageModel model) {
    chatController.addMessage(model);
    messageDao.saveMessage(model);
    _notifyConversationListUpdate();
  }

  int pageIndex = 1;

  ///从数据库加载历史聊天记录
  Future<List<MessageModel>> _loadMore({loadMore = false}) async {
    if (loadMore) {
      pageIndex++;
    } else {
      pageIndex = 1;
    }
    var list = await messageDao.getMessages(pageIndex: pageIndex);
    if (loadMore) {
      if (list.isNotEmpty) {
        chatController.loadMoreData(list);
      } else {
        //如果没有更多的数据，则pageIndex不增加
        pageIndex--;
      }
    }
    return list;
  }

  void _updateConversation() {
    //更新会话信息
    if (chatController.initialMessageList.isNotEmpty) {
      var model = chatController.initialMessageList.first;
      widget.conversationModel.lastMessage = model.content;
      widget.conversationModel.updateAt = model.createdAt;
      widget.conversationModel.title ??=
          chatController.initialMessageList.last.content ?? '';
    }
  }

  //设为"精彩"
  void _addFavorite(MessageModel message) async {
    var result = await favoriteDao.addFavorite(FavoriteModel(
        id: message.id,
        cid: widget.conversationModel.cid,
        ownerName: message.ownerName,
        createdAt: message.createdAt,
        content: message.content));
    var showText = '';
    if (result != null && result > 0) {
      message.isFavorite = true;
      messageDao.update(message);
      showText = AppLocalizations.of(context)!.successfulCollection;
    } else {
      showText = AppLocalizations.of(context)!.collectionFailure;
    }
    if (!mounted) return;
    HiDialog.showSnackBar(context, showText);
    setState(() {});
  }

  //取消"精彩"
  void _removeFavorite(MessageModel message) async {
    var result = await favoriteDao.removeFavorite(FavoriteModel(
        id: message.id,
        cid: widget.conversationModel.cid,
        ownerName: message.ownerName,
        createdAt: message.createdAt,
        content: message.content));
    var showText = '';
    if (result != null && result > 0) {
      message.isFavorite = false;
      messageDao.update(message);
      showText = AppLocalizations.of(context)!.unSuccessfulCollection;
    } else {
      showText = AppLocalizations.of(context)!.unCollectionFailure;
    }
    if (!mounted) return;
    HiDialog.showSnackBar(context, showText);
    setState(() {});
  }

  //信息行控件
  Widget _messageWidget(MessageModel message) {
    Widget content = message.ownerType == OwnerType.receiver
        ? _buildReceiver(message, context)
        : _buildSender(message, context);
    return Column(
      children: [
        if (message.showCreatedTime) _buildCreatedTime(message),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: content,
        )
      ],
    );
  }

  //接收行控件
  _buildReceiver(MessageModel message, BuildContext context) {
    Widget receiverWidget;
    if (message.content == 'no response') {
      ///报错情况下的显示
      receiverWidget = Text(AppLocalizations.of(context)!.apologyTips,
          style: const TextStyle(fontSize: 16, color: Colors.black));
    } else {
      receiverWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildContentText(message, TextAlign.left, context),
          _menuItem(message)
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ClipOval(child: Icon(Icons.assistant, size: 40, color: _themeColor)),
        Flexible(
            child: Bubble(
                margin: const BubbleEdges.fromLTRB(10, 0, 50, 0),
                stick: true,
                nip: BubbleNip.leftTop,
                color: const Color.fromRGBO(233, 233, 252, 19),
                alignment: Alignment.topLeft,
                child: receiverWidget))
      ],
    );
  }

  //发送行控件
  _buildSender(MessageModel message, BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
            child: Bubble(
          margin: const BubbleEdges.fromLTRB(50, 0, 10, 0),
          stick: true,
          nip: BubbleNip.rightTop,
          color: Colors.white,
          alignment: Alignment.topRight,
          child: _buildContentText(message, TextAlign.left, context),
        )),
      ],
    );
  }

  _buildContentText(
      MessageModel message, TextAlign align, BuildContext context) {
    String sendMessage = message.content;
    if (widget.isAITool == true) {
      String description = AIMappingToLocalize.getAITitleDesc(
          context, widget.aiToolModel?.description);
      if (sendMessage.contains(description)) {
        sendMessage = sendMessage.replaceAll('$description\n', '');
      }
    }
    return InkWell(
      child: HiSelectionAreaWidget(
        selectAll: true,
        copy: true,
        transpond: true,
        focusNode: _focusNode,
        child: Text(
          sendMessage,
          textAlign: align,
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
      ),
    );
  }

  _buildCreatedTime(MessageModel message) {
    String showT = WechatDateFormat.format(message.createdAt, dayOnly: false);
    return Container(
      padding: const EdgeInsets.only(top: 10),
      child: Text(showT),
    );
  }

  _menuItem(MessageModel message) {
    bool isFavorite = false;
    if (message.isFavorite != null) {
      isFavorite = message.isFavorite!;
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(0.0, 6.0, 0.0, 6.0),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ..._actionItem(
              isEnable: true,
              actionTap: () {
                if (isFavorite) {
                  _removeFavorite(message);
                } else {
                  _addFavorite(message);
                }
              },
              icon: Icon(Icons.favorite,
                  color: isFavorite
                      ? Colors.red
                      : const Color.fromRGBO(233, 233, 252, 19),
                  size: 15),
              text: isFavorite
                  ? AppLocalizations.of(context)!.cancelWonderful
                  : AppLocalizations.of(context)!.setAsWonderful),
          ..._actionItem(
              isEnable: !_isBroadcast,
              actionTap: () {
                /// 语音播报开始
                flutterTts.startHandler = () {
                  setState(() {
                    message.isVoiceing = true;
                  });
                };

                /// 语音播报完成
                flutterTts.completionHandler = () {
                  setState(() {
                    message.isVoiceing = false;
                    _isBroadcast = false;
                  });
                };

                /// 语音播报报错
                flutterTts.errorHandler = (dynamic message) {
                  setState(() {
                    message.isVoiceing = false;
                    _isBroadcast = false;
                  });
                };

                ///没有其它段落在播报时才可执行
                _listenMessage(message);
              },
              icon: Icon(Icons.voice_chat,
                  color: message.isVoiceing == true
                      ? Colors.black
                      : const Color.fromRGBO(233, 233, 252, 19),
                  size: 15),
              text: AppLocalizations.of(context)!.listen),
        ],
      ),
    );
  }

  _actionItem(
          {GestureTapCallback? actionTap,
          required bool isEnable,
          required Icon icon,
          required String text}) =>
      [
        Container(
          decoration: BoxDecoration(
            color: Colors.cyan,
            borderRadius: BorderRadius.circular(4.0), // 设置圆角半径
          ),
          child: InkWell(
            onTap: isEnable ? actionTap : null,
            child: Row(
              children: [
                4.paddingWidth,
                icon,
                Text(text,
                    style: const TextStyle(fontSize: 14, color: Colors.white)),
                4.paddingWidth
              ],
            ),
          ),
        ),
        4.paddingWidth
      ];

  //语音播报
  Future _listenMessage(MessageModel message) async {
    _isBroadcast = true;
    await langdetect.initLangDetect();
    final language = langdetect.detect(message.content);
    await flutterTts.setLanguage(language); // 设置语言，可以根据需要更改
    await flutterTts.setPitch(1.0); // 设置音调，1.0为正常音调
    await flutterTts.speak(message.content);
  }
}

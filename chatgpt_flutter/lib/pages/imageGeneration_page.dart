import 'dart:convert';
import 'dart:typed_data';

import 'package:bubble/bubble.dart';
import 'package:chat_message/util/wechat_date_format.dart';
import 'package:chatgpt_flutter/controller/image_controller.dart';
import 'package:chatgpt_flutter/dao/completion_dao.dart';
import 'package:chatgpt_flutter/db/hi_db_manager.dart';
import 'package:chatgpt_flutter/db/image_dao.dart';
import 'package:chatgpt_flutter/model/imageGeneration_model.dart';
import 'package:chatgpt_flutter/provider/theme_provider.dart';
import 'package:chatgpt_flutter/util/hi_const.dart';
import 'package:chatgpt_flutter/util/hi_dialog.dart';
import 'package:chatgpt_flutter/util/preferences_helper.dart';
import 'package:chatgpt_flutter/widget/image_list_widget.dart';
import 'package:chatgpt_flutter/widget/message_input_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openai_flutter/utils/ai_logger.dart';
import 'package:provider/provider.dart';

class ImageGenerationPage extends StatefulWidget {
  final String? title;

  const ImageGenerationPage({super.key, this.title});

  @override
  State<ImageGenerationPage> createState() => _ImageGenerationPageState();
}

class _ImageGenerationPageState extends State<ImageGenerationPage> {
  // 数据，类型为一个数组
  late List<ImageGenerationModel> _data;
  // 当前输入的提示词
  String _inputMessage = '';
  bool _sendBtnEnable = true;
  // 文心一言的accessToken
  late String accessToken;
  late ImageDao imageDao;
  late CompletionDao completionDao;
  late ImageGenerationController imageGenerationController;
  final ScrollController _scrollController = ScrollController();
  // 标题
  late String _title;

  get _themeColor => context.watch<ThemeProvider>().themeColor;

  get _imageList => Expanded(
          child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: ImageList(imageController: imageGenerationController),
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

  // 删除所有图片
  get _cleanStream => Container(
        padding: const EdgeInsets.only(right: 10),
        child: InkWell(
          splashColor: Colors.transparent, // 水波纹颜色透明
          highlightColor: Colors.transparent, // 高亮颜色透明
          onTap: () {
            setState(() {
              // 删除所有数据
              imageDao.deleteAllImages();
              imageGenerationController.initialImageList.clear();
            });
            HiDialog.showSnackBar(
                context, AppLocalizations.of(context)!.haveEmptied);
          },
          child: const Icon(Icons.cleaning_services, size: 30),
        ),
      );

  @override
  void initState() {
    super.initState();
    _doInit();
    _initWenXinConfig();
  }

  @override
  void setState(VoidCallback fn) {
    // 页面关闭后不再处理消息更新
    if (!mounted) {
      return;
    }
    super.setState(fn);
  }

  void _doInit() async {
    imageGenerationController = ImageGenerationController(
        initialImageList: [],
        scrollController: _scrollController,
        imageWidgetBuilder: _imageWidget,
        timePellet: 60);
    //下拉触发加载更多
    _scrollController.addListener(() {
      // 滚动到顶部
      // if (_scrollController.offset ==
      //         _scrollController.position.minScrollExtent &&
      //     !_scrollController.position.outOfRange) {
      //   setState(() {});
      // } else {
      //   setState(() {});
      // }
      AILogger.log('scrollController-offset:${_scrollController.offset}');
      // 滚动到底部
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMore(loadMore: true);
      }
    });
    var dbManager =
        await HiDBManager.instance(dbName: HiDBManager.getAccountHash());
    imageDao = ImageDao(dbManager);
    var list = await _loadMore();
    imageGenerationController.loadMoreData(list);
    completionDao = CompletionDao();
  }

  void _initWenXinConfig() async {
    accessToken = (await PreferencesHelper.loadData(HiConst.accessToken))!;
    if (accessToken == '') {
      accessToken = await CompletionDao.getWenXinToken();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: Column(children: [_imageList, _inputWidget]),
    );
  }

  _buildCreatedTime(ImageGenerationModel image) {
    String showT = WechatDateFormat.format(image.updateAt, dayOnly: false);
    return Container(
      padding: const EdgeInsets.only(top: 10),
      child: Text(showT),
    );
  }

  _buildContentImage(
      ImageGenerationModel imageModel, TextAlign left, BuildContext context) {
    String base64Str = imageModel.base64 ?? '';
    try {
      Uint8List bytes = base64Decode(base64Str);
      Widget imageWidget = Image.memory(bytes);
      return Column(
        children: [
          Text(imageModel.prompt ?? '', style: TextStyle(color: _themeColor)),
          imageWidget
        ],
      );
    } catch (e) {
      AILogger.log('Error decoding base64 image: $e');
    }
  }

  // 图片框控件
  _buildContent(ImageGenerationModel image, BuildContext context) {
    Widget receiverWidget;
    if (image.base64 == 'no response') {
      ///报错情况下的显示
      receiverWidget = Text(AppLocalizations.of(context)!.apologyTips,
          style: const TextStyle(fontSize: 16, color: Colors.black));
    } else {
      receiverWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildContentImage(image, TextAlign.left, context),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ClipOval(child: Icon(Icons.image, size: 40, color: _themeColor)),
        Flexible(
            child: Bubble(
                margin: const BubbleEdges.fromLTRB(10, 0, 50, 0),
                stick: true,
                nip: BubbleNip.leftTop,
                color: Colors.white,
                alignment: Alignment.topLeft,
                child: receiverWidget))
      ],
    );
  }

  Widget _imageWidget(ImageGenerationModel image) {
    return Column(
      children: [
        if (image.showCreatedTime) _buildCreatedTime(image),
        Padding(
            padding: const EdgeInsets.only(top: 10),
            child: _buildContent(image, context))
      ],
    );
  }

  int pageIndex = 1;

  ///从数据库加载历史聊天记录
  Future<List<ImageGenerationModel>> _loadMore({loadMore = false}) async {
    if (loadMore) {
      pageIndex++;
    } else {
      pageIndex = 1;
    }
    var list = await imageDao.getImages(pageIndex: pageIndex);
    if (loadMore) {
      if (list.isNotEmpty) {
        imageGenerationController.loadMoreData(list);
      } else {
        //如果没有更多的数据，则pageIndex不增加
        pageIndex--;
      }
    }
    return list;
  }

  getTitle() {
    _title = _sendBtnEnable
        ? widget.title!
        : AppLocalizations.of(context)!.generating;
  }

  AppBar appBar() {
    getTitle();
    return AppBar(
      title: Text(_title),
      actions: [_cleanStream],
    );
  }

  // 发送给文心一言-文生图
  _onWenXinSend(String inputMessage) async {
    setState(() {
      _sendBtnEnable = false;
    });
    String? response = '';
    try {
      var map = await completionDao.createWenXinWSTCompletions(
          accessToken: accessToken,
          prompt: inputMessage) as Map<String, dynamic>;
      if (map['errorCode'] != null) {
        if (map['errorCode'] == 110) {
          PreferencesHelper.saveData(HiConst.accessToken, '');
          _initWenXinConfig();
          _onWenXinSend(inputMessage);
          return;
        }
      } else {
        response = map['base64'];
      }
    } catch (e) {
      response = 'no response';
    }
    response ??= 'no response';
    _addImage(_genImageModel(prompt: inputMessage, base64: response));
    setState(() {
      _sendBtnEnable = true;
    });
  }

  ImageGenerationModel _genImageModel(
      {required String prompt, required String base64}) {
    return ImageGenerationModel(
        prompt: prompt,
        base64: base64,
        updateAt: DateTime.now().millisecondsSinceEpoch);
  }

  void _addImage(ImageGenerationModel model) {
    imageGenerationController.addImage(model);
    imageDao.saveImage(model);
  }
}

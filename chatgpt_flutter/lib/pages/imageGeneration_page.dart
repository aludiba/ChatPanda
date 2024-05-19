// ignore_for_file: use_build_context_synchronously
import 'dart:convert';

import 'package:bubble/bubble.dart';
import 'package:chat_message/util/wechat_date_format.dart';
import 'package:chatgpt_flutter/controller/image_controller.dart';
import 'package:chatgpt_flutter/dao/completion_dao.dart';
import 'package:chatgpt_flutter/db/favoriteImage_dao.dart';
import 'package:chatgpt_flutter/db/hi_db_manager.dart';
import 'package:chatgpt_flutter/db/image_dao.dart';
import 'package:chatgpt_flutter/model/favorite_model.dart';
import 'package:chatgpt_flutter/model/imageGeneration_model.dart';
import 'package:chatgpt_flutter/pages/imageBox_page.dart';
import 'package:chatgpt_flutter/provider/theme_provider.dart';
import 'package:chatgpt_flutter/util/hi_const.dart';
import 'package:chatgpt_flutter/util/hi_dialog.dart';
import 'package:chatgpt_flutter/util/image_utils.dart';
import 'package:chatgpt_flutter/util/padding_extension.dart';
import 'package:chatgpt_flutter/util/preferences_helper.dart';
import 'package:chatgpt_flutter/widget/image_list_widget.dart';
import 'package:chatgpt_flutter/widget/message_input_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  // 当前输入的提示词
  String _inputMessage = '';
  bool _sendBtnEnable = true;
  // 文心一言的_accessToken
  late String _accessToken;
  late ImageDao _imageDao;
  late CompletionDao _completionDao;
  late FavoriteImageDao favoriteDao;
  late ImageGenerationController _imageGenerationController;
  final ScrollController _scrollController = ScrollController();
  // 标题
  late String _title;

  get _themeColor => context.watch<ThemeProvider>().themeColor;

  int get _dataCount => _imageGenerationController.initialImageList.length;

  get _imageList => Expanded(
          child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: ImageList(imageController: _imageGenerationController),
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
              // 删除所有的收藏图片
              favoriteDao.deleteAllFavoriteImages();
              // 删除所有数据
              _imageDao.deleteAllImages();
              _imageGenerationController.initialImageList.clear();
            });
            HiDialog.showSnackBar(
                context, AppLocalizations.of(context)!.haveEmptied);
          },
          child: Icon(Icons.cleaning_services, size: 25, color: _themeColor),
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
    _imageGenerationController = ImageGenerationController(
        initialImageList: [],
        scrollController: _scrollController,
        imageWidgetBuilder: _imageWidget,
        timePellet: 60);
    //下拉触发加载更多
    _scrollController.addListener(() {
      // 滚动到底部
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMore(loadMore: true);
      }
    });
    var account = await HiDBManager.getAccountHash();
    var dbManager = await HiDBManager.instance(dbName: account);
    _imageDao = ImageDao(dbManager);
    favoriteDao = FavoriteImageDao(dbManager);
    var list = await _loadMore();
    _imageGenerationController.loadMoreData(list);
    _completionDao = CompletionDao();
    setState(() {});
  }

  void _initWenXinConfig() async {
    _accessToken = (await PreferencesHelper.loadData(HiConst.accessToken))!;
    if (_accessToken == '') {
      _accessToken = await CompletionDao.getWenXinToken();
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
          5.paddingHeight,
          InkWell(
            onTap: () {
              _showModal(context, imageModel, imageWidget);
            },
            child: imageWidget,
          )
        ],
      );
    } catch (e) {
      AILogger.log('Error decoding base64 image: $e');
    }
  }

  // 模态展示图片
  void _showModal(BuildContext context, ImageGenerationModel imageModel,
      Widget imageWidget) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          // 使用Container包裹，设置背景颜色
          color: Colors.white,
          child: ImageBoxPage(imageModel: imageModel, imageWidget: imageWidget),
        );
      },
    );
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
          _menuItem(image)
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

  _menuItem(ImageGenerationModel imageModel) {
    Color color = const Color.fromRGBO(233, 233, 252, 19);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(0.0, 6.0, 0.0, 6.0),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ..._actionItem(
              isEnable: true,
              actionTap: () {
                //保存图片
                ImageUtils.saveBase64ImageToGallery(imageModel, context);
              },
              icon: Icon(Icons.save_alt, color: color, size: 15),
              text: AppLocalizations.of(context)!.save),
          ..._actionItem(
              isEnable: true,
              actionTap: () {
                ///删除
                setState(() {
                  if (imageModel.isFavorite == true) {
                    favoriteDao.removeFavoriteImage(FavoriteImageModel(
                        updateAt: imageModel.updateAt,
                        prompt: imageModel.prompt,
                        base64: imageModel.base64));
                  }
                  _imageDao.deleteImage(imageModel.updateAt);
                  _imageGenerationController.initialImageList
                      .remove(imageModel);
                  HiDialog.showSnackBar(
                      context, AppLocalizations.of(context)!.haveDeleted);
                });
              },
              icon: Icon(Icons.delete, color: color, size: 15),
              text: AppLocalizations.of(context)!.delete),
          ..._actionItem(
              isEnable: true,
              actionTap: () {
                //分享
                ImageUtils.shareImage(imageModel, context);
              },
              icon: Icon(Icons.share_outlined, color: color, size: 15),
              text: AppLocalizations.of(context)!.share),
          ..._actionItem(
              isEnable: true,
              actionTap: () {
                //收藏
                if (imageModel.isFavorite == true) {
                  _removeFavorite(imageModel);
                } else {
                  _addFavorite(imageModel);
                }
              },
              icon: Icon(Icons.favorite,
                  color: imageModel.isFavorite == true ? Colors.red : color,
                  size: 15),
              text: AppLocalizations.of(context)!.favorite)
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

  int pageIndex = 1;

  ///从数据库加载历史聊天记录
  Future<List<ImageGenerationModel>> _loadMore({loadMore = false}) async {
    if (loadMore) {
      pageIndex++;
    } else {
      pageIndex = 1;
    }
    var list = await _imageDao.getImages(pageIndex: pageIndex);
    if (loadMore) {
      if (list.isNotEmpty) {
        _imageGenerationController.loadMoreData(list);
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
      actions: _appActions(),
    );
  }

  // 发送给文心一言-文生图
  _onWenXinSend(String inputMessage) async {
    setState(() {
      _sendBtnEnable = false;
    });
    String? response = '';
    try {
      var map = await _completionDao.createWenXinWSTCompletions(
          accessToken: _accessToken,
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
    _imageGenerationController.addImage(model);
    _imageDao.saveImage(model);
  }

  // 是否有图片
  List<Widget>? _appActions() {
    bool result = _dataCount > 0 ? true : false;
    return result ? [_cleanStream] : [];
  }

  //设为"精彩图片"
  void _addFavorite(ImageGenerationModel imageModel) async {
    var result = await favoriteDao.addFavoriteImage(FavoriteImageModel(
        updateAt: imageModel.updateAt,
        prompt: imageModel.prompt,
        base64: imageModel.base64));
    var showText = '';
    if (result != null && result > 0) {
      imageModel.isFavorite = true;
      _imageDao.update(imageModel);
      showText = AppLocalizations.of(context)!.successfulCollection;
    } else {
      showText = AppLocalizations.of(context)!.collectionFailure;
    }
    if (!mounted) return;
    HiDialog.showSnackBar(context, showText);
    setState(() {});
  }

  //取消"精彩图片"
  void _removeFavorite(ImageGenerationModel imageModel) async {
    var result = await favoriteDao.removeFavoriteImage(FavoriteImageModel(
        updateAt: imageModel.updateAt,
        prompt: imageModel.prompt,
        base64: imageModel.base64));
    var showText = '';
    if (result != null && result > 0) {
      imageModel.isFavorite = false;
      _imageDao.update(imageModel);
      showText = AppLocalizations.of(context)!.unSuccessfulCollection;
    } else {
      showText = AppLocalizations.of(context)!.unCollectionFailure;
    }
    if (!mounted) return;
    HiDialog.showSnackBar(context, showText);
    setState(() {});
  }
}

// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

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
import 'package:chatgpt_flutter/util/padding_extension.dart';
import 'package:chatgpt_flutter/util/preferences_helper.dart';
import 'package:chatgpt_flutter/widget/image_list_widget.dart';
import 'package:chatgpt_flutter/widget/message_input_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image/image.dart' as img;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:openai_flutter/utils/ai_logger.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

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
              // 删除所有数据
              _imageDao.deleteAllImages();
              _imageGenerationController.initialImageList.clear();
            });
            HiDialog.showSnackBar(
                context, AppLocalizations.of(context)!.haveEmptied);
          },
          child: const Icon(Icons.cleaning_services, size: 25),
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
    var dbManager =
        await HiDBManager.instance(dbName: HiDBManager.getAccountHash());
    _imageDao = ImageDao(dbManager);
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
                //先检查权限,保存图片
                saveBase64ImageToGallery(imageModel);
              },
              icon: Icon(Icons.save_alt, color: color, size: 15),
              text: AppLocalizations.of(context)!.save),
          ..._actionItem(
              isEnable: true,
              actionTap: () {
                ///删除
                setState(() {
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
                ///分享
                shareImage(imageModel);
              },
              icon: Icon(Icons.share_outlined, color: color, size: 15),
              text: AppLocalizations.of(context)!.share)
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

  // 分享图片
  Future<void> shareImage(ImageGenerationModel imageModel) async {
    String base64Image = imageModel.base64!;
    String text = imageModel.prompt!;
    try {
      // 将 Base64 字符串解码为 Uint8List
      final Uint8List bytes = base64.decode(base64Image);
      // 使用image库将Uint8List解码为图片
      final img.Image? image = img.decodeImage(bytes);
      if (image == null) {
        throw 'Unable to decode image';
      }
      // 获取临时目录用于存储临时文件
      final Directory tempDir = await getTemporaryDirectory();
      final String path = '${tempDir.path}/temp_image.png';
      // 将解码后的图片保存为文件
      final File file = File(path)..writeAsBytesSync(img.encodePng(image));
      await Share.shareXFiles(
        [path].map((path) => XFile(path)).toList(), // 将路径列表转换为XFile列表
        text: text, // 可以附加一段文本说明
        subject: AppLocalizations.of(context)!.shareImageTips, // iOS的邮件分享可设置主题
      );
      // 删除临时文件。
      await file.delete();
    } catch (e) {
      HiDialog.showSnackBar(
          context, AppLocalizations.of(context)!.shareImageError);
    }
  }

  // 保存图片到相册
  Future<void> saveBase64ImageToGallery(ImageGenerationModel imageModel) async {
    String base64String = imageModel.base64!;
    String prompt = imageModel.prompt!;
    try {
      // Base64字符串解码。
      Uint8List imageData = base64.decode(base64String);
      // 获取临时目录。
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName =
          '${prompt}_${DateTime.now().millisecondsSinceEpoch}.png';
      final File imageFile = File('${tempDir.path}/$fileName');
      // 文件写入。
      await imageFile.writeAsBytes(imageData);
      // 将文件保存到相册。
      final result = await ImageGallerySaver.saveFile(imageFile.path);
      if (result != null && result.isNotEmpty) {
        // 文件保存成功
        HiDialog.showSnackBar(context, AppLocalizations.of(context)!.haveSaved);
      } else {
        // 文件保存失败
        HiDialog.showSnackBar(
            context, AppLocalizations.of(context)!.saveFailure);
      }
      // 删除临时文件。
      await imageFile.delete();
    } on PlatformException catch (e) {
      HiDialog.showSnackBar(context, AppLocalizations.of(context)!.saveFailure);
    }
  }

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
}

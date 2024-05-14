import 'dart:convert';
import 'dart:typed_data';

import 'package:chatgpt_flutter/db/favoriteImage_dao.dart';
import 'package:chatgpt_flutter/db/hi_db_manager.dart';
import 'package:chatgpt_flutter/db/image_dao.dart';
import 'package:chatgpt_flutter/model/favorite_model.dart';
import 'package:chatgpt_flutter/model/imageGeneration_model.dart';
import 'package:chatgpt_flutter/pages/imageBox_page.dart';
import 'package:chatgpt_flutter/provider/theme_provider.dart';
import 'package:chatgpt_flutter/util/hi_dialog.dart';
import 'package:chatgpt_flutter/widget/favoriteImge_widget.dart';
import 'package:chatgpt_flutter/widget/noData_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:openai_flutter/utils/ai_logger.dart';
import 'package:provider/provider.dart';

///收藏的消息页面
class WonderfulImagePage extends StatefulWidget {
  const WonderfulImagePage({Key? key}) : super(key: key);

  @override
  State<WonderfulImagePage> createState() => _WonderfulImagePageState();
}

class _WonderfulImagePageState extends State<WonderfulImagePage> {
  late FavoriteImageDao favoriteImageDao;

  List<FavoriteImageModel> favoriteList = [];

  get _themeColor => context.watch<ThemeProvider>().themeColor;

  get _listView => ListView.builder(
      itemCount: favoriteList.length,
      itemBuilder: (BuildContext context, int index) {
        FavoriteImageModel model = favoriteList[index];
        return Slidable(
            endActionPane: ActionPane(
                motion: const ScrollMotion(),
                extentRatio: 0.5,
                children: [
                  SlidableAction(
                    flex: 5,
                    onPressed: (BuildContext context) {
                      _onDelete(model);
                    },
                    icon: Icons.delete,
                    label: AppLocalizations.of(context)!.delete,
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    backgroundColor: _themeColor,
                  ),
                ]),
            child: FavoriteImageWidget(
              model: model,
              onTap: _jumpToDetail,
            ));
      });

  @override
  void initState() {
    super.initState();
    _doInit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.wonderfulImage),
      ),
      body: _subViews(),
    );
  }

  void _doInit() async {
    var dbManager =
        await HiDBManager.instance(dbName: HiDBManager.getAccountHash());
    favoriteImageDao = FavoriteImageDao(dbManager);
    _loadData();
  }

  void _loadData() async {
    List<FavoriteImageModel> list = await favoriteImageDao.getFavoriteImages();
    setState(() {
      favoriteList = list;
    });
  }

  ///取消"精彩"设置
  _onCancelWonderFul(FavoriteImageModel model) async {
    ///将会话中的该条数据取消"精彩"设置
    if (model.updateAt != null) {
      var dbManager =
          await HiDBManager.instance(dbName: HiDBManager.getAccountHash());
      ImageDao imageDao = ImageDao(dbManager);
      ImageGenerationModel imageModel = ImageGenerationModel(
          prompt: model.prompt,
          base64: model.base64,
          updateAt: model.updateAt ?? 0,
          isFavorite: false);
      imageDao.update(imageModel);
    }
  }

  _onDelete(FavoriteImageModel model) async {
    //从"精彩"列表中移除
    var result = await favoriteImageDao.removeFavoriteImage(model);
    var showText = '';
    if (result != null && result > 0) {
      _onCancelWonderFul(model);
      showText = AppLocalizations.of(context)!.successfullyDelete;
    } else {
      showText = AppLocalizations.of(context)!.deletionFailure;
    }
    if (!mounted) return;
    HiDialog.showSnackBar(context, showText);
    setState(() {
      favoriteList.remove(model);
    });
  }

  // 跳转详情
  void _jumpToDetail(FavoriteImageModel model, BuildContext ancestor) {
    ImageGenerationModel imageModel = ImageGenerationModel(
        prompt: model.prompt,
        base64: model.base64,
        updateAt: model.updateAt ?? 0,
        isFavorite: true);
    String base64Str = imageModel.base64 ?? '';
    try {
      Uint8List bytes = base64Decode(base64Str);
      Widget imageWidget = Image.memory(bytes);
      // 模态展示图片
      showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return Container(
            // 使用Container包裹，设置背景颜色
            color: Colors.white,
            child:
                ImageBoxPage(imageModel: imageModel, imageWidget: imageWidget),
          );
        },
      );
    } catch (e) {
      AILogger.log('Error decoding base64 image: $e');
    }
  }

  _subViews() {
    if (favoriteList.isNotEmpty) {
      return _listView;
    } else {
      return const NoDataWidget();
    }
  }
}

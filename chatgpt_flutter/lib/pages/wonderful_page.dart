import 'package:chat_message/models/message_model.dart';
import 'package:chatgpt_flutter/db/favorite_dao.dart';
import 'package:chatgpt_flutter/db/hi_db_manager.dart';
import 'package:chatgpt_flutter/db/message_dao.dart';
import 'package:chatgpt_flutter/model/favorite_model.dart';
import 'package:chatgpt_flutter/pages/message_detail.dart';
import 'package:chatgpt_flutter/provider/theme_provider.dart';
import 'package:chatgpt_flutter/util/hi_dialog.dart';
import 'package:chatgpt_flutter/util/hi_utils.dart';
import 'package:chatgpt_flutter/util/navigator_util.dart';
import 'package:chatgpt_flutter/widget/noData_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../widget/favorite_widget.dart';

///收藏的消息页面
class WonderfulPage extends StatefulWidget {
  const WonderfulPage({Key? key}) : super(key: key);

  @override
  State<WonderfulPage> createState() => _WonderfulPageState();
}

class _WonderfulPageState extends State<WonderfulPage> {
  late FavoriteDao favoriteDao;

  List<FavoriteModel> favoriteList = [];

  get _themeColor => context.watch<ThemeProvider>().themeColor;

  get _listView => ListView.builder(
      itemCount: favoriteList.length,
      itemBuilder: (BuildContext context, int index) {
        FavoriteModel model = favoriteList[index];
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
            child: FavoriteWidget(
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
        title: Text(AppLocalizations.of(context)!.wonderfulContent),
      ),
      body: _subViews(),
    );
  }

  void _doInit() async {
    var dbManager =
        await HiDBManager.instance(dbName: HiDBManager.getAccountHash());
    favoriteDao = FavoriteDao(dbManager);
    _loadData();
  }

  void _loadData() async {
    var list = await favoriteDao.getFavoriteList();
    setState(() {
      favoriteList = list;
    });
  }

  void _onLongPress(FavoriteModel model, BuildContext ancestor) {
    HiDialog.showPopMenu(ancestor, offsetX: -50, items: [
      PopupMenuItem(
        onTap: () => HiUtils.copyMessage(model.content, context),
        child: Text(AppLocalizations.of(context)!.copy),
      ),
      PopupMenuItem(
        child: Text(AppLocalizations.of(context)!.delete),
        onTap: () => _onDelete(model),
      ),
      PopupMenuItem(
        child: Text(AppLocalizations.of(context)!.transpond),
        onTap: () => HiDialog.showSnackBar(
            context, AppLocalizations.of(context)!.comingSoon),
      ),
      PopupMenuItem(
        child: Text(AppLocalizations.of(context)!.more),
        onTap: () => HiDialog.showSnackBar(
            context, AppLocalizations.of(context)!.comingSoon),
      )
    ]);
  }

  ///取消"精彩"设置
  _onCancelWonderFul(FavoriteModel model) async {
    ///将会话中的该条数据取消"精彩"设置
    if (model.cid != null) {
      var dbManager =
          await HiDBManager.instance(dbName: HiDBManager.getAccountHash());
      MessageDao messageDao = MessageDao(dbManager, cid: model.cid!);
      MessageModel messagemodel = MessageModel(
          ownerType: OwnerType.receiver,
          ownerName: model.ownerName,
          content: model.content,
          createdAt: model.createdAt ?? 0,
          isFavorite: false);
      messageDao.update(messagemodel);
    }
  }

  _onDelete(FavoriteModel model) async {
    //从"精彩"列表中移除
    var result = await favoriteDao.removeFavorite(model);
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

  void _jumpToDetail(FavoriteModel model, BuildContext ancestor) {
    NavigatorUtil.push(context, MessageDetailPage(model: model));
  }

  _subViews() {
    if (favoriteList.isNotEmpty) {
      return _listView;
    } else {
      return const NoDataWidget();
    }
  }
}

import 'dart:convert';

import 'package:chatgpt_flutter/db/conversation_dao.dart';
import 'package:chatgpt_flutter/db/favorite_dao.dart';
import 'package:chatgpt_flutter/model/aiTool_model.dart';
import 'package:chatgpt_flutter/model/conversation_model.dart';
import 'package:chatgpt_flutter/model/favorite_model.dart';
import 'package:chatgpt_flutter/pages/conversation_page.dart';
import 'package:chatgpt_flutter/provider/theme_provider.dart';
import 'package:chatgpt_flutter/util/custom_Notification.dart';
import 'package:chatgpt_flutter/util/file_utils.dart';
import 'package:chatgpt_flutter/util/hi_const.dart';
import 'package:chatgpt_flutter/util/navigator_util.dart';
import 'package:chatgpt_flutter/widget/conversation_widget.dart';
import 'package:chatgpt_flutter/widget/noData_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../db/hi_db_manager.dart';
import '../db/message_dao.dart';

class ConversationListWidget extends StatefulWidget {
  //是否加载到首页-聊天页面,默认为false
  final bool? isComprehensive;
  const ConversationListWidget({super.key, this.isComprehensive});

  @override
  State<ConversationListWidget> createState() => ConversationListWidgetState();
}

class ConversationListWidgetState extends State<ConversationListWidget>
    with AutomaticKeepAliveClientMixin {
  //聊天列表
  List<ConversationModel> conversationList = [];
  //置顶列表
  List<ConversationModel> stickConversationList = [];
  late ConversationListDao conversationListDao;
  late MessageDao currentMessageDao;
  late FavoriteDao favoriteDao;
  //跳转到对话详情待更新的model
  ConversationModel? pendingModel;

  get _dataCount => conversationList.length + stickConversationList.length;

  get _listView => ListView.builder(
      itemCount: _dataCount,
      itemBuilder: (BuildContext context, int index) =>
          _conversationWidget(index));

  get _themeColor => context.watch<ThemeProvider>().themeColor;

  @override
  void initState() {
    super.initState();
    _doInit();
  }

  @override
  void setState(VoidCallback fn) {
    if (!mounted) {
      //fix 热重启/热加载 build被连续执行两次，_doInit执行setState时页面已经销毁的问题
      return;
    }
    super.setState(fn);
  }

  // build
  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.isComprehensive == true) {
      _aIToolListener(context);
    }
    return widget.isComprehensive == true
        ? _buildComprehensiveListWidget()
        : _buildConversationListWidget();
  }

  _buildComprehensiveListWidget() {
    return Container(
      child: _listView,
    );
  }

  _buildConversationListWidget() {
    return Container(
      child: _dataCount == 0
          ? NoDataWidget(
              hostIcon: Icons.add_chart,
              tip: AppLocalizations.of(context)!.clickNewSession,
              hostTap: createConversation)
          : _listView,
    );
  }

  //创建新的会话
  void createConversation() {
    int cid = DateTime.now().millisecondsSinceEpoch;
    _jumpToConversation(ConversationModel(
        cid: cid,
        icon:
            'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fci.xiaohongshu.com%2F40061aa2-e489-5be1-9099-d4c6f70487cd%3FimageView2%2F2%2Fw%2F1080%2Fformat%2Fjpg&refer=http%3A%2F%2Fci.xiaohongshu.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1714562783&t=44139dcd0294e703f4777025c6429318'));
  }

  _conversationWidget(int pos) {
    ConversationModel model;
    if (pos < stickConversationList.length) {
      model = stickConversationList[pos];
    } else {
      model = conversationList[pos - stickConversationList.length];
    }
    return Slidable(
        endActionPane: ActionPane(
            motion: const ScrollMotion(),
            extentRatio: 0.5,
            children: [
              SlidableAction(
                flex: 5,
                onPressed: (BuildContext context) {
                  _onStick(model, isStick: !_isStick(model));
                },
                icon: Icons.sticky_note_2,
                label: _stickLabel(model),
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                backgroundColor: _themeColor,
              ),
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
        child:
            ConversationWidget(model: model, onPressed: _jumpToConversation));
  }

  void _doInit() async {
    var account = await HiDBManager.getAccountHash();
    var storage = await HiDBManager.instance(dbName: account);
    conversationListDao = ConversationListDao(
        storage,
        widget.isComprehensive == true
            ? HiConst.aIToolChatListName
            : HiConst.randomChatListName);
    favoriteDao = FavoriteDao(storage);
    _loadStickData();
    _loadData();
  }

  _aIToolListener(BuildContext context) {
    bool isUpdate = context.watch<AIToolSharedData>().isUpdate;
    if (isUpdate && (context.watch<AIToolSharedData>().updateModel != null)) {
      ConversationModel updateModel =
          context.watch<AIToolSharedData>().updateModel!;
      pendingModel = updateModel;
      _doUpdate(updateModel.cid);
      // 更新完之后状态设为false
      Provider.of<AIToolSharedData>(context, listen: false).isUpdate = false;
    }
  }

  int pageIndex = 1;

  Future<List<ConversationModel>> _loadStickData() async {
    var list = await conversationListDao.getStickConversationList();
    setState(() {
      stickConversationList = list;
    });
    return list;
  }

  Future<List<ConversationModel>> _loadData({loadMore = false}) async {
    if (loadMore) {
      pageIndex++;
    } else {
      pageIndex = 1;
    }
    var list =
        await conversationListDao.getConversationList(pageIndex: pageIndex);
    debugPrint(jsonEncode(list));
    if (loadMore) {
      setState(() {
        conversationList.addAll(list);
      });
    } else {
      setState(() {
        conversationList = list;
      });
    }
    return list;
  }

  // 获取AI工具的子model
  Future<AIToolSubModel?> getAIToolModel(ConversationModel model) async {
    dynamic jsonData = await JsonStorage.loadDataFromFile('AIToolData.json');
    List<dynamic> map = jsonData.toList();
    List<AIToolModel> data = map.map((e) => AIToolModel.fromJson(e)).toList();
    AIToolSubModel? tempModel;
    for (var element in data) {
      for (var value in element.children!) {
        if (value.conversation?.cid == model.cid) {
          tempModel = value;
          break;
        }
      }
    }
    return tempModel;
  }

  void _jumpToConversation(ConversationModel model) async {
    pendingModel = model;
    AIToolSubModel? aIToolSubModel;
    if (widget.isComprehensive == true) {
      aIToolSubModel = await getAIToolModel(pendingModel!);
    }
    // ignore: use_build_context_synchronously
    NavigatorUtil.push(
        context,
        ConversationPage(
          isAITool: widget.isComprehensive,
          aiToolModel: aIToolSubModel,
          conversationModel: model,
          conversationUpdate: (model) => _doUpdate(model.cid),
        )).then((value) => {
          //从对话详情页返回
          Future.delayed(
              const Duration(milliseconds: 500), () => _doUpdate(model.cid))
        });
  }

  _doUpdate(int cid) async {
    //fix 新建会话，没有聊天消息也会保存的问题
    if (pendingModel == null || pendingModel?.title == null) {
      return;
    }
    var messageDao = MessageDao(conversationListDao.storage, cid: cid);
    var count = await messageDao.getMessageCount();
    //fix 置顶消息从对话框返回重复添加的问题
    if (pendingModel!.stickTime > 0) {
      for (var element in stickConversationList) {
        if (element.cid == pendingModel!.cid) {
          int index = stickConversationList.indexOf(element);
          stickConversationList[index] = pendingModel!; //
        }
      }
      if (!stickConversationList.contains(pendingModel)) {
        stickConversationList.add(pendingModel!);
      }
    } else {
      for (var element in conversationList) {
        if (element.cid == pendingModel!.cid) {
          int index = conversationList.indexOf(element);
          conversationList[index] = pendingModel!; //
        }
      }
      if (!conversationList.contains(pendingModel)) {
        conversationList.insert(0, pendingModel!);
      }
    }
    //触发刷新
    setState(() {
      pendingModel?.messageCount = count;
    });
    conversationListDao.saveConversation(pendingModel!);
  }

  @override
  bool get wantKeepAlive => true;

  _onDelete(ConversationModel model) async {
    var account = await HiDBManager.getAccountHash();

    /// 如果有设为"精彩"的内容则取消设置
    var storage = await HiDBManager.instance(dbName: account);
    currentMessageDao = MessageDao(storage, cid: model.cid);
    currentMessageDao.getAllMessage().then((value) {
      for (var messageModel in value) {
        if (messageModel.isFavorite == true) {
          favoriteDao.removeFavorite(FavoriteModel(
              id: messageModel.id,
              cid: model.cid,
              ownerName: messageModel.ownerName,
              createdAt: messageModel.createdAt,
              content: messageModel.content));
        }
      }
    });

    conversationListDao.deleteConversation(model);
    conversationList.remove(model);
    //fix 置顶消息无法删除问题
    stickConversationList.remove(model);
    // 通过Provider获取AIToolSharedData的实例，并删除AI工具数据
    // ignore: use_build_context_synchronously
    Provider.of<AIToolSharedData>(context, listen: false)
        .deleteAIToolData(true, model);
    setState(() {});
  }

  _onStick(ConversationModel model, {required bool isStick}) async {
    var result =
        await conversationListDao.updateStickTime(model, isStick: isStick);
    //操作失败
    if (result <= 0) {
      return;
    }
    if (isStick) {
      //从之前的列表中移除
      conversationList.remove(model);
      if (!stickConversationList.contains(model)) {
        //加入到新的列表
        stickConversationList.insert(0, model);
      }
    } else {
      stickConversationList.remove(model);
      if (!conversationList.contains(model)) {
        conversationList.insert(0, model); //也可根据需要，根据条件model插入到其他位置
      }
    }
    //刷新
    setState(() {});
  }

  _stickLabel(ConversationModel model) {
    var showStick = _isStick(model)
        ? AppLocalizations.of(context)!.untop
        : AppLocalizations.of(context)!.top;
    return showStick;
  }

  _isStick(ConversationModel model) {
    return model.stickTime > 0 ? true : false;
  }
}

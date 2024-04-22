// ignore_for_file: use_build_context_synchronously

import 'package:chatgpt_flutter/db/conversation_dao.dart';
import 'package:chatgpt_flutter/db/hi_db_manager.dart';
import 'package:chatgpt_flutter/db/message_dao.dart';
import 'package:chatgpt_flutter/model/aiTool_model.dart';
import 'package:chatgpt_flutter/model/conversation_model.dart';
import 'package:chatgpt_flutter/pages/conversation_page.dart';
import 'package:chatgpt_flutter/util/custom_Notification.dart';
import 'package:chatgpt_flutter/util/file_utils.dart';
import 'package:chatgpt_flutter/util/hi_const.dart';
import 'package:chatgpt_flutter/util/navigator_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class AIToolPage extends StatefulWidget {
  const AIToolPage({super.key});

  @override
  State<AIToolPage> createState() => _AIToolPageState();
}

class _AIToolPageState extends State<AIToolPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // 数组
  List<AIToolModel> _data = [];
  // 左列数据量
  int _leftDataCount = 0;
  // 左列选中ID
  String _selectedId = '';
  // 当前选中的子数组
  List<AIToolSubModel> _selectedSubData = [];
  // 右列数据量
  int _rightDataCount = 0;
  // 对话列表操作Dao
  late ConversationListDao conversationListDao;
  //跳转到对话详情待更新的model
  ConversationModel? pendingModel;

  @override
  void initState() {
    super.initState();
    _doInit();
  }

  void _doInit() async {
    var storage =
        await HiDBManager.instance(dbName: HiDBManager.getAccountHash());
    conversationListDao =
        ConversationListDao(storage, HiConst.aIToolChatListName);
    loadJsonData();
  }

  // 加载json数据
  loadJsonData() async {
    List<dynamic> map =
        await JsonStorage.loadJsonData('assets/json/AIToolData.json');
    _data = map.map((e) => AIToolModel.fromJson(e)).toList();
    _leftDataCount = _data.length;
    _selectedId = _data[0].id ?? '';
    _selectedSubData = _data[0].children ?? [];
    _rightDataCount = _selectedSubData.length;
    setState(() {});
  }

  // 将数据保存到json文件
  saveDataToJson() async {
    List<dynamic> list = _data.map((e) => e.toJson).toList();
    await JsonStorage.saveDataToJson(list, 'assets/json/AIToolData.json');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.aITool), centerTitle: true),
      body: Row(children: [
        Expanded(
          flex: 1,
          child: ListView.builder(
            itemCount: _leftDataCount,
            itemBuilder: (BuildContext context, int index) =>
                _aiLeftWidget(_data[index]),
          ),
        ),
        Expanded(
          flex: 2,
          child: ListView.builder(
            itemCount: _rightDataCount,
            itemBuilder: (BuildContext context, int index) =>
                _aiRightWidget(_selectedSubData[index]),
          ),
        ),
      ]),
    );
  }

  //左列cell
  _aiLeftWidget(AIToolModel model) {
    return InkWell(
      onTap: () {
        // 在这里添加选中逻辑
        setState(() {
          _selectedId = model.id ?? '';
          _selectedSubData = model.children ?? [];
          _rightDataCount = _selectedSubData.length;
        });
      },
      splashColor: Colors.transparent, // 水波纹颜色透明
      highlightColor: Colors.transparent, // 高亮颜色透明
      child: ListTile(
        title: Container(
          decoration: BoxDecoration(
            color: _selectedId == model.id ? Colors.blue[600] : null,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          child: Text(
            model.title ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color:
                    _selectedId == model.id ? Colors.white : Colors.grey[600]),
          ),
        ),
      ),
    );
  }

  // AI工具历史列表数据更新
  _doUpdate(int cid) async {
    //fix 新建会话，没有聊天消息也会保存的问题
    if (pendingModel == null || pendingModel?.title == null) {
      return;
    }
    var messageDao = MessageDao(conversationListDao.storage, cid: cid);
    var count = await messageDao.getMessageCount();
    //触发刷新
    setState(() {
      pendingModel?.messageCount = count;
    });
    conversationListDao.saveConversation(pendingModel!);
    // 通过Provider获取AIToolSharedData的实例，并更新数据
    Provider.of<AIToolSharedData>(context, listen: false)
        .updateData(true, pendingModel);
  }

  // 跳转到相应的AI工具对话框
  void _jumpToConversation(
      ConversationModel conversationModel, AIToolSubModel aISubModel) {
    pendingModel = conversationModel;
    NavigatorUtil.push(
        context,
        ConversationPage(
          isAITool: true,
          aiToolModel: aISubModel,
          conversationModel: conversationModel,
          conversationUpdate: (model) => _doUpdate(model.cid),
        )).then((value) => {
          //从对话详情页返回
          Future.delayed(const Duration(milliseconds: 500),
              () => _doUpdate(conversationModel.cid))
        });
  }

  //右列cell
  _aiRightWidget(AIToolSubModel model) {
    return GestureDetector(
        onTap: () {
          if (model.conversation != null) {
            _jumpToConversation(model.conversation!, model);
          } else {
            int cid = DateTime.now().millisecondsSinceEpoch;
            ConversationModel conversationModel = ConversationModel(
                cid: cid,
                icon:
                    'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fsafe-img.xhscdn.com%2Fbw1%2Ff3dfa152-d9c2-423d-9997-b491e72542da%3FimageView2%2F2%2Fw%2F1080%2Fformat%2Fjpg&refer=http%3A%2F%2Fsafe-img.xhscdn.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1715679555&t=2cb992904a45b003716111e12944eecb');
            model.conversation = conversationModel;
            saveDataToJson();
            _jumpToConversation(conversationModel, model);
          }
        },
        child: Padding(
            padding: const EdgeInsets.only(top: 4, right: 12, bottom: 4),
            child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
                child: ListTile(
                    title: Text(
                      model.descTitle ?? '',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.blue),
                    ),
                    subtitle: Text(
                      model.description ?? '',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey),
                    )))));
  }
}

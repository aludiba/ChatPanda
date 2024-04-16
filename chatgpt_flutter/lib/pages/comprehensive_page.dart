import 'package:chatgpt_flutter/model/comprehensive_model.dart';
import 'package:chatgpt_flutter/model/conversation_model.dart';
import 'package:chatgpt_flutter/pages/conversation_list_page.dart';
import 'package:chatgpt_flutter/pages/imageGeneration_page.dart';
import 'package:chatgpt_flutter/pages/voiceChat_page.dart';
import 'package:chatgpt_flutter/widget/comprehensive_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ComprehensivePage extends StatefulWidget {
  const ComprehensivePage({super.key});

  @override
  State<ComprehensivePage> createState() => _ComprehensivePageState();
}

class _ComprehensivePageState extends State<ComprehensivePage>
    with AutomaticKeepAliveClientMixin {
  static const titleStyle =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black);

  late List<ComprehensiveModel> comprehensiveList;

  List<ConversationModel> conversationList = [];

  //跳转到对话详情待更新的model
  ConversationModel? pendingModel;

  get _dataCount => comprehensiveList.length + 1 + conversationList.length;

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

  @override
  Widget build(BuildContext context) {
    comprehensiveList = [
      ComprehensiveModel(
          title: AppLocalizations.of(context)!.casualChat,
          icon: Icons.chat,
          jumpToPage: ConversationListPage(
              title: AppLocalizations.of(context)!.casualChat)),
      ComprehensiveModel(
          title: AppLocalizations.of(context)!.voiceChat,
          icon: Icons.voice_chat,
          jumpToPage:
              VoiceChatPage(title: AppLocalizations.of(context)!.voiceChat)),
      ComprehensiveModel(
          title: AppLocalizations.of(context)!.imageGeneration,
          icon: Icons.image,
          jumpToPage: ImageGenerationPage(
              title: AppLocalizations.of(context)!.imageGeneration))
    ];
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.chatPanda),
          centerTitle: true,
        ),
        body: ListView.builder(
            itemCount: _dataCount,
            itemBuilder: (BuildContext context, int index) =>
                _comprehensiveWidget(index)));
  }

  void _doInit() async {}

  @override
  bool get wantKeepAlive => true;

  _comprehensiveWidget(int index) {
    if (index < 3) {
      return ComprehensiveWidget(model: comprehensiveList[index]);
    } else if (index == 3) {
      return Container(
        padding: const EdgeInsets.only(left: 15, top: 20),
        child: Text(
          AppLocalizations.of(context)!.chatRecently,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.grey[600]),
        ),
      );
    }
  }
}

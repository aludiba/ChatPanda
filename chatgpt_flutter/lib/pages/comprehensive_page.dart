import 'package:chatgpt_flutter/model/comprehensive_model.dart';
import 'package:chatgpt_flutter/pages/conversation_list_page.dart';
import 'package:chatgpt_flutter/pages/imageGeneration_page.dart';
import 'package:chatgpt_flutter/pages/voiceChat_page.dart';
import 'package:chatgpt_flutter/widget/comprehensive_widget.dart';
import 'package:chatgpt_flutter/widget/conversation_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ComprehensivePage extends StatefulWidget {
  const ComprehensivePage({super.key});

  @override
  State<ComprehensivePage> createState() => _ComprehensivePageState();
}

class _ComprehensivePageState extends State<ComprehensivePage> {
  static const titleStyle =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black);
  //综合性服务列表
  late List<ComprehensiveModel> comprehensiveList;
  get _dataCount => comprehensiveList.length + 1 + 1;

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
      //随便聊
      ComprehensiveModel(
          title: AppLocalizations.of(context)!.casualChat,
          icon: Icons.chat,
          jumpToPage: ConversationListPage(
              title: AppLocalizations.of(context)!.casualChat)),
      //语音聊
      ComprehensiveModel(
          title: AppLocalizations.of(context)!.voiceChat,
          icon: Icons.voice_chat,
          jumpToPage:
              VoiceChatPage(title: AppLocalizations.of(context)!.voiceChat)),
      //图片生成
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
                _comprehensiveWidget(index, context)));
  }

  _comprehensiveWidget(int index, BuildContext context) {
    if (index < 3) {
      return SizedBox(
        height: 56,
        child: ComprehensiveWidget(model: comprehensiveList[index]),
      );
    } else if (index == 3) {
      return SizedBox(
        height: 36,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(left: 15),
              child: Text(
                'AI${AppLocalizations.of(context)!.chatRecently}',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600]),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15),
              child: Divider(),
            )
          ],
        ),
      );
    } else {
      // 获取屏幕尺寸
      final Size screenSize = MediaQuery.of(context).size;
      // 获取顶部和底部导航栏高度
      final double topPadding = MediaQuery.of(context).padding.top;
      final double bottomPadding = MediaQuery.of(context).padding.bottom;
      // 计算屏幕高度减去导航栏高度
      final double screenHeightMinusNavBars =
          screenSize.height - topPadding - bottomPadding - 204;
      return SizedBox(
        height: screenHeightMinusNavBars,
        child: const ConversationListWidget(isComprehensive: true),
      );
    }
  }
}

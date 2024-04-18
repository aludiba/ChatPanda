import 'package:chatgpt_flutter/provider/theme_provider.dart';
import 'package:chatgpt_flutter/widget/conversation_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class ConversationListPage extends StatefulWidget {
  final String? title;

  const ConversationListPage({super.key, this.title});

  @override
  State<ConversationListPage> createState() => _ConversationListPageState();
}

class _ConversationListPageState extends State<ConversationListPage>
    with AutomaticKeepAliveClientMixin {
  // 创建 GlobalKey
  final GlobalKey<ConversationListWidgetState> conversationListKey =
      GlobalKey<ConversationListWidgetState>();

  get _themeColor => context.watch<ThemeProvider>().themeColor;

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
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'ChatPanda'),
        centerTitle: true,
      ),
      body: ConversationListWidget(key: conversationListKey),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _themeColor,
        onPressed: () {
          // 使用GlobalKey调用ConversationListWidget中的公开方法
          conversationListKey.currentState?.createConversation();
        },
        tooltip: AppLocalizations.of(context)!.newSession,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

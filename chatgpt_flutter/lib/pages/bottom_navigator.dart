import 'dart:io' show Platform;

import 'package:chatgpt_flutter/pages/AITool_page.dart';
import 'package:chatgpt_flutter/pages/Translate_page.dart';
import 'package:chatgpt_flutter/pages/comprehensive_page.dart';
import 'package:chatgpt_flutter/pages/my_page.dart';
import 'package:chatgpt_flutter/provider/theme_provider.dart';
import 'package:chatgpt_flutter/util/hi_const.dart';
import 'package:chatgpt_flutter/util/navigator_util.dart';
import 'package:chatgpt_flutter/util/preferences_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openai_flutter/utils/ai_logger.dart';
import 'package:provider/provider.dart';

// method通道常量
const platform = MethodChannel('chatPanda/icloud');

///首页底部导航器
class BottomNavigator extends StatefulWidget {
  const BottomNavigator({super.key});

  @override
  State<BottomNavigator> createState() => _BottomNavigatorState();
}

class _BottomNavigatorState extends State<BottomNavigator> {
  final PageController _controller = PageController(initialPage: 0);
  final defaultColor = Colors.grey;
  var _activeColor = Colors.blue;
  int _currentIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _doInit();
  }

  _doInit() async {
    if (isIOS()) {
      // 运行iOS设备特定的代码
      String iCloudUserID = await getICloudUserID() ?? '';
      AILogger.log('iCloudUserID:$iCloudUserID');
      // 如果可以获取icloud id则保存
      if (iCloudUserID.isNotEmpty) {
        PreferencesHelper.saveData(HiConst.iCloudUserID, iCloudUserID);
      }
    } else {
      // 运行其他平台的代码
    }
  }

  //获取iCloud用户id
  Future<String?> getICloudUserID() async {
    try {
      final String userID = await platform.invokeMethod('getICloudUserID');
      return userID;
    } on PlatformException catch (e) {
      // 处理异常
      AILogger.log("Failed to get iCloud userID: ${e.message}");
    }
  }

  // 判断当前设备是否是iOS设备
  bool isIOS() {
    return Platform.isIOS;
  }

  @override
  Widget build(BuildContext context) {
    //更新导航器的context，供退出登录时使用
    NavigatorUtil.updateContext(context);
    var themeProvider = context.watch<ThemeProvider>();
    themeProvider.screenSize = MediaQuery.of(context).size;
    themeProvider.topPadding = MediaQuery.of(context).padding.top;
    themeProvider.bottomPadding = MediaQuery.of(context).padding.bottom;
    _activeColor = themeProvider.themeColor;
    return Scaffold(
      body: PageView(
        controller: _controller,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          AIToolPage(),
          ComprehensivePage(),
          TranslatePage(),
          MyPage()
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          _controller.jumpToPage(index);
        },
        type: BottomNavigationBarType.fixed,
        items: [
          _bottomItem(AppLocalizations.of(context)!.aITool, Icons.pan_tool, 0),
          _bottomItem(AppLocalizations.of(context)!.chat, Icons.chat, 0),
          _bottomItem(
              AppLocalizations.of(context)!.translate, Icons.translate, 1),
          _bottomItem(AppLocalizations.of(context)!.my, Icons.account_circle, 2)
        ],
      ),
    );
  }

  _bottomItem(String title, IconData icon, int index) {
    return BottomNavigationBarItem(
        icon: Icon(icon, color: defaultColor),
        activeIcon: Icon(icon, color: _activeColor),
        label: title);
  }
}

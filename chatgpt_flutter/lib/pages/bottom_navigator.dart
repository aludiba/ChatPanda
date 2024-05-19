import 'package:chatgpt_flutter/pages/AITool_page.dart';
import 'package:chatgpt_flutter/pages/Translate_page.dart';
import 'package:chatgpt_flutter/pages/comprehensive_page.dart';
import 'package:chatgpt_flutter/pages/my_page.dart';
import 'package:chatgpt_flutter/provider/theme_provider.dart';
import 'package:chatgpt_flutter/util/hi_const.dart';
import 'package:chatgpt_flutter/util/hi_utils.dart';
import 'package:chatgpt_flutter/util/navigator_util.dart';
import 'package:chatgpt_flutter/util/preferences_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_pangle_ads/flutter_pangle_ads.dart';
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
    super.initState();
    _doInit();
    AILogger.log('bottom-initState');
    _loadSplashAd();
  }

  _doInit() async {
    if (HiUtils.isIOS()) {
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

  void _loadSplashAd() {
    FlutterPangleAds.showSplashAd('889279359', timeout: 3);
    FlutterPangleAds.onEventListener((event) {
      // 普通广告事件
      String adEvent =
          'FlutterPangleAds-adId:${event.adId} action:${event.action}';
      if (event is AdErrorEvent) {
        // 错误事件
        adEvent += ' errCode:${event.errCode} errMsg:${event.errMsg}';
      } else if (event is AdRewardEvent) {
        // 激励事件
        adEvent +=
            'rewardType:${event.rewardType} rewardVerify:${event.rewardVerify} rewardAmount:${event.rewardAmount} rewardName:${event.rewardName} errCode:${event.errCode} errMsg:${event.errMsg} customData:${event.customData} userId:${event.userId}';
      }
      AILogger.log('onEventListener:$adEvent');
    });
    // // 设置广告监听
    // FlutterGromoreAds.onEventListener((event) {
    //   AILogger.log('onEventListener adId:${event.adId} action:${event.action}');
    //   if (event is AdErrorEvent) {
    //     AILogger.log(
    //         'AdErrorEvent-errCode:${event.errCode}, errMsg:${event.errMsg}');
    //   } else if (event is AdRewardEvent) {
    //     // 获得广告激励事件
    //   }
    // });
    // FlutterGromoreAds.showSplashAd('889279359', // 替换为你的开屏广告 ID
    //     timeout: 4.5);
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

import 'package:chatgpt_flutter/pages/wonderfulImage_page.dart';
import 'package:chatgpt_flutter/pages/wonderful_page.dart';
import 'package:chatgpt_flutter/provider/theme_provider.dart';
import 'package:chatgpt_flutter/util/navigator_util.dart';
import 'package:chatgpt_flutter/util/padding_extension.dart';
import 'package:chatgpt_flutter/widget/account_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../widget/theme_widget.dart';

///我的页面
class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  static const titleStyle =
      TextStyle(fontSize: 18, fontWeight: FontWeight.w600);

  get _buildTitle => Container(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            15.paddingWidth,
            Text(AppLocalizations.of(context)!.setTheme, style: titleStyle),
            10.paddingWidth,
            Text(AppLocalizations.of(context)!.pleaseChooseTheThemeYouLike,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]))
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    var themeProvider = context.watch<ThemeProvider>();
    var color = themeProvider.themeColor;
    return Scaffold(
      body: Column(
        children: [
          // ..._itemWidget(
          //     color: color,
          //     title: AppLocalizations.of(context)!.setOpenAIAPIKey,
          //     icon: Icons.network_check,
          //     onTap: _setKey),
          // ..._itemWidget(
          //     color: color,
          //     title: AppLocalizations.of(context)!.help,
          //     icon: Icons.arrow_forward_ios,
          //     onTap: _jumpToHelper),
          const AccountWidget(),
          ..._itemWidget(
              color: color,
              title: AppLocalizations.of(context)!.wonderfulContent,
              icon: Icons.arrow_forward_ios,
              onTap: _jumpToWonderful),
          ..._itemWidget(
              color: color,
              title: AppLocalizations.of(context)!.wonderfulImage,
              icon: Icons.arrow_forward_ios,
              onTap: _jumpToWonderfulImage),
          _buildTitle,
          ThemeWidget(onThemeChange: _onThemeChange)
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  void _onThemeChange(String value) {
    context.read<ThemeProvider>().setTheme(colorName: value);
  }

  _itemWidget(
          {required Color color,
          required String title,
          required IconData icon,
          GestureTapCallback? onTap}) =>
      [
        GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onTap,
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(
                      left: 15, top: 10, bottom: 10, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: titleStyle,
                      ),
                      Icon(icon, color: color)
                    ],
                  ),
                ),
                const Padding(
                    padding: EdgeInsets.only(left: 15, right: 15),
                    child: Divider())
              ],
            ))
      ];

  /// 设置api key
  // void _setKey() async {
  //   //获取之前设置过的open ai apikey
  //   var cacheKey = HiCache.getInstance().get(HiConst.keyOpenAi);
  //   var result = await HiDialog.showProxySettingDialog(context,
  //       proxyText: cacheKey, onTap: _jumpToHelper);
  //   //点击取消
  //   if (!result[0]) {
  //     return;
  //   }
  //   String? key = result[1];
  //   if (key == null || key.isEmpty) {
  //     HiCache.getInstance().remove(HiConst.keyOpenAi);
  //   } else {
  //     HiCache.getInstance().setString(HiConst.keyOpenAi, key);
  //   }
  //   // AIConfigBuilder.init(key ?? '');
  // }

  /// 进入"帮助"页面
  // void _jumpToHelper() {
  //   HelpTipModel model = HelpTipModel(
  //       title: AppLocalizations.of(context)!.helpTitleForKey,
  //       content: AppLocalizations.of(context)!.helpIntroForKey,
  //       url: AppLocalizations.of(context)!.helpURLForKey);
  //   NavigatorUtil.push(context, HelpPage(tipsList: [model]));
  // }

  /// 进入"精彩内容"页面
  void _jumpToWonderful() {
    NavigatorUtil.push(context, const WonderfulPage());
  }

  /// 进入"精彩图片"页面
  void _jumpToWonderfulImage() {
    NavigatorUtil.push(context, const WonderfulImagePage());
  }
}

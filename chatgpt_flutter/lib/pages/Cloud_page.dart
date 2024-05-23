import 'package:chatgpt_flutter/pages/manageCloud_page.dart';
import 'package:chatgpt_flutter/provider/theme_provider.dart';
import 'package:chatgpt_flutter/util/navigator_util.dart';
import 'package:chatgpt_flutter/util/padding_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openai_flutter/utils/ai_logger.dart';
import 'package:provider/provider.dart';

class CloudPage extends StatefulWidget {
  const CloudPage({super.key});

  @override
  State<CloudPage> createState() => _CloudPageState();
}

class _CloudPageState extends State<CloudPage> {
  get _themeColor => context.watch<ThemeProvider>().themeColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue[50],
        appBar: AppBar(
            title: const Text('Cloud'),
            centerTitle: true,
            backgroundColor: Colors.blue[50]),
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(left: 15, right: 15),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
              child: Column(
                children: [
                  ..._itemWidget(
                      color: _themeColor,
                      title: AppLocalizations.of(context)!.cloudPlan,
                      icon: Icons.cloud_outlined,
                      onTap: _jumpToCloudPlan,
                      isSkip: true,
                      isLast: false),
                  ..._itemWidget(
                      color: _themeColor,
                      title: AppLocalizations.of(context)!.subscribe,
                      subTitle: 'test:2025-01-24',
                      icon: Icons.calendar_view_month,
                      isSkip: false,
                      isLast: false),
                  ..._itemWidget(
                      color: _themeColor,
                      title: AppLocalizations.of(context)!.cloudID,
                      subTitle: 'test:20250124998',
                      icon: Icons.perm_device_info,
                      isSkip: false,
                      isLast: true)
                ],
              ),
            ),
            40.paddingHeight,
            _pointPurchase()
          ],
        ));
  }

  _itemWidget(
          {required Color color,
          required String title,
          String? subTitle,
          required IconData icon,
          GestureTapCallback? onTap,
          required bool isSkip,
          required bool isLast}) =>
      [
        GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onTap,
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(
                      left: 10, top: 10, bottom: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(icon, color: color),
                          10.paddingWidth,
                          Text(
                            title,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      isSkip
                          ? Icon(Icons.arrow_forward_ios, color: color)
                          : Text(
                              subTitle!,
                              style: const TextStyle(fontSize: 14),
                            )
                    ],
                  ),
                ),
                isLast
                    ? const Padding(
                        padding: EdgeInsets.only(bottom: 5),
                      )
                    : const Padding(
                        padding: EdgeInsets.only(left: 15, right: 15),
                        child: Divider())
              ],
            ))
      ];

  /// 点数购买widget
  _pointPurchase() {
    return GestureDetector(
      onTap: () {
        // TODO:调用订阅功能
        AILogger.log('购买熊猫豆~~~');
      },
      child: Container(
        margin: const EdgeInsets.only(left: 15, right: 15),
        padding:
            const EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_bag, color: _themeColor),
                10.paddingWidth,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.pointPurchaseTitle,
                      style: TextStyle(fontSize: 18, color: _themeColor),
                    ),
                    6.paddingHeight,
                    Text(
                      AppLocalizations.of(context)!.pointPurchaseSub,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    )
                  ],
                )
              ],
            ),
            Text(
              '\$4.99',
              style: TextStyle(fontSize: 18, color: _themeColor),
            )
          ],
        ),
      ),
    );
  }

  /// 进入"管理云计划"页面
  void _jumpToCloudPlan() {
    NavigatorUtil.push(context, const ManageCloudPlanPage());
  }
}

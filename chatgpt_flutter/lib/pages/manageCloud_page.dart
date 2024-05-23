import 'package:chatgpt_flutter/provider/theme_provider.dart';
import 'package:chatgpt_flutter/util/padding_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class ManageCloudPlanPage extends StatefulWidget {
  const ManageCloudPlanPage({super.key});

  @override
  State<ManageCloudPlanPage> createState() => _ManageCloudPlanPageState();
}

class _ManageCloudPlanPageState extends State<ManageCloudPlanPage> {
  get _themeColor => context.watch<ThemeProvider>().themeColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.cloudPlan),
        centerTitle: true,
        backgroundColor: Colors.grey[100],
      ),
      body: ListView.builder(
        itemCount: 3,
        itemBuilder: (BuildContext context, int index) => _itemWidget(index),
      ),
    );
  }

  _itemWidget(int index) {
    if (index == 0) {
      return Column(
        children: [
          20.paddingHeight,
          Text(AppLocalizations.of(context)!.selectPlanning,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center)
        ],
      );
    } else if (index == 1) {
      return _planItem();
    } else {
      return _planRightItem();
    }
  }

  // 订阅计划
  _planItem() {
    return Column(
      children: [
        30.paddingHeight,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            10.paddingWidth,
            _planWidget(
                title: AppLocalizations.of(context)!.monthlySubscription,
                price: '\$2.49',
                isSubscribed: false,
                onTap: _monthlySubscription),
            _planWidget(
                title: AppLocalizations.of(context)!.annualSubscription,
                price: '\$29.88',
                isSubscribed: false,
                onTap: _annualSubscription),
            10.paddingWidth
          ],
        ),
        15.paddingHeight,
        Text(
          AppLocalizations.of(context)!.pandaBeanTip,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        30.paddingHeight
      ],
    );
  }

  _planWidget(
      {required String title,
      required String price,
      required bool isSubscribed,
      GestureTapCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.only(left: 10, top: 10, bottom: 10, right: 10),
        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            10.paddingWidth,
            Text(
              price,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }

  // 月度订阅
  _monthlySubscription() {}

  // 年度订阅
  _annualSubscription() {}

  // 订阅之后的权益
  _planRightItem() {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10),
      padding: const EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(6)),
      ),
      child: Column(
        children: [
          Text(AppLocalizations.of(context)!.cloudSubscription,
              style: TextStyle(fontSize: 18, color: _themeColor)),
          ..._planRightWidget(
              title: AppLocalizations.of(context)!.intelligentQuestion,
              icon: Icons.question_answer),
          ..._planRightWidget(
              title: AppLocalizations.of(context)!.translate,
              icon: Icons.translate),
          ..._planRightWidget(
              title: AppLocalizations.of(context)!.writing,
              icon: Icons.text_fields),
          ..._planRightWidget(
              title: AppLocalizations.of(context)!.drawing, icon: Icons.draw),
        ],
      ),
    );
  }

  _planRightWidget({
    required String title,
    required IconData icon,
  }) =>
      [
        Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(
                  left: 10, top: 10, bottom: 10, right: 10),
              child: Row(
                children: [
                  Icon(icon, color: _themeColor),
                  25.paddingWidth,
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16),
                  )
                ],
              ),
            ),
          ],
        )
      ];
}

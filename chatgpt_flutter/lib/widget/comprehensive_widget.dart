import 'package:chatgpt_flutter/model/comprehensive_model.dart';
import 'package:chatgpt_flutter/provider/theme_provider.dart';
import 'package:chatgpt_flutter/util/navigator_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ComprehensiveWidget extends StatelessWidget {
  final ComprehensiveModel model;

  const ComprehensiveWidget({super.key, required this.model});

  static const titleStyle =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black);

  @override
  Widget build(BuildContext context) {
    var themeProvider = context.watch<ThemeProvider>();
    var color = themeProvider.themeColor;
    return GestureDetector(
      onTap: () {
        if (model.jumpToPage != null) {
          NavigatorUtil.push(context, model.jumpToPage!);
        }
      },
      behavior: HitTestBehavior.translucent,
      child: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.only(left: 15, top: 8, right: 20, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ..._titleItemWidget(
                    color: color, icon: model.icon, title: model.title),
                Icon(Icons.arrow_forward_ios, color: color)
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 15, right: 15),
            child: Divider(),
          ),
        ],
      ),
    );
  }

  _titleItemWidget(
          {required Color color,
          required IconData icon,
          required String title}) =>
      [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color),
            Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  title,
                  style: titleStyle,
                ))
          ],
        )
      ];
}

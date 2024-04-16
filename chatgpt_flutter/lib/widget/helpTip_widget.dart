import 'package:chatgpt_flutter/model/helpTip_model.dart';
import 'package:chatgpt_flutter/provider/theme_provider.dart';
import 'package:chatgpt_flutter/util/padding_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpTipWidget extends StatelessWidget {
  final HelpTipModel model;

  const HelpTipWidget({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var themeProvider = context.watch<ThemeProvider>();
    var themeColor = themeProvider.themeColor;
    return Padding(
        padding: const EdgeInsets.only(left: 15, right: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(model.title,
              style:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          10.paddingHeight,
          Text(model.content, style: const TextStyle(fontSize: 15)),
          if (model.url != null && model.url!.isNotEmpty)
            GestureDetector(
              onTap: () {
                // 在点击时打开链接
                _launchURL(model.url ?? '');
              },
              child: Text(
                model.url ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: themeColor,
                ),
              ),
            ),
          20.paddingHeight
        ]));
  }

  // 打开链接
  _launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $uri';
    }
  }
}

import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openai_flutter/utils/ai_logger.dart';
import 'package:url_launcher/url_launcher.dart';

import 'hi_dialog.dart';

class HiUtils {
  ///复制内容
  static void copyMessage(String message, BuildContext context) {
    Clipboard.setData(ClipboardData(text: message));
    if (!context.mounted) return;
    HiDialog.showSnackBar(context, AppLocalizations.of(context)!.copied);
  }

  ///打开H5页面
  static void openH5(String url) async {
    Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $uri';
    }
  }

  ///去掉第二个data及后面的字符串, 并返回json解析数据
  static String processStreamData(String input) {
    // 定义正则表达式，匹配第一个 "data: " 后面的 JSON 对象
    RegExp regex = RegExp(r'(data: \{.*?\}\})(.*)', dotAll: true);
    Match? match = regex.firstMatch(input);
    if (match != null) {
      // 提取匹配到的第一个 JSON 对象
      String jsonString = match.group(1)!;
      // 解析 JSON
      try {
        return jsonString.replaceFirst('data: ', '');
      } catch (e) {
        AILogger.log('Parsing Error: $e');
        return '';
      }
    } else {
      AILogger.log('No valid JSON data found.');
      return '';
    }
  }

  // 判断当前设备是否是iOS设备
  static bool isIOS() {
    return Platform.isIOS;
  }
}

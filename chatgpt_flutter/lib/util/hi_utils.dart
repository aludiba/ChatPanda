import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
}

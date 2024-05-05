import 'package:chatgpt_flutter/model/imageGeneration_model.dart';
import 'package:chatgpt_flutter/provider/theme_provider.dart';
import 'package:chatgpt_flutter/util/image_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class ImageBoxPage extends StatelessWidget {
  final ImageGenerationModel imageModel;
  final Widget imageWidget;

  const ImageBoxPage(
      {super.key, required this.imageModel, required this.imageWidget});

  @override
  Widget build(BuildContext context) {
    final themeColor = context.watch<ThemeProvider>().themeColor;

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // 彻底删除返回按钮
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop(); // 点击完成按钮返回前一个页面
                },
                child: Text(AppLocalizations.of(context)!.done,
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: themeColor)),
              ),
            )
          ],
        ),
        body: Center(
          child: imageWidget, // 此处为您的图片显示部分
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.white, // 设置底部工具栏的背景色为白色
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.share_outlined, color: themeColor),
                  onPressed: () {
                    //分享
                    ImageUtils.shareImage(imageModel, context);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.save_alt, color: themeColor),
                  onPressed: () {
                    //保存图片
                    ImageUtils.saveBase64ImageToGallery(imageModel, context);
                  },
                ),
              ],
            ),
          ),
        ));
  }
}

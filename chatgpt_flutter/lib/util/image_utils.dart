import 'dart:convert';
import 'dart:io';

import 'package:chatgpt_flutter/model/imageGeneration_model.dart';
import 'package:chatgpt_flutter/util/hi_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image/image.dart' as img;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ImageUtils {
  // 分享图片
  static Future<void> shareImage(
      ImageGenerationModel imageModel, BuildContext context) async {
    String base64Image = imageModel.base64!;
    String text = imageModel.prompt!;
    try {
      // 将 Base64 字符串解码为 Uint8List
      final Uint8List bytes = base64.decode(base64Image);
      // 使用image库将Uint8List解码为图片
      final img.Image? image = img.decodeImage(bytes);
      if (image == null) {
        throw 'Unable to decode image';
      }
      // 获取临时目录用于存储临时文件
      final Directory tempDir = await getTemporaryDirectory();
      final String path = '${tempDir.path}/temp_image.png';
      // 将解码后的图片保存为文件
      final File file = File(path)..writeAsBytesSync(img.encodePng(image));
      await Share.shareXFiles(
        [path].map((path) => XFile(path)).toList(), // 将路径列表转换为XFile列表
        text: text, // 可以附加一段文本说明
        subject: AppLocalizations.of(context)!.shareImageTips, // iOS的邮件分享可设置主题
      );
      // 删除临时文件。
      await file.delete();
    } catch (e) {
      HiDialog.showSnackBar(
          context, AppLocalizations.of(context)!.shareImageError);
    }
  }

  // 保存图片到相册
  static Future<void> saveBase64ImageToGallery(
      ImageGenerationModel imageModel, BuildContext context) async {
    String base64String = imageModel.base64!;
    String prompt = imageModel.prompt!;
    try {
      // Base64字符串解码。
      Uint8List imageData = base64.decode(base64String);
      // 获取临时目录。
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName =
          '${prompt}_${DateTime.now().millisecondsSinceEpoch}.png';
      final File imageFile = File('${tempDir.path}/$fileName');
      // 文件写入。
      await imageFile.writeAsBytes(imageData);
      // 将文件保存到相册。
      final result = await ImageGallerySaver.saveFile(imageFile.path);
      if (result != null && result.isNotEmpty) {
        // 文件保存成功
        HiDialog.showSnackBar(context, AppLocalizations.of(context)!.haveSaved);
      } else {
        // 文件保存失败
        HiDialog.showSnackBar(
            context, AppLocalizations.of(context)!.saveFailure);
      }
      // 删除临时文件。
      await imageFile.delete();
    } on PlatformException catch (e) {
      HiDialog.showSnackBar(context, AppLocalizations.of(context)!.saveFailure);
    }
  }
}

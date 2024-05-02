import 'dart:async';

import 'package:chatgpt_flutter/model/imageGeneration_model.dart';
import 'package:flutter/cupertino.dart';

typedef ImageWidgetBuilder = Widget Function(ImageGenerationModel message);

class ImageGenerationController implements IImageController {
  ///初始化数据
  List<ImageGenerationModel> initialImageList;
  final ScrollController scrollController;
  //信息流控件
  final ImageWidgetBuilder? imageWidgetBuilder;

  ///展示时间的间隔，单位秒
  final int timePellet;
  List<int> pelletShow = [];

  ImageGenerationController(
      {required this.initialImageList,
      required this.scrollController,
      required this.timePellet,
      this.imageWidgetBuilder}) {
    for (var message in initialImageList.reversed) {
      inflateMessage(message);
    }
  }

  StreamController<List<ImageGenerationModel>> imageStreamController =
      StreamController();

  void dispose() {
    imageStreamController.close();
    scrollController.dispose();
  }

  void widgetReady() {
    if (!imageStreamController.isClosed) {
      imageStreamController.sink.add(initialImageList);
    }
    if (initialImageList.isNotEmpty) scrollToLastImage();
  }

  void scrollToLastImage() {
    if (!scrollController.hasClients) {
      return;
    }
    scrollController.animateTo(0,
        duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
  }

  @override
  void addImage(ImageGenerationModel message) {
    if (imageStreamController.isClosed) return;
    inflateMessage(message);
    initialImageList.insert(0, message);
    imageStreamController.sink.add(initialImageList);
    scrollToLastImage();
  }

  @override
  void deleteImage(ImageGenerationModel message) {
    if (imageStreamController.isClosed) return;
    initialImageList.remove(message);
    pelletShow.clear();
    for (var message in initialImageList.reversed) {
      inflateMessage(message);
    }
    imageStreamController.sink.add(initialImageList);
  }

  @override
  void loadMoreData(List<ImageGenerationModel> messageList) {
    messageList = List.from(messageList.reversed);
    List<ImageGenerationModel> tempList = [...initialImageList, ...messageList];
    pelletShow.clear();
    for (var message in tempList.reversed) {
      inflateMessage(message);
    }
    initialImageList.clear();
    initialImageList.addAll(tempList);
    if (imageStreamController.isClosed) return;
    imageStreamController.sink.add(initialImageList);
  }

  ///设置消息的时间是否可以展示
  void inflateMessage(ImageGenerationModel message) {
    int pellet = (message.updateAt / (timePellet * 1000)).truncate();
    if (!pelletShow.contains(pellet)) {
      pelletShow.add(pellet);
      message.showCreatedTime = true;
    } else {
      message.showCreatedTime = false;
    }
  }
}

abstract class IImageController {
  void addImage(ImageGenerationModel image);
  void loadMoreData(List<ImageGenerationModel> imageList);
  void deleteImage(ImageGenerationModel image);
}

import 'package:chatgpt_flutter/controller/image_controller.dart';
import 'package:chatgpt_flutter/model/imageGeneration_model.dart';
import 'package:flutter/material.dart';

class ImageList extends StatefulWidget {
  ///ImageList的控制器
  final ImageGenerationController imageController;
  final EdgeInsetsGeometry? padding;

  const ImageList({
    super.key,
    required this.imageController,
    this.padding,
  });

  @override
  State<ImageList> createState() => _ImageListState();
}

class _ImageListState extends State<ImageList> {
  ImageGenerationController get imageController => widget.imageController;
  ImageWidgetBuilder? get imageWidgetBuilder =>
      imageController.imageWidgetBuilder;
  ScrollController get scrollController => imageController.scrollController;
  Widget get _imageStreamBuilder => StreamBuilder<List<ImageGenerationModel>>(
        stream: imageController.imageStreamController.stream,
        builder: (BuildContext context,
            AsyncSnapshot<List<ImageGenerationModel>> snapshot) {
          return snapshot.connectionState == ConnectionState.active
              ? ListView.builder(
                  // 配合shrinkWrap: true使用，解决数据少的时候数据底部对齐的问题
                  shrinkWrap: true,
                  reverse: true,
                  padding: widget.padding,
                  controller: scrollController,
                  itemCount: snapshot.data?.length ?? 0,
                  itemBuilder: (BuildContext context, int index) {
                    var model = snapshot.data![index];
                    return Container(
                        height: 350, child: imageWidgetBuilder!(model));
                  })
              : const Center(
                  child: CircularProgressIndicator(),
                );
        },
      );

  @override
  Widget build(BuildContext context) {
    //配合shrinkWrap: true使用，解决数据少的时候数据底部对齐的问题
    return Align(
      alignment: Alignment.topCenter,
      child: _imageStreamBuilder,
    );
  }

  @override
  void initState() {
    super.initState();
    imageController.widgetReady();
  }

  @override
  void dispose() {
    imageController.dispose();
    super.dispose();
  }
}

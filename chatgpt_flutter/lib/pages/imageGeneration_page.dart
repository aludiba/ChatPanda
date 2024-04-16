import 'package:flutter/material.dart';

class ImageGenerationPage extends StatefulWidget {
  final String? title;

  const ImageGenerationPage({super.key, this.title});

  @override
  State<ImageGenerationPage> createState() => _ImageGenerationPageState();
}

class _ImageGenerationPageState extends State<ImageGenerationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'ChatPanda'),
        centerTitle: true,
      ),
    );
  }
}

import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImageDisplayPage extends StatefulWidget {
  final Uint8List image;
  final String title;
  ImageDisplayPage({this.image, this.title, Key key}) : super(key: key);
  @override
  _ImageDisplayPageState createState() => _ImageDisplayPageState();
}

class _ImageDisplayPageState extends State<ImageDisplayPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.close),
        ),
        title: Text(
          widget.title,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Center(
        child: InkWell(
          child: Image.memory(widget.image),
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}

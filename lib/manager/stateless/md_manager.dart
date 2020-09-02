import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:markdown/markdown.dart' as md;

class MdManager {
  factory MdManager() => _instance;
  MdManager._();
  static MdManager _instance = MdManager._();
  final Map<String, String> _pathMap = {};
  static const List<String> _kAssetsDocImages = [];
  Future<void> init(BuildContext context) async {
    for (String imageName in _kAssetsDocImages) {
      await _buildMarkdownImage(context, imageName);
    }
  }

  ///把markdown文件编译成为html文件
  Future<String> buildMarkdownFileUrl(
      BuildContext context, String assetPath) async {
    String fileUrl = _pathMap[assetPath];
    if (fileUrl == null) {
      String markdownString =
          await DefaultAssetBundle.of(context).loadString(assetPath);
      String htmlString = md.markdownToHtml(markdownString);
      int idx = assetPath.lastIndexOf(".md");
      String filePath = StorageService().temporaryDirectory.path +
          "/${assetPath.substring(0, idx)}.html";
      File file = File(filePath);
      if (!file.parent.existsSync()) {
        file.parent.createSync(recursive: true);
      }
      file.writeAsStringSync(
          "<html><head><meta charset='UTF-8'></head><body>$htmlString</body></html>");
      fileUrl = "file://${file.path}";
      _pathMap[assetPath] = fileUrl;
      Logger.info("buildMarkdownFileUrl 文件路径：$fileUrl");
    }
    return fileUrl;
  }

  ///重新编译markdown中的图片
  Future<String> _buildMarkdownImage(
      BuildContext context, String assetPath) async {
    String fileUrl = _pathMap[assetPath];
    if (fileUrl == null) {
      var bytes = await rootBundle.load(assetPath);
      String dir = StorageService().temporaryDirectory.path;
      fileUrl = '$dir/$assetPath';
      File file = File(fileUrl);
      if (!file.parent.existsSync()) {
        file.parent.createSync(recursive: true);
      }
      await _writeToFile(bytes, fileUrl);
      _pathMap[assetPath] = fileUrl;
      Logger.info("buildMarkdownImage 文件路径：$fileUrl");
    }
    return fileUrl;
  }

  //write to app path
  Future<void> _writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return new File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:markdown/markdown.dart' as md;

///markdown文件转换为html文件，方便WebView显示。目前用户条款和隐私协议都是使用markdown编写的。
class MarkdownService {
  factory MarkdownService() => _instance;
  MarkdownService._();
  static MarkdownService _instance = MarkdownService._();
  final Map<String, String> _pathMap = {};
  Future<void> init(BuildContext context) async {}

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
}

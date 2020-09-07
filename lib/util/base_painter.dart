import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

class BasePainter extends CustomPainter {
  //背景颜色白色
  Paint bgPaint;
  //前景颜色黑色
  Paint fgPaint;
  void doStart() {
    //初始化背景色
    bgPaint = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;
    //初始化前景色
    fgPaint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;
  }

  //
  @override
  void paint(Canvas canvas, Size size) {
    //填充成白色
    this.drawBackground(canvas, size);
  }

  void drawBackground(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), bgPaint);
  }

  ///填充长方形函数
  void drawRect(
      Canvas canvas, double x, double y, double width, double height) {
    canvas.drawRect(Rect.fromLTRB(x, y, x + width, y + height), fgPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldPainter) {
    return true;
  }

  /// Returns a [ui.Picture] object containing the text data.
  ui.Picture toPicture(double width, double height) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    paint(canvas, Size(width, height));
    return recorder.endRecording();
  }

  /// Returns the raw text [ui.Image] object.
  Future<ui.Image> toImage(double width, double height,
      {ui.ImageByteFormat format = ui.ImageByteFormat.png}) async {
    return await toPicture(width, height)
        .toImage(width.toInt(), height.toInt());
  }

  /// Returns the raw text image byte data.
  Future<ByteData> toImageData(double width, double height,
      {ui.ImageByteFormat format = ui.ImageByteFormat.png}) async {
    final image = await toImage(width, height, format: format);
    return image.toByteData(format: format);
  }
}

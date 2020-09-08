import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_scc/painter/base_painter.dart';

/*
 * 方案详情二维码打印1
 * 
 * @author jiangyb
 *
 */
class QrCodePainter extends BasePainter {
  String nickName = "";
  ui.Image image;
  @override
  void doStart() {
    super.doStart();
  }

  @override
  void paint(Canvas canvas, Size size) async {
    super.paint(canvas, size);
    double offset = 0.0;
    this.drawString(canvas, size, nickName, leftBarWidth * 1.5,
        leftBarHeight * (offset + 1.5), 24);
    canvas.drawImage(image,
        Offset(leftBarWidth * 3.5, leftBarHeight * (offset + 7.5)), fgPaint);
  }
}

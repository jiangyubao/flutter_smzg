import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_smzg/routes/routers.dart';
import 'package:flutter_smzg/util/base_painter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:r_scan/r_scan.dart';
import 'dart:io';

import 'package:flutter_common/com/itou/common/util/logger.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/cupertino.dart';

class QrManager {
  factory QrManager() => _instance;
  const QrManager._();
  static const QrManager _instance = QrManager._();

  ///生成图片路径
  Future<String> saveImage(Uint8List imageData) async {
    int s2 = DateTime.now().millisecondsSinceEpoch;
    Directory temporaryDirectory = await getTemporaryDirectory();
    String dir = temporaryDirectory.path;
    String fileUrl = '$dir/$s2.bmp';
    File file = File(fileUrl);
    if (!file.parent.existsSync()) {
      file.parent.createSync(recursive: true);
    }
    file.writeAsBytesSync(imageData);
    return file.path;
  }

  Future<Uint8List> buildPainterImage(
      BasePainter basePainter, double width, double height) async {
    final ui.Image image = await basePainter.toImage(width, height);
    final ByteData byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData.buffer.asUint8List();
  }

  ///生成qrcode
  Future<ui.Image> buildQrCodeImage(String text, {double size = 600}) async {
    try {
      return await QrPainter(
        data: text,
        version: QrVersions.auto,
        gapless: false,
        color: Colors.black,
        emptyColor: Colors.white,
      ).toImage(size);
    } catch (e) {
      throw e;
    }
  }

  Future<Uint8List> buildQrCodeImageData(String text,
      {double size = 600}) async {
    try {
      final ui.Image image = await buildQrCodeImage(text, size: size);
      final ByteData byteData =
          await image.toByteData(format: ImageByteFormat.png);
      Logger.info("生成二维码成功");
      return byteData.buffer.asUint8List();
    } catch (e) {
      throw e;
    }
  }

  Future<String> scanQrCode(BuildContext context, String text) async {
    try {
      if (await PermissionService().requireCameraPermission()) {
        final RScanResult result = await Routers().goScan(context, text);
        if (result != null && result.message != null) {
          Logger.info("扫码成功");
          return result.message;
        } else {
          await DialogService().nativeAlert("扫码失败", "无法识别");
          Logger.info("扫码失败");
          return null;
        }
      } else {
        if (await DialogService().nativeConfirm("需要相机权限", "是否手工设置相机权限？")) {
          Logger.info("需要相机权限");
          await PermissionService().openAppSettings();
          return null;
        }
      }
    } on FormatException {
      await DialogService().nativeAlert("数据错误", "请仔细检查名片是否正确");
      Logger.info("数据格式错误");
      return null;
    } catch (e, s) {
      Logger.printErrorStack(e, s);
      await DialogService().nativeAlert("出现异常", e.toString());
      return null;
    }
    return null;
  }
}

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_hyble/ble/flutter_hyble_plugin.dart';
import 'package:flutter_hyble/flutter_hyble.dart';
import 'package:flutter_smzg/model/password_card.dart';
import 'package:flutter_smzg/service/statefull/password_card_list_state.dart';
import 'package:flutter_smzg/util/smzg_icon_font.dart';
import 'package:flutter_smzg/service/stateless/qr_manager.dart';
import 'package:flutter_smzg/view/widget/qr_code_painter.dart';
import 'package:image_save/image_save.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_extend/share_extend.dart';

class PasswordCardImagePage extends StatelessWidget {
  final PasswordCard passwordCard;
  PasswordCardImagePage({this.passwordCard});
  //根据路径打印图片
  Future<bool> _print(PasswordCard passwordCard) async {
    FlutterHyblePlugin flutterHyblePlugin = FlutterHyblePlugin();
    try {
      final QrCodePainter qrCodePainter = QrCodePainter()
        ..nickName = passwordCard.nickName
        ..image = await QrManager()
            .buildQrCodeImage(jsonEncode(passwordCard.toJson()), size: 300)
        ..paintBar = false
        ..doStart();
      final Uint8List image =
          await QrManager().buildPainterImage(qrCodePainter);
      final String path = await QrManager().saveImageData(image);

      await flutterHyblePlugin.ensureOnAndPermission();
      if (await flutterHyblePlugin.state != 2) {
        await DialogService().nativeAlert("", "未获得足够权限");
        return false;
      }
      List<Printer> list =
          await flutterHyblePlugin.startScan(name: "IT-", mac: "", count: 1);
      if (list.length == 0) {
        await DialogService().nativeAlert("", "未发现ESC蓝牙打印机");
        return false;
      }
      CommonResponse response = await flutterHyblePlugin.connect(
          mac: list[0].mac, timeOut: Duration(seconds: 20));
      if (response.code != "200") {
        await DialogService().nativeAlert("蓝牙连接失败", response.msg);
        return false;
      }
      await flutterHyblePlugin.printImage(
          filePath: path, timeOut: Duration(seconds: 30));
      return true;
    } catch (e, s) {
      Logger.printErrorStack(e, s);
      return false;
    } finally {
      await flutterHyblePlugin.disconnect();
    }
  }

  Widget build(BuildContext context) {
    return Consumer<PasswordCardListState>(
      builder: (context, accountListState, child) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(passwordCard.nickName),
            actions: <Widget>[],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Card(
                  child: Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: 20.h, vertical: 20.w),
                    child: QrImage(
                      size: 672.w,
                      data: jsonEncode(passwordCard.toJson()),
                      version: QrVersions.auto,
                    ),
                  ),
                ),
                SizedBox(
                  height: 32.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: Icon(
                        SmzgIconFont.save,
                        size: 48.sp,
                      ),
                      onPressed: () async {
                        if (!await PermissionService()
                            .requirePhotosPermission()) {
                          if (await DialogService()
                                  .nativeConfirm("需要相册权限", "是否手工设置相册权限？") ??
                              false) {
                            await PermissionService().openAppSettings();
                          }
                        } else {
                          await ImageSave.saveImage(
                              "png",
                              await QrManager().buildQrCodeImageData(
                                jsonEncode(passwordCard.toJson()),
                                size: 400,
                              ));
                          await DialogService().nativeAlert("", "保存成功");
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.share,
                        size: 48.sp,
                      ),
                      onPressed: () async {
                        if (await PermissionService()
                            .requireStoragePermission()) {
                          final String path = await QrManager().saveImageData(
                              await QrManager().buildQrCodeImageData(
                                  jsonEncode(passwordCard.toJson()),
                                  size: 400));
                          await ShareExtend.share(path, "image",
                              sharePanelTitle: passwordCard.nickName,
                              subject: passwordCard.nickName);
                        } else {
                          if (await DialogService().nativeConfirm(
                              "需要存储权限", "是否手工设置存储权限？",
                              ok: "是", cancel: "否")) {
                            PermissionService().openAppSettings();
                          }
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.print,
                        size: 48.sp,
                      ),
                      onPressed: () async {
                        if (await PermissionService()
                            .requireStoragePermission()) {
                          await this._print(passwordCard);
                        } else {
                          if (await DialogService().nativeConfirm(
                              "需要存储权限", "是否手工设置存储权限？",
                              ok: "是", cancel: "否")) {
                            PermissionService().openAppSettings();
                          }
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

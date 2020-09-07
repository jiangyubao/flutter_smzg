import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_smzg/model/password_card.dart';
import 'package:flutter_smzg/service/statefull/password_card_list_state.dart';
import 'package:image_save/image_save.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_extend/share_extend.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PasswordCardImagePage extends StatelessWidget {
  final PasswordCard passwordCard;
  PasswordCardImagePage({this.passwordCard});
  Widget build(BuildContext context) {
    return Consumer<PasswordCardListState>(
      builder: (context, accountListState, child) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(passwordCard.nickName),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () async {
                  final File file = null;
                  await ShareExtend.share(file.path, "image",
                      sharePanelTitle: passwordCard.nickName,
                      subject: passwordCard.nickName);
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Card(
                    child: Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: 20.h, vertical: 20.w),
                      child: QrImage(
                        size: 672.w,
                        foregroundColor: Theme.of(context).accentColor,
                        data: jsonEncode(passwordCard.toJson()),
                        version: QrVersions.auto,
                      ),
                    ),
                  ),
                ),
                CupertinoButton(
                  child: const Text("保存"),
                  onPressed: () async {
                    if (await PermissionService().requirePhotosPermission()) {
                      final File f = null;
                      await ImageSave.saveImage("png", f.readAsBytesSync());
                    } else {
                      if (await DialogService().nativeConfirm(
                          "需要相机权限", "是否手工设置相机权限？",
                          ok: "是", cancel: "否")) {
                        PermissionService().openAppSettings();
                      }
                    }
                  },
                ),
                CupertinoButton(
                  child: const Text("分享"),
                  onPressed: () async {
                    if (await PermissionService().requirePhotosPermission()) {
                      final File f = null;
                      await ImageSave.saveImage("png", f.readAsBytesSync());
                    } else {
                      if (await DialogService().nativeConfirm(
                          "需要相机权限", "是否手工设置相机权限？",
                          ok: "是", cancel: "否")) {
                        PermissionService().openAppSettings();
                      }
                    }
                  },
                ),
                CupertinoButton(
                  child: const Text("打印"),
                  onPressed: () async {
                    if (await PermissionService().requirePhotosPermission()) {
                      final File f = null;
                      await ImageSave.saveImage("png", f.readAsBytesSync());
                    } else {
                      if (await DialogService().nativeConfirm(
                          "需要相机权限", "是否手工设置相机权限？",
                          ok: "是", cancel: "否")) {
                        PermissionService().openAppSettings();
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

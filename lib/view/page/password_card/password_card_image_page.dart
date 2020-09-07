import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_smzg/model/password_card.dart';
import 'package:flutter_smzg/service/statefull/password_card_list_state.dart';
import 'package:image_save/image_save.dart';
import 'package:qr_flutter/qr_flutter.dart';
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
                        Icons.save,
                        size: 48.sp,
                      ),
                      onPressed: () async {
                        if (await PermissionService()
                            .requirePhotosPermission()) {
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
                    IconButton(
                      icon: Icon(
                        Icons.share,
                        size: 48.sp,
                      ),
                      onPressed: () async {
                        if (await PermissionService()
                            .requirePhotosPermission()) {
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
                    IconButton(
                      icon: Icon(
                        Icons.print,
                        size: 48.sp,
                      ),
                      onPressed: () async {
                        if (await PermissionService()
                            .requirePhotosPermission()) {
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
              ],
            ),
          ),
        );
      },
    );
  }
}

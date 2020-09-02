import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_fordova/flutter_fordova.dart';
import 'package:flutter_svprogresshud/flutter_svprogresshud.dart';
import 'package:flutter_smzg/manager/statefull/password_list_state.dart';

class HttpManager {
  factory HttpManager() => _instance;
  HttpManager._();
  static HttpManager _instance = HttpManager._();
  Future<void> upload(
      BuildContext context, PasswordListState accountListState) async {
    if (await DialogService()
        .nativeConfirm("备份数据提示", "是否要把本地云端备份到云端", ok: "是", cancel: "否")) {
      int phoneId = await this._findId();
      String token =
          StorageService().sharedPreferences.getString("auth_token_key");
      if (token == null) {
        if (await this._jverifyEnsure(context)) {
          token = await this._findAuthToken(context, phoneId);
          if (token == null) {
            await DialogService().nativeAlert("操作失败", "授权失败");
          } else {
            StorageService()
                .sharedPreferences
                .setString("auth_token_key", token);
          }
        }
      }
      if (token != null) {
        SVProgressHUD.show("备份中...");
        bool result = await JssService().save(
          token,
          jsonEncode(accountListState.toJson()),
        );
        SVProgressHUD.dismiss();
        if (result) {
          await DialogService().nativeAlert("操作成功", "云端备份成功");
        } else {
          await DialogService().nativeAlert("操作失败", "云端备份失败");
        }
      }
    }
  }

  Future<void> download(
      BuildContext context, PasswordListState accountListState) async {
    if (await DialogService()
        .nativeConfirm("云端恢复", "是否要把云端数据下载到本地", ok: "是", cancel: "否")) {
      int phoneId = await this._findId();
      String token =
          StorageService().sharedPreferences.getString("auth_token_key");
      if (token == null) {
        if (await this._jverifyEnsure(context)) {
          token = await this._findAuthToken(context, phoneId);
          if (token == null) {
            await DialogService().nativeAlert("操作失败", "授权失败");
          } else {
            StorageService()
                .sharedPreferences
                .setString("auth_token_key", token);
          }
        }
      }
      if (token != null) {
        SVProgressHUD.show("恢复中...");
        String body = await JssService().load(token);
        SVProgressHUD.dismiss();
        if (body != null && body != '') {
          accountListState.fromJson(jsonDecode(body));
          await DialogService().nativeAlert("操作成功", "云端恢复成功");
        } else {
          await DialogService().nativeAlert("操作失败", "云端恢复失败");
        }
      }
    }
  }

  Future<int> _findId() async {
    var iosDeviceInfo = await PlatformService().getDeviceInfo();
    return iosDeviceInfo.name.hashCode;
  }

  Future<bool> _jverifyEnsure(BuildContext context) async {
    try {
      if (await JVerifyService().isInitSuccess() == false) {
        await DialogService().nativeAlert("一键登录初始化失败", "请重新启动");
        return false;
      }
      if (await JVerifyService().checkVerifyEnable() == false) {
        await DialogService().nativeAlert("不支持一键登录", "请开启4G网络");
        return false;
      }
      return true;
    } catch (e, s) {
      Logger.printErrorStack(e, s);
      return false;
    }
  }

  Future<String> _findAuthToken(BuildContext context, int phoneId) async {
    try {
      Map<dynamic, dynamic> map = await JVerifyService().loginAuth(context);
      if (map != null) {
        if (map['code'] == 6000) {
          String message = map['message'];
          return await JssService().auth("$phoneId", message);
        }
      }
    } catch (e, s) {
      Logger.printErrorStack(e, s);
    }
    return null;
  }
}

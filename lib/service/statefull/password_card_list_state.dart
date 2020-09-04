import 'dart:convert';

import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_fordova/flutter_fordova.dart';
import 'package:flutter_smzg/model/password_card.dart';
import 'package:flutter_smzg/service/stateless/password_card_service.dart';

///provider状态对象
class PasswordCardListState extends RefreshListViewState<PasswordCard> {
  PasswordCardListState();

  ///是否显示隐私协议、用户条款对话框
  bool _showUserAgreement = false;
  bool localAuth = false;
  Future<bool> requestLocalAuth() async {
    localAuth =
        !localAuth ? await DialogService().localAuth("需要本地认证以保护密码卡") : true;
    return localAuth;
  }

  ///给安卓使用的，为了防止误按返回键程序退出，需要增加点击频率限制
  DateTime _lastPressed;
  bool get showUserAgreement {
    return _showUserAgreement;
  }

  ///设置是否显示隐私协议、用户条款对话框状态
  Future<void> updateShowUserAgreement(bool val) async {
    await StorageService().sharedPreferences.setBool("showUserAgreement", val);
    _showUserAgreement = val;
    this.notifyListeners();
  }

  DateTime get lastPressed => _lastPressed;
  set lastPressed(DateTime last) {
    _lastPressed = last;
    this.notifyListeners();
  }

  ///初始化
  Future<void> init() async {
    _showUserAgreement =
        StorageService().sharedPreferences.getBool("showUserAgreement") ?? true;
    Logger.info("initData...");
    await this.initData();
    this.notifyListeners();
  }

  ///加载数据
  Future<List<PasswordCard>> loadData({int pageNum}) async {
    return PasswordCardService().find(pageNumber: pageNum, pageSize: 50);
  }

  ///删除
  Future<bool> delete(int id) async {
    bool result = await PasswordCardService().delete(id);
    if (result) {
      this.list.removeWhere((u) => u.id == id);
    }
    this.notifyListeners();
    return result;
  }

  ///添加
  Future<int> insert(PasswordCard passwordCard) async {
    int id = await PasswordCardService().insert(passwordCard);
    if (id >= 0) {
      list.add(passwordCard);
      this.setIdle();
      this.notifyListeners();
    }
    return id;
  }

  ///修改
  Future<bool> update(PasswordCard passwordCard) async {
    bool result = await PasswordCardService().update(passwordCard);
    if (result) {
      list
          .firstWhere((element) => element.id == passwordCard.id)
          .copy(passwordCard);
      this.notifyListeners();
    }
    return result;
  }

  ///转换为json，其中图片要转换为base64
  String toBase64Json() {
    String array =
        list.map((e) => jsonEncode(e.toBase64Json())).toList().join(',');
    return '[$array]';
  }

  ///从base64的json中还原
  Future<bool> fromBase64Json(String json) async {
    try {
      await PasswordCardService().clear();
      this.list.clear();
      List<dynamic> array = jsonDecode(json);
      array.forEach((element) {
        PasswordCard passwordCard = PasswordCard.fromBase64Json(element);
        this.insert(passwordCard);
      });
      this.notifyListeners();
      return true;
    } catch (e, s) {
      Logger.printErrorStack(e, s);
      return false;
    }
  }

  void updatePasswordShow(int id, bool showPassword) {
    this.list.firstWhere((element) => element.id == id).showPassword =
        !showPassword;
    this.notifyListeners();
  }
}

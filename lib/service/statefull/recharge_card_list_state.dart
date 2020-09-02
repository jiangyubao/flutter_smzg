import 'dart:convert';

import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_fordova/flutter_fordova.dart';
import 'package:flutter_smzg/model/recharge_card.dart';
import 'package:flutter_smzg/service/stateless/recharge_card_service.dart';

///provider状态对象
class RechargeCardListState extends RefreshListViewState<RechargeCard> {
  RechargeCardListState();

  ///是否显示隐私协议、用户条款对话框
  bool _showUserAgreement = false;

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

  int totalInit() {
    List<int> sumList = list.map((e) => e.init).toList();
    int sum = 0;
    for (int i in sumList) {
      sum += i;
    }
    return sum;
  }

  int totalCurrent() {
    List<int> sumList = list.map((e) => e.current).toList();
    int sum = 0;
    for (int i in sumList) {
      sum += i;
    }
    return sum;
  }

  ///加载数据
  Future<List<RechargeCard>> loadData({int pageNum}) async {
    return RechargeCardService().find(pageNumber: pageNum, pageSize: 50);
  }

  ///删除
  Future<bool> delete(int id) async {
    bool result = await RechargeCardService().delete(id);
    if (result) {
      this.list.removeWhere((u) => u.id == id);
    }
    this.notifyListeners();
    return result;
  }

  ///添加
  Future<int> insert(RechargeCard rechargeCard) async {
    int id = await RechargeCardService().insert(rechargeCard);
    if (id >= 0) {
      list.add(rechargeCard);
      this.setIdle();
      this.notifyListeners();
    }
    return id;
  }

  ///修改
  Future<bool> update(RechargeCard rechargeCard) async {
    bool result = await RechargeCardService().update(rechargeCard);
    if (result) {
      list
          .firstWhere((element) => element.id == rechargeCard.id)
          .copy(rechargeCard);
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
      await RechargeCardService().clear();
      this.list.clear();
      List<dynamic> array = jsonDecode(json);
      array.forEach((element) {
        RechargeCard rechargeCard = RechargeCard.fromBase64Json(element);
        this.insert(rechargeCard);
      });
      this.notifyListeners();
      return true;
    } catch (e, s) {
      Logger.printErrorStack(e, s);
      return false;
    }
  }
}

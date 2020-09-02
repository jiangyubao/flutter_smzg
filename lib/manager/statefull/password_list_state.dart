import 'package:flutter_smzg/model/password.dart';
import 'package:flutter_smzg/manager/stateless/data_manager.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_fordova/flutter_fordova.dart';

class PasswordListState extends RefreshListViewState<Password> {
  PasswordListState();
  Future<void> init() async {
    Logger.info("initData...");
    await this.initData();
    this.notifyListeners();
  }

  Future<List<Password>> loadData({int pageNum}) async {
    return DataManager().find(pageNumber: pageNum, pageSize: 50);
  }

  Future<bool> remove(int id) async {
    bool result = await DataManager().delete(id);
    if (result) {
      this.list.removeWhere((u) => u.id == id);
    }
    this.notifyListeners();
    return result;
  }

  Future<bool> save(Password user) async {
    if (await DataManager().save(user)) {
      if (user.id == -1) {
        list.add(user);
      }
      this.setIdle();
      this.notifyListeners();
      return true;
    }
    return false;
  }

  List<dynamic> toJson() {
    return list.map((e) => e.toJson()).toList();
  }

  void fromJson(List<dynamic> mapList) {
    list = mapList.map((e) => Password.fromJson(e)).toList();
    this.notifyListeners();
  }
}

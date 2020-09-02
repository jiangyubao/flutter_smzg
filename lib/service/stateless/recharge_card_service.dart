import 'dart:async';

import 'package:flutter_smzg/model/recharge_card.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_smzg/service/stateless/database_service.dart';

///sqlite数据库服务
class RechargeCardService {
  factory RechargeCardService() => _instance;
  RechargeCardService._();
  static RechargeCardService _instance = RechargeCardService._();

  ///修改昵称
  Future<bool> update(RechargeCard rechargeCard) async {
    RechargeCard find = await this.findByName(rechargeCard.name);
    if (find != null && find.id != rechargeCard.id) {
      Logger.info("存在相同名字的记录");
      return false;
    }
    final int result = await DatabaseService().database.rawUpdate(
        "UPDATE RechargeCard SET name=?,address=?,mobile=?,init=?,current=?,image=?,expiredDate=? WHERE id=?",
        [
          rechargeCard.name,
          rechargeCard.address,
          rechargeCard.mobile,
          rechargeCard.init,
          rechargeCard.current,
          rechargeCard.image,
          rechargeCard.expiredDate,
          rechargeCard.id,
        ]);
    return result == 1;
  }

  ///插入充值卡
  Future<int> insert(RechargeCard rechargeCard) async {
    RechargeCard find = await this.findByName(rechargeCard.name);
    if (find == null) {
      Logger.info("insert |  name: ${rechargeCard.name}");
      final int id = await DatabaseService().database.rawInsert(
          "INSERT INTO RechargeCard(name,address,mobile,init,current,image,expiredDate) VALUES(?,?,?,?,?,?,?)",
          [
            rechargeCard.name,
            rechargeCard.address,
            rechargeCard.mobile,
            rechargeCard.init,
            rechargeCard.current,
            rechargeCard.image,
            rechargeCard.expiredDate
          ]);
      rechargeCard.id = id;

      Logger.info("insert | OK id: $id");
      return id;
    }
    return -1;
  }

  ///删除充值卡

  Future<bool> delete(int id) async {
    Logger.info("delete | id: $id");
    final int count = await DatabaseService()
        .database
        .rawDelete('DELETE FROM RechargeCard WHERE id = ?', [id]);
    Logger.info("deleteRechargeCard | count: $count");
    return count == 1;
  }

  ///清除
  Future<bool> clear() async {
    Logger.info("clear | ");
    final int count = await DatabaseService()
        .database
        .rawDelete('DELETE FROM RechargeCard', []);
    Logger.info("deleteRechargeCard | count: $count");
    return count == 1;
  }

  ///查找充值卡列表
  Future<List<RechargeCard>> find({int pageNumber = 0, int pageSize}) async {
    final String sql = "SELECT * FROM RechargeCard ORDER BY id ASC " +
        (pageSize != null ? " LIMIT ${pageSize * pageNumber}, $pageSize" : "");
    final List<Map<String, dynamic>> list =
        await DatabaseService().database.rawQuery(sql);
    List<RechargeCard> result =
        list.map((m) => RechargeCard.fromJson(m)).toList();
    return result;
  }

  ///按名字查找充值卡
  Future<RechargeCard> findByName(String name) async {
    final String sql = "SELECT * FROM RechargeCard WHERE name=?";
    final List<Map<String, dynamic>> list =
        await DatabaseService().database.rawQuery(sql, [name]);
    List<RechargeCard> result =
        list.map((m) => RechargeCard.fromJson(m)).toList();
    return result.length > 0 ? result[0] : null;
  }
}

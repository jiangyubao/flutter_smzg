import 'dart:async';

import 'package:flutter_smzg/model/password_card.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_smzg/service/stateless/db_service.dart';

///sqlite数据库服务
class PasswordCardService {
  factory PasswordCardService() => _instance;
  PasswordCardService._();
  static PasswordCardService _instance = PasswordCardService._();

  ///修改昵称
  Future<bool> update(PasswordCard passwordCard) async {
    PasswordCard find = await this.findByName(passwordCard.nickName);
    if (find != null && find.id != passwordCard.id) {
      Logger.info("存在相同名字的记录");
      return false;
    }
    final int result = await DbService().database.rawUpdate(
        "UPDATE PasswordCard SET nickName=?,url=?,userName=?,sitePassword=? WHERE id=?",
        [
          passwordCard.nickName,
          passwordCard.url,
          passwordCard.userName,
          passwordCard.sitePassword,
          passwordCard.id,
        ]);
    return result == 1;
  }

  ///插入密码卡
  Future<int> insert(PasswordCard passwordCard) async {
    PasswordCard find = await this.findByName(passwordCard.nickName);
    if (find == null) {
      Logger.info("insert |  name: ${passwordCard.nickName}");
      final int id = await DbService().database.rawInsert(
          "INSERT INTO PasswordCard(nickName,url,userName,sitePassword) VALUES(?,?,?,?)",
          [
            passwordCard.nickName,
            passwordCard.url,
            passwordCard.userName,
            passwordCard.sitePassword
          ]);
      passwordCard.id = id;

      Logger.info("insert | OK id: $id");
      return id;
    }
    return -1;
  }

  ///删除密码卡

  Future<bool> delete(int id) async {
    Logger.info("delete | id: $id");
    final int count = await DbService()
        .database
        .rawDelete('DELETE FROM PasswordCard WHERE id = ?', [id]);
    Logger.info("deletePasswordCard | count: $count");
    return count == 1;
  }

  ///清除
  Future<bool> clear() async {
    Logger.info("clear | ");
    final int count =
        await DbService().database.rawDelete('DELETE FROM PasswordCard', []);
    Logger.info("deletePasswordCard | count: $count");
    return count == 1;
  }

  ///查找密码卡列表
  Future<List<PasswordCard>> find({int pageNumber = 0, int pageSize}) async {
    final String sql = "SELECT * FROM PasswordCard ORDER BY id ASC " +
        (pageSize != null ? " LIMIT ${pageSize * pageNumber}, $pageSize" : "");
    final List<Map<String, dynamic>> list =
        await DbService().database.rawQuery(sql);
    List<PasswordCard> result =
        list.map((m) => PasswordCard.fromJson(m)).toList();
    return result;
  }

  ///按名字查找密码卡
  Future<PasswordCard> findByName(String nickName) async {
    final String sql = "SELECT * FROM PasswordCard WHERE nickName=?";
    final List<Map<String, dynamic>> list =
        await DbService().database.rawQuery(sql, [nickName]);
    List<PasswordCard> result =
        list.map((m) => PasswordCard.fromJson(m)).toList();
    return result.length > 0 ? result[0] : null;
  }
}

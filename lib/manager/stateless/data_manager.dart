import 'dart:async';
import 'dart:io';

import 'package:flutter_smzg/model/password.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

///sqlite数据库服务
class DataManager {
  factory DataManager() => _instance;
  DataManager._() {
    //this.init();
  }
  static DataManager _instance = DataManager._();
  static const _kDatabaseName = "clientd.db";

  ///DDL
  static const _kDDL = '''
        CREATE TABLE IF NOT EXISTS `Password` (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name VARCHAR (32) UNIQUE,
          account VARCHAR (32) ,
          `password` VARCHAR (32),
          description VARCHAR (32) 
        );
        CREATE INDEX IF NOT EXISTS idx_name ON Account(name);
        ''';

  ///数据库对象
  Database _database;

  ///数据库初始化
  Future<void> init() async {
    try {
      String databasePath = await this._initDatabasePath();
      _database = await openDatabase(databasePath);
      Logger.info("openDatabase OK");
      await this._initDDL();
    } catch (e, s) {
      Logger.printErrorStack(e, s);
    }
  }

  Future<void> dispose() async {
    await _database.close();
  }

  ///初始化数据库路径
  Future<String> _initDatabasePath() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _kDatabaseName);
    if (!await Directory(dirname(path)).exists()) {
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (e, s) {
        Logger.printErrorStack(e, s);
      }
    }
    Logger.info("_initDatabasePath | path: $path");
    return path;
  }

  ///初始化DDL
  Future<void> _initDDL() async {
    final List<String> ddlList = _kDDL.split(";");
    for (int i = 0; i < ddlList.length; i++) {
      String ddl = ddlList[i].trim();
      if (ddl.isNotEmpty) {
        Logger.info("execute ddl: $ddl");
        await _database.execute(ddlList[i]);
        Logger.info("execute ok");
      }
    }
    Logger.info("_initDDL OK");
  }

  ///插入用户
  Future<bool> save(Password password) async {
    Logger.info("addAccount |  name: ${password.name}");
    final Password find = await this.findByName(password.name);
    if (find != null) {
      final int count = await _database.rawUpdate(
          "UPDATE INTO `Password` SET name=?,account=?,`password`=?,description=? WHERE id=?",
          [
            password.name,
            password.account,
            password.password,
            password.description,
            password.id
          ]);
      return count == 1;
    }
    final int id = await _database.rawInsert(
        "INSERT INTO `Password`(name,account,`password`,description) VALUES(?,?,?,?)",
        [
          password.name,
          password.account,
          password.password,
          password.description
        ]);
    password.id = id;
    Logger.info("insert | OK id: $id");
    return id >= 0;
  }

  ///删除用户

  Future<bool> delete(int id) async {
    Logger.info("deleteAccount | id: $id");
    final int count =
        await _database.rawDelete('DELETE FROM Account WHERE id = ?', [id]);
    Logger.info("deleteAccount | count: $count");
    return count == 1;
  }

  ///查找用户列表
  Future<List<Password>> find({int pageNumber = 0, int pageSize}) async {
    final String sql = "SELECT * FROM `Password` ORDER BY id ASC " +
        (pageSize != null ? " LIMIT ${pageSize * pageNumber}, $pageSize" : "");
    final List<Map<String, dynamic>> list = await _database.rawQuery(sql);
    List<Password> result = list.map((m) => Password.fromJson(m)).toList();
    //result.sort((a, b) => a.id - b.id);
    return result;
  }

  ///根据name查找用户
  Future<Password> findByName(String name) async {
    final List<Map<String, dynamic>> list = await _database
        .rawQuery("SELECT * FROM `Password` WHERE name=? LIMIT 1", [name]);
    return list.isNotEmpty ? Password.fromJson(list[0]) : null;
  }
}

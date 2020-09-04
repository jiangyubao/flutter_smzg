import 'dart:async';
import 'dart:io';

import 'package:flutter_common/flutter_common.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

///sqlite数据库服务
class DbService {
  factory DbService() => _instance;
  DbService._();
  static DbService _instance = DbService._();
  static const _databaseName = "password_card.db";

  ///DDL
  static const _ddl = '''
      CREATE TABLE IF NOT EXISTS PasswordCard (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nickName VARCHAR (8) UNIQUE,
        url VARCHAR (32),
        userName VARCHAR (16),
        sitePassword VARCHAR (16)
      );
  ''';

  ///数据库对象
  Database _database;
  Database get database => _database;

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
    final path = join(databasePath, _databaseName);
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
    final List<String> ddlList = _ddl.split(";");
    for (int i = 0; i < ddlList.length; i++) {
      if (ddlList[i].trim().isNotEmpty) {
        Logger.info("execute ddl: ${ddlList[i]}");
        await _database.execute(ddlList[i]);
        Logger.info("execute ok");
      }
    }
    Logger.info("_initDDL OK");
  }
}

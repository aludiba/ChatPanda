import 'package:chatgpt_flutter/util/hi_const.dart';
import 'package:chatgpt_flutter/util/hi_utils.dart';
import 'package:chatgpt_flutter/util/preferences_helper.dart';
import 'package:flutter/cupertino.dart';
// import 'package:login_sdk/dao/login_dao.dart';
import 'package:sqflite/sqflite.dart';

class HiDBManager {
  /// 多实例
  static final Map<String, HiDBManager> _storageMap = {};

  ///数据库名称
  final String _dbName;

  ///数据库实例
  late Database _db;

  ///获取HiStorage实例
  static Future<HiDBManager> instance({required String dbName}) async {
    if (!dbName.endsWith('.db')) {
      dbName = '$dbName.db';
    }
    var storage = _storageMap[dbName];
    storage ??= await HiDBManager._(dbName: dbName)._init();
    return storage;
  }

  Database get db {
    return _db;
  }

  ///多实例模式，一个数据库一个实例
  HiDBManager._({required String dbName}) : _dbName = dbName {
    _storageMap[_dbName] = this;
  }

  ///初始化数据库
  Future<HiDBManager> _init() async {
    _db = await openDatabase(_dbName);
    debugPrint('db ver:${await _db.getVersion()}');
    return this;
  }

  ///销毁数据库
  void destroy() {
    _db.close();
    _storageMap.remove(_dbName);
  }

  ///账号唯一标识
  static Future<String> getAccountHash() async {
    String accountStr = '';
    if (HiUtils.isIOS()) {
      ///使用iCloud账号标识
      accountStr = await PreferencesHelper.loadData(HiConst.iCloudUserID) ?? '';
    }
    if (accountStr.isEmpty) {
      accountStr = 'test';
      // accountStr = 'test1';
    }
    // AILogger.log('accountStr:$accountStr');
    return accountStr;
  }
}

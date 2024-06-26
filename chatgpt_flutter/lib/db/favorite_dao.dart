import 'package:chatgpt_flutter/db/hi_db_manager.dart';
import 'package:chatgpt_flutter/db/table_name.dart';
import 'package:chatgpt_flutter/model/favorite_model.dart';
import 'package:sqflite/sqflite.dart';

///收藏功能数据操作接口
abstract class IFavorite {
  // 收藏精彩内容
  Future<int?> addFavorite(FavoriteModel model);
  // 移除精彩内容
  Future<int?> removeFavorite(FavoriteModel model);
  // 获取精彩内容
  Future<List<FavoriteModel>> getFavoriteList();
}

class FavoriteDao implements IFavorite, ITable {
  final HiDBManager storage;
  @override
  String tableName = 'tb_favorite';

  ///构造方法中，进行数据表的检查和创建
  FavoriteDao(this.storage) {
    // id	integer	主键、自增
    // cid	integer	来自于哪个会话标识
    // content	text	消息内容
    // createdAt	integer	消息创建时间
    // ownerName	text	发送者昵称
    //创建表
    storage.db.execute(
        'create table if not exists $tableName (id integer primary key autoincrement'
        ', cid integer, ownerName text, content text, createdAt integer);');
  }

  @override
  Future<int?> addFavorite(FavoriteModel model) async {
    var result = await storage.db.insert(tableName, model.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return result;
  }

  @override
  Future<int?> removeFavorite(FavoriteModel model) async {
    String whereClause = 'createdAt = ${model.createdAt}';
    var result = await storage.db.delete(tableName, where: whereClause);
    return result;
  }

  @override
  Future<List<FavoriteModel>> getFavoriteList() async {
    var results =
        await storage.db.rawQuery('select * from $tableName order by id desc');
    var list = results.map((item) => FavoriteModel.fromJson(item)).toList();
    return list;
  }
}

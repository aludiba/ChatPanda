import 'package:chatgpt_flutter/db/hi_db_manager.dart';
import 'package:chatgpt_flutter/db/table_name.dart';
import 'package:chatgpt_flutter/model/favorite_model.dart';
import 'package:sqflite/sqflite.dart';

///收藏功能数据操作接口
abstract class IFavoriteImage {
  // 收藏精彩图片
  Future<int?> addFavoriteImage(FavoriteImageModel imageModel);
  // 移除精彩图片
  Future<int?> removeFavoriteImage(FavoriteImageModel imageModel);
  // 删除所有精彩图片
  Future<int> deleteAllFavoriteImages();
  // 获取所有精彩图片
  Future<List<FavoriteImageModel>> getFavoriteImages();
}

class FavoriteImageDao implements IFavoriteImage, ITable {
  final HiDBManager storage;
  @override
  String tableName = 'tb_favoriteImage';

  ///构造方法中，进行数据表的检查和创建
  FavoriteImageDao(this.storage) {
    // id	integer	主键、自增
    // prompt	text	提示词
    // base64	text	图片base64编码
    // updateAt	integer	图片更新(创建)时间
    //创建表
    storage.db.execute(
        'create table if not exists $tableName (id integer primary key autoincrement'
        ', prompt	text, base64	text, updateAt integer);');
  }

  @override
  Future<int?> addFavoriteImage(FavoriteImageModel imageModel) async {
    var result = await storage.db.insert(tableName, imageModel.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return result;
  }

  @override
  Future<int?> removeFavoriteImage(FavoriteImageModel imageModel) async {
    String whereClause = 'updateAt = ${imageModel.updateAt}';
    var result = await storage.db.delete(tableName, where: whereClause);
    return result;
  }

  @override
  Future<int> deleteAllFavoriteImages() async {
    var result = await storage.db.delete(tableName);
    return result;
  }

  @override
  Future<List<FavoriteImageModel>> getFavoriteImages() async {
    var results =
        await storage.db.rawQuery('select * from $tableName order by id desc');
    var list =
        results.map((item) => FavoriteImageModel.fromJson(item)).toList();
    return list;
  }
}

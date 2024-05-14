import 'package:chatgpt_flutter/db/hi_db_manager.dart';
import 'package:chatgpt_flutter/db/table_name.dart';
import 'package:chatgpt_flutter/model/imageGeneration_model.dart';

///消息表数据操作接口
abstract class IImage {
  void saveImage(ImageGenerationModel model);

  Future<int> deleteAllImages();

  Future<int> deleteImage(int updateAt);

  void update(ImageGenerationModel model);

  Future<List<ImageGenerationModel>> getAllImage();

  ///分页查询，pageIndex页码从1开始，pageSize每页显示的数据量
  Future<List<ImageGenerationModel>> getImages(
      {int pageIndex = 1, int pageSize = 20});

  Future<int> getImageCount();
}

class ImageDao implements IImage, ITable {
  final HiDBManager storage;

  @override
  String tableName = 'tb_image';
  //  字段	类型	备注
  //  id	integer	主键、自增
  //  prompt	text	提示词
  //  updateAt	integer	创建/更新时间
  //  base64	text	图片的base64字符串
  //  isFavorite bool 是否收藏
  ImageDao(this.storage) {
    storage.db.execute(
        'create table if not exists $tableName (id integer primary key autoincrement, prompt text,'
        'updateAt integer, base64 text, isFavorite bool)');
  }

  @override
  Future<int> deleteAllImages() async {
    var result = await storage.db.delete(tableName);
    return result;
  }

  @override
  Future<int> deleteImage(int updateAt) async {
    var result =
        await storage.db.delete(tableName, where: 'updateAt=$updateAt');
    return result;
  }

  @override
  Future<List<ImageGenerationModel>> getAllImage() async {
    var results =
        await storage.db.rawQuery('select * from $tableName order by id asc');

    ///将查询结果转成Dart Models以方便使用
    var list =
        results.map((item) => ImageGenerationModel.fromJson(item)).toList();
    return list;
  }

  @override
  Future<int> getImageCount() async {
    var result =
        await storage.db.query(tableName, columns: ['COUNT(*) as cnt']);
    return result.first['cnt'] as int;
  }

  @override
  Future<List<ImageGenerationModel>> getImages(
      {int pageIndex = 1, int pageSize = 15}) async {
    var offset = (pageIndex - 1) * pageSize;
    var results = await storage.db.rawQuery(
        'select * from $tableName order by id desc limit $pageSize offset $offset');

    ///将查询结果转成Dart Model以方便使用
    var list =
        results.map((item) => ImageGenerationModel.fromJson(item)).toList();

    ///反转列表以适应分页查询
    return List.from(list.reversed);
  }

  @override
  void saveImage(ImageGenerationModel model) {
    storage.db.insert(tableName, model.toJson());
  }

  @override
  void update(ImageGenerationModel model) {
    String whereClause = 'updateAt = ?';
    List<dynamic> whereArgs = [model.updateAt];
    Map<String, dynamic> jsonMap = model.toJson();

    /// id有可能为空
    if (model.id == null) {
      jsonMap.remove('id');
    }
    storage.db
        .update(tableName, jsonMap, where: whereClause, whereArgs: whereArgs);
  }
}

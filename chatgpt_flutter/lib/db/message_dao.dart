import 'package:chat_message/models/message_model.dart';
import 'package:chatgpt_flutter/db/hi_db_manager.dart';
import 'package:chatgpt_flutter/db/table_name.dart';

///消息表数据操作接口
abstract class IMessage {
  void saveMessage(MessageModel model);

  Future<int> deleteMessage(int id);

  Future<int> deleteStreamMessage(String streamId);

  void update(MessageModel model);

  void updateStream(MessageModel model);

  Future<List<MessageModel>> getAllMessage();

  ///分页查询，pageIndex页码从1开始，pageSize每页显示的数据量
  Future<List<MessageModel>> getMessages(
      {int pageIndex = 1, int pageSize = 20});

  Future<int> getMessageCount();
}

class MessageDao implements IMessage, ITable {
  final HiDBManager storage;

  ///会话id
  final int cid;
  @override
  String tableName = '';

  //  字段	类型	备注
//  id	integer	主键、自增
//  streamId	text	本轮对话的标识id
//  content	text	消息内容
//  createdAt	integer	消息创建时间
//  ownerName	text	发送者昵称
//  ownerType	text	发送者类型（receiver, sender）
//  avatar	text	发送者头像
//  isFavorite bool 是否收藏
  MessageDao(this.storage, {required this.cid})
      : tableName = tableNameByCid(cid) {
    storage.db.execute(
        'create table if not exists $tableName (id integer primary key autoincrement, content text,'
        'createdAt integer, streamId text, ownerName text, ownerType text, avatar text, isFavorite bool)');
  }

  ///获取带cid的表名称
  static String tableNameByCid(int cid) {
    return 'tb_$cid';
  }

  @override
  Future<int> deleteMessage(int id) {
    return storage.db.delete(tableName, where: 'id=$id');
  }

  @override
  Future<int> deleteStreamMessage(String streamId) {
    return storage.db.delete(
      tableName,
      where: 'streamId = ?',
      whereArgs: [streamId],
    );
  }

  @override
  Future<List<MessageModel>> getAllMessage() async {
    var results =
        await storage.db.rawQuery('select * from $tableName order by id asc');

    ///将查询结果转成Dart Models以方便使用
    var list = results.map((item) => MessageModel.fromJson(item)).toList();
    return list;
  }

  @override
  Future<int> getMessageCount() async {
    var result =
        await storage.db.query(tableName, columns: ['COUNT(*) as cnt']);
    return result.first['cnt'] as int;
  }

  @override
  Future<List<MessageModel>> getMessages(
      {int pageIndex = 1, int pageSize = 15}) async {
    var offset = (pageIndex - 1) * pageSize;
    var results = await storage.db.rawQuery(
        'select * from $tableName order by id desc limit $pageSize offset $offset');

    ///将查询结果转成Dart Model以方便使用
    var list = results.map((item) => MessageModel.fromJson(item)).toList();

    ///反转列表以适应分页查询
    return List.from(list.reversed);
  }

  @override
  void saveMessage(MessageModel model) {
    storage.db.insert(tableName, model.toJson());
  }

  @override
  void update(MessageModel model) {
    String whereClause = 'createdAt = ?';
    List<dynamic> whereArgs = [model.createdAt];
    Map<String, dynamic> jsonMap = model.toJson();

    /// id有可能为空
    if (model.id == null) {
      jsonMap.remove('id');
    }
    storage.db
        .update(tableName, jsonMap, where: whereClause, whereArgs: whereArgs);
  }

  @override
  void updateStream(MessageModel model) {
    String whereClause = 'streamId = ?';
    List<dynamic> whereArgs = [model.streamId];
    Map<String, dynamic> jsonMap = model.toJson();

    /// id有可能为空
    if (model.id == null) {
      jsonMap.remove('id');
    }
    storage.db
        .update(tableName, jsonMap, where: whereClause, whereArgs: whereArgs);
  }
}

///收藏内容模型
class FavoriteModel {
  /// primary key autoincrement
  int? id;

  ///会话cid(来自于哪次对话的标识)
  int? cid;

  ///发送者昵称
  String? ownerName;

  /// 消息的创建时间，单位milliseconds since。
  int? createdAt;

  ///消息内容
  String content;

  FavoriteModel(
      {this.id,
      this.cid,
      this.ownerName,
      this.createdAt,
      required this.content});

  factory FavoriteModel.fromJson(Map<String, dynamic> json) => FavoriteModel(
        id: json['id'],
        cid: json['cid'],
        ownerName: json['ownerName'],
        createdAt: json['createdAt'],
        content: json['content'],
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['cid'] = cid;
    data['ownerName'] = ownerName;
    data['createdAt'] = createdAt;
    data['content'] = content;
    return data;
  }
}

///收藏图片模型
class FavoriteImageModel {
  /// primary key autoincrement
  int? id;

  // 提示词
  String? prompt;

  ///图片base64
  String? base64;

  /// 图片的创建时间，单位milliseconds since。
  int? updateAt;

  FavoriteImageModel({this.id, this.updateAt, this.prompt, this.base64});

  factory FavoriteImageModel.fromJson(Map<String, dynamic> json) =>
      FavoriteImageModel(
        id: json['id'],
        updateAt: json['updateAt'],
        prompt: json['prompt'],
        base64: json['base64'],
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['updateAt'] = updateAt;
    data['prompt'] = prompt;
    data['base64'] = base64;
    return data;
  }
}

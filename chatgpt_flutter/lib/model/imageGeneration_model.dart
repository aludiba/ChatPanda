/// 文生图模型
class ImageGenerationModel {
  // 记录id
  int? id;
  // 提示词
  String? prompt;
  // 创建/更新时间
  int updateAt;
  // 图片的base64字符串
  String? base64;

  ///是否被收藏(设为"精彩")
  bool? isFavorite;

  ///是否展示创建时间
  bool showCreatedTime = false;

  ImageGenerationModel(
      {this.id,
      this.prompt,
      required this.updateAt,
      this.base64,
      this.isFavorite});

  factory ImageGenerationModel.fromJson(Map<String, dynamic> json) =>
      ImageGenerationModel(
          id: json['id'],
          prompt: json['prompt'],
          updateAt: json['updateAt'],
          isFavorite: json['isFavorite'] == 1,
          base64: json['base64']);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['prompt'] = prompt;
    data['updateAt'] = updateAt;
    data['base64'] = base64;
    data['isFavorite'] = isFavorite;
    return data;
  }
}

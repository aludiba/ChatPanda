/// 帮助页面小贴士列表模型
class HelpTipModel {
  String title;
  String content;
  String? url;

  HelpTipModel({required this.title, required this.content, this.url});

  factory HelpTipModel.fromJson(Map<String, dynamic> json) => HelpTipModel(
      title: json['title'], content: json['content'], url: json['url']);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['content'] = content;
    data['url'] = url;
    return data;
  }
}

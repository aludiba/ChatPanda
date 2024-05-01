class AIWenXinWSTResponse {
  //  本轮对话的id
  String? id;
  //  回包类型chat.completion：多轮对话返回
  String? object;
  //  时间戳
  int? created;
  //  生成图片结果
  List<ImageData>? data;
  // token统计信息
  Usage? usage;
  //  错误码,110表示Access Token失效，需要重新获取新的Access Token
  int? errorCode;
  // 错误描述信息，帮助理解和解决发生的错误
  String? errorMsg;

  AIWenXinWSTResponse({id, object, created, data, usage, errorCode, errorMsg});

  AIWenXinWSTResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    object = json['object'];
    created = json['created'];
    usage = json['usage'] != null ? Usage.fromJson(json['usage']) : null;
    if (json['data'] != null) {
      data = <ImageData>[];
      json['data'].forEach((v) {
        data!.add(ImageData.fromJson(v));
      });
    }
    errorCode = json['error_code'];
    errorMsg = json['error_msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dic = <String, dynamic>{};
    dic['id'] = id;
    dic['object'] = object;
    dic['created'] = created;
    if (data != null) {
      dic['data'] = data!.map((v) => v.toJson()).toList();
    }
    if (usage != null) {
      dic['usage'] = usage!.toJson();
    }
    dic['error_code'] = errorCode;
    dic['error_msg'] = errorMsg;
    return dic;
  }
}

class ImageData {
  //  固定值"image"
  String? object;
  //  图片base64编码内容
  String? b64Image;
  //  序号
  int? index;

  ImageData({object, b64Image, index});

  ImageData.fromJson(Map<String, dynamic> json) {
    object = json['object'];
    b64Image = json['b64_image'];
    index = json['index'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['object'] = object;
    data['b64_image'] = b64Image;
    data['index'] = index;
    return data;
  }
}

class Usage {
  //  问题tokens数
  int? promptTokens;
  // tokens总数
  int? totalTokens;

  Usage({promptTokens, completionTokens, totalTokens, plugins});

  Usage.fromJson(Map<String, dynamic> json) {
    promptTokens = json['prompt_tokens'];
    totalTokens = json['total_tokens'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['prompt_tokens'] = promptTokens;
    data['total_tokens'] = totalTokens;
    return data;
  }
}

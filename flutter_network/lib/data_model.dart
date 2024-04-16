// {
// "code": 0,
// "data": {
// "code": 0,
// "method": "POST",
// "jsonParams": {
// "name": "jack"
// }
// },
// "msg": "SUCCESS."
// }

class DataModel {
  int? code;
  Data? data;
  String? msg;

  DataModel({this.code, this.data, this.msg});

  DataModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data1 = <String, dynamic>{};
    data1['code'] = code;
    if (data != null) {
      data1['data'] = data!.toJson();
    }
    data1['msg'] = msg;
    return data1;
  }
}

class Data {
  int? code;
  String? method;
  NameModel? jsonParams;
  String? requestPrams;

  Data({this.code, this.method, this.jsonParams, this.requestPrams});

  Data.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    method = json['method'];
    jsonParams = json['jsonParams'] != null
        ? NameModel.fromJson(json['jsonParams'])
        : null;
    requestPrams = json['requestPrams'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['method'] = method;
    if (jsonParams != null) {
      data['jsonParams'] = jsonParams!.toJson();
    }
    data['requestPrams'] = requestPrams;
    return data;
  }
}

class NameModel {
  String? name;

  NameModel({this.name});

  NameModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    return data;
  }
}

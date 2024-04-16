class AIWenXinResponse {
  //  本轮对话的id
  String? id;
  //  回包类型chat.completion：多轮对话返回
  String? object;
  //  时间戳
  int? created;
  // 表示当前子句的序号。只有在流式接口模式下会返回该字段
  int? sentenceId;
  // 表示当前子句是否是最后一句。只有在流式接口模式下会返回该字段
  bool? isEnd;
  // 当前生成的结果是否被截断
  bool? isTruncated;
  // 输出内容标识，说明：
  // · normal：输出内容完全由大模型生成，未触发截断、替换
  // · stop：输出结果命中入参stop中指定的字段后被截断
  // · length：达到了最大的token数，根据EB返回结果is_truncated来截断
  // · content_filter：输出内容被截断、兜底、替换为**等
  // · function_call：调用了function call功能
  String? finishReason;
  //  搜索数据，当请求参数enable_citation为true并且触发搜索时，会返回该字段
  SearchInfo? searchInfo;
  //  对话返回结果
  String? result;
  // 表示用户输入是否存在安全风险，是否关闭当前会话，清理历史会话信息
  // · true：是，表示用户输入存在安全风险，建议关闭当前会话，清理历史会话信息
  // · false：否，表示用户输入无安全风险
  bool? needClearHistory;
  // 说明：
  // · 0：正常返回
  // · 其他：非正常
  int? flag;
  // 当need_clear_history为true时，此字段会告知第几轮对话有敏感信息，如果是当前问题，ban_round=-1
  int? banRound;
  // token统计信息
  Usage? usage;
  // 由模型生成的函数调用，包含函数名称，和调用参数
  FunctionCall? functionCall;
  //  错误码,110表示Access Token失效，需要重新获取新的Access Token
  int? errorCode;
  // 错误描述信息，帮助理解和解决发生的错误
  String? errorMsg;

  AIWenXinResponse(
      {id,
      object,
      created,
      sentenceId,
      isEnd,
      isTruncated,
      finishReason,
      searchInfo,
      result,
      needClearHistory,
      flag,
      banRound,
      usage,
      functionCall,
      errorCode,
      errorMsg});

  AIWenXinResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    object = json['object'];
    created = json['created'];
    sentenceId = json['sentence_id'];
    isEnd = json['is_end'];
    isTruncated = json['is_truncated'];
    finishReason = json['finish_reason'];
    searchInfo = json['search_info'] != null
        ? SearchInfo.fromJson(json['search_info'])
        : null;
    result = json['result'];
    needClearHistory = json['need_clear_history'];
    flag = json['flag'];
    banRound = json['ban_round'];
    usage = json['usage'] != null ? Usage.fromJson(json['usage']) : null;
    functionCall = json['function_call'] != null
        ? FunctionCall.fromJson(json['function_call'])
        : null;
    errorCode = json['error_code'];
    errorMsg = json['error_msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['object'] = object;
    data['created'] = created;
    data['sentence_id'] = sentenceId;
    data['is_end'] = isEnd;
    data['is_truncated'] = isTruncated;
    data['finish_reason'] = finishReason;
    if (searchInfo != null) {
      data['search_info'] = searchInfo!.toJson();
    }
    data['result'] = result;
    data['need_clear_history'] = needClearHistory;
    data['flag'] = flag;
    data['ban_round'] = banRound;
    if (usage != null) {
      data['usage'] = usage!.toJson();
    }
    if (functionCall != null) {
      data['function_call'] = functionCall!.toJson();
    }
    data['error_code'] = errorCode;
    data['error_msg'] = errorMsg;
    return data;
  }
}

class SearchInfo {
  // 搜索结果列表
  List<SearchResult>? searchResults;

  SearchInfo({searchResults});

  SearchInfo.fromJson(Map<String, dynamic> json) {
    if (json['search_results'] != null) {
      searchResults = <SearchResult>[];
      json['search_results'].forEach((v) {
        searchResults!.add(SearchResult.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (searchResults != null) {
      data['search_results'] = searchResults!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SearchResult {
  //  序号
  int? index;
  //  搜索结果URL
  String? url;
  //  搜索结果标题
  String? title;

  SearchResult({index, url, title});

  SearchResult.fromJson(Map<String, dynamic> json) {
    index = json['index'];
    url = json['url'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['index'] = index;
    data['url'] = url;
    data['title'] = title;
    return data;
  }
}

class Usage {
  //  问题tokens数
  int? promptTokens;
  //  回答tokens数
  int? completionTokens;
  // tokens总数
  int? totalTokens;
  // plugin消耗的tokens
  List<PluginUsage>? plugins;

  Usage({promptTokens, completionTokens, totalTokens, plugins});

  Usage.fromJson(Map<String, dynamic> json) {
    promptTokens = json['prompt_tokens'];
    completionTokens = json['completion_tokens'];
    totalTokens = json['total_tokens'];
    if (json['plugins'] != null) {
      plugins = <PluginUsage>[];
      json['plugins'].forEach((v) {
        plugins!.add(PluginUsage.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['prompt_tokens'] = promptTokens;
    data['completion_tokens'] = completionTokens;
    data['total_tokens'] = totalTokens;
    if (plugins != null) {
      data['plugins'] = plugins!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PluginUsage {
  //  plugin名称，chatFile：chatfile插件消耗的tokens
  String? name;
  //  解析文档tokens
  int? parseTokens;
  //  请求参数
  int? abstractTokens;
  // 检索文档tokens
  int? searchTokens;
  // 总tokens
  int? totalTokens;

  PluginUsage({name, parseTokens, abstractTokens, searchTokens, totalTokens});

  PluginUsage.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    parseTokens = json['parse_tokens'];
    abstractTokens = json['abstract_tokens'];
    searchTokens = json['search_tokens'];
    totalTokens = json['total_tokens'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['parse_tokens'] = parseTokens;
    data['abstract_tokens'] = abstractTokens;
    data['search_tokens'] = searchTokens;
    data['total_tokens'] = totalTokens;
    return data;
  }
}

class FunctionCall {
  //  触发的function名
  String? name;
  //  模型思考过程
  String? thoughts;
  //  请求参数
  String? arguments;

  FunctionCall({name, thoughts, arguments});

  FunctionCall.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    thoughts = json['thoughts'];
    arguments = json['arguments'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['thoughts'] = thoughts;
    data['arguments'] = arguments;
    return data;
  }
}

class AIWenXinTokenResp {
  //  访问凭证
  String? accessToken;
  //  有效期，Access Token的有效期。
  //  说明：单位是秒，有效期30天
  int? expiresIn;
  String? sessionKey;
  String? refreshToken;
  String? scope;
  String? sessionSecret;

  AIWenXinTokenResp(
      {accessToken, expiresIn, sessionKey, refreshToken, scope, sessionSecret});

  AIWenXinTokenResp.fromJson(Map<String, dynamic> json) {
    accessToken = json['access_token'];
    expiresIn = json['expires_in'];
    sessionKey = json['session_key'];
    refreshToken = json['refresh_token'];
    scope = json['scope'];
    sessionSecret = json['session_secret'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['access_token'] = accessToken;
    data['expires_in'] = expiresIn;
    data['session_key'] = sessionKey;
    data['refresh_token'] = refreshToken;
    data['scope'] = scope;
    data['session_secret'] = sessionSecret;
    return data;
  }
}

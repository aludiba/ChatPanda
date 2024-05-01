import 'package:openai_flutter/core/interfaces/ai_wenxincreate.dart';
import 'package:openai_flutter/http/ai_wenxinhttp.dart';
import 'package:openai_flutter/model/ai_wenxinresponse.dart';
import 'package:openai_flutter/model/ai_wenxinwstresponse.dart';

class AIWenXinCompletion implements AIWenXinCreateInterface {
  @override
  Future<AIWenXinWSTResponse> createWenXinWST(
      {required String accessToken, required String prompt}) async {
    //通过断言来检查参数的合法性，是封装SDK常用的工具
    assert(prompt is String, 'prompt field must be a String');
    return await AIWenXinHttp.post(
        url:
            'https://aip.baidubce.com/rpc/2.0/ai_custom/v1/wenxinworkshop/text2image/sd_xl?access_token=$accessToken',
        onSuccess: (Map<String, dynamic> response) {
          return AIWenXinWSTResponse.fromJson(response);
        },
        body: {
          if (prompt != null) 'prompt': prompt,
        });
  }

  @override
  Future<AIWenXinResponse> createWenXinChat(
      {required String accessToken,
      required List<Map<String, dynamic>> messages}) async {
    //通过断言来检查参数的合法性，是封装SDK常用的工具
    assert(messages is List<Map<String, dynamic>>,
        'messages field must be a List<Map<String, dynamic>>');
    return await AIWenXinHttp.post(
        url:
            'https://aip.baidubce.com/rpc/2.0/ai_custom/v1/wenxinworkshop/chat/completions?access_token=$accessToken',
        onSuccess: (Map<String, dynamic> response) {
          return AIWenXinResponse.fromJson(response);
        },
        body: {
          if (messages != null) 'messages': messages,
        });
  }

  @override
  Future<AIWenXinTokenResp> getWenXinToken(
      {required String clientId, required String clientSecret}) async {
    //通过断言来检查参数的合法性，是封装SDK常用的工具
    assert(clientId is String, 'clientId field must be a String');
    assert(clientSecret is String, 'clientSecret field must be a String');
    return await AIWenXinHttp.post(
        url:
            'https://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials&client_id=$clientId&client_secret=$clientSecret',
        onSuccess: (Map<String, dynamic> response) {
          return AIWenXinTokenResp.fromJson(response);
        });
  }
}

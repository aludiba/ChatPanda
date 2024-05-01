import 'package:openai_flutter/model/ai_wenxinresponse.dart';

abstract class AIWenXinCreateInterface {
  // 获取文心一言-文生图
  Future<AIWenXinWSTResponse> createWenXinWST(
      {required String accessToken, required String prompt});
  // 获取文心一言对话
  Future<AIWenXinResponse> createWenXinChat(
      {required String accessToken,
      required List<Map<String, dynamic>> messages});
  //获取文心一言的token
  Future<AIWenXinTokenResp> getWenXinToken(
      {required String clientId, required String clientSecret});
}

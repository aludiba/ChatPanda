import 'package:openai_flutter/model/ai_wenxinresponse.dart';

abstract class AIWenXinCreateInterface {
  Future<AIWenXinResponse> createWenXinChat(
      {required String accessToken,
      required List<Map<String, dynamic>> messages});
  Future<AIWenXinTokenResp> getWenXinToken(
      {required String clientId, required String clientSecret});
}

import 'dart:convert';

import 'package:chat_message/models/message_model.dart';
import 'package:chatgpt_flutter/util/conversation_context_helper.dart';
import 'package:chatgpt_flutter/util/hi_const.dart';
import 'package:chatgpt_flutter/util/preferences_helper.dart';
import 'package:http/http.dart' as http;
import 'package:openai_flutter/core/ai_completions.dart';
import 'package:openai_flutter/core/ai_wenxincompletions.dart';
import 'package:openai_flutter/model/ai_wenxinwstresponse.dart';
import 'package:openai_flutter/utils/ai_logger.dart';

class CompletionDao {
  final ConversationContextHelper conversationContextHelper =
      ConversationContextHelper();

  ///初始化会话上下文
  CompletionDao({List<MessageModel>? messages}) {
    MessageModel? question, answer;
    messages?.forEach((model) {
      //sender为提问者，receiver为ChatGPT
      if (model.ownerType == OwnerType.sender) {
        question = model;
      } else {
        answer = model;
      }
      if (question != null && answer != null) {
        conversationContextHelper
            .add(ConversationModel(question!.content, answer!.content));
        question = answer = null;
      }
    });
    AILogger.log(
        'init finish,prompt is ${conversationContextHelper.getPromptContext("")}');
  }

  ///和ChatGPT进行会话
  Future<String?> createCompletions({required String prompt}) async {
    var fullPrompt = conversationContextHelper.getPromptContext(prompt);
    var response =
        await AICompletion().createChat(prompt: fullPrompt, maxTokens: 200);
    var choices = response.choices?.first;
    var content = choices?.message?.content;
    if (content != null) {
      var list = content.split('A:'); //过滤掉不想展示的字符
      content = list.length > 1 ? list[1] : content;
      content = content.replaceFirst("\n\n", ""); //过滤掉开始的换行
      conversationContextHelper.add(ConversationModel(prompt, content));
    }
    return content;
  }

  ///获取文心一言的access_token
  static Future<String> getWenXinToken() async {
    var response = await AIWenXinCompletion().getWenXinToken(
        clientId: 'dGS8uD4kJmTS0wE40Wfdo6Wm',
        clientSecret: 'TqINjvUSleNBmIxqWUrGlXf7sEAg8RoN');
    var accessToken = response.accessToken ?? '';
    PreferencesHelper.saveData(HiConst.accessToken, accessToken);
    return accessToken;
  }

  ///和文心一言进行会话
  Future<Map<String, dynamic>?> createWenXinCompletions(
      {required String accessToken, required String prompt}) async {
    var fullMessages = conversationContextHelper.getWenXinMessage(prompt);
    var response = await AIWenXinCompletion()
        .createWenXinChat(accessToken: accessToken, messages: fullMessages);
    var map = <String, dynamic>{};
    var content = response.result;
    if (content != null) {
      content = content.replaceFirst("\n\n", ""); //过滤掉开始的换行
      conversationContextHelper.add(ConversationModel(prompt, content));
      map = {'content': content};
    } else {
      var errorCode = response.errorCode;
      map = {'errorCode': errorCode};
    }
    return map;
  }

  ///和文心一言进行会话(流式)
  void createWenXinStream(
      {required String accessToken,
      required String prompt,
      required Function(String value) onSuccess,
      required Function? onError,
      required void Function() onDone}) async {
    var fullMessages = conversationContextHelper.getWenXinMessage(prompt);
    AILogger.log('wenxinfullMessages:$fullMessages');
    var url =
        'https://aip.baidubce.com/rpc/2.0/ai_custom/v1/wenxinworkshop/chat/completions?access_token=$accessToken';
    var headers = {'Content-Type': 'application/json'};
    var dict = {'messages': fullMessages, 'stream': true};
    var json = jsonEncode(dict);
    var request = http.Request('POST', Uri.parse(url))
      ..headers.addAll(headers)
      ..body = json; // 添加 JSON 请求体
    try {
      var streamedResponse = await request.send();
      streamedResponse.stream.transform(utf8.decoder).listen(
            onSuccess,
            onDone: onDone,
            onError: onError,
            cancelOnError: true, // 当发现错误时，取消监听
          );
    } catch (e) {
      AILogger.log('Caught error: $e');
    }
  }

  contextHelperAdd(String inputMessage, String streamContent) {
    conversationContextHelper
        .add(ConversationModel(inputMessage, streamContent));
  }

  ///和文心一言-文生图进行会话
  Future<Map<String, dynamic>?> createWenXinWSTCompletions(
      {required String accessToken, required String prompt}) async {
    var response = await AIWenXinCompletion()
        .createWenXinWST(accessToken: accessToken, prompt: prompt);
    var map = <String, dynamic>{};
    List<ImageData>? list = response.data;
    if (list != null) {
      if (list.isNotEmpty) {
        ImageData imgData = list[0];
        map = {'base64': imgData.b64Image};
      }
    } else {
      var errorCode = response.errorCode;
      map = {'errorCode': errorCode};
    }
    return map;
  }

  //  重置对话
  void resetChat() {
    conversationContextHelper.reset();
  }
}

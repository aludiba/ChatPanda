import 'package:chat_message/models/message_model.dart';
import 'package:chatgpt_flutter/util/conversation_context_helper.dart';
import 'package:chatgpt_flutter/util/hi_const.dart';
import 'package:chatgpt_flutter/util/preferences_helper.dart';
import 'package:openai_flutter/core/ai_completions.dart';
import 'package:openai_flutter/core/ai_wenxincompletions.dart';
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

  //  重置对话
  void resetChat() {
    conversationContextHelper.reset();
  }
}

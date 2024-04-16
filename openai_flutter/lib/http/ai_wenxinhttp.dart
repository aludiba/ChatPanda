import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:openai_flutter/utils/ai_logger.dart';

///HTTP请求工具类
class AIWenXinHttp {
  static Future<T> post<T>(
      {required String url,
      required T Function(Map<String, dynamic>) onSuccess,
      Map<String, dynamic>? body}) async {
    AILogger.log('starting request to $url');

    ///借助HttpClient来发送请求
    HttpClient httpClient = HttpClient();

    IOClient myClient = IOClient(httpClient);
    final http.Response response = await myClient.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body != null ? jsonEncode(body) : null);
    AILogger.log(
        'request to $url finished with status code ${response.statusCode}');
    AILogger.log('starting decoding response body');

    ///防止乱码
    Utf8Decoder utf8decoder = const Utf8Decoder();
    final Map<String, dynamic> decodedBody =
        jsonDecode(utf8decoder.convert(response.bodyBytes))
            as Map<String, dynamic>;
    AILogger.log('response body decoded successfully');
    if (decodedBody['error'] != null) {
      AILogger.log('an error occurred, throwing exception');
      throw 'RequestFailedException{message: ${decodedBody['error_description']}, statusCode: ${decodedBody['error']}}';
    } else {
      AILogger.log('request finished successfully');
      return onSuccess(decodedBody);
    }
  }
}

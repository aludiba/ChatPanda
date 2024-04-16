import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_network/data_model.dart';
import 'package:http/http.dart' as http;

class HttpICan extends StatefulWidget {
  const HttpICan({super.key});

  @override
  State<HttpICan> createState() => _HttpICanState();
}

class _HttpICanState extends State<HttpICan> {
  var resultShow = '';
  var resultShow2 = '';
  var resultShow3 = '';

  get _goGetBtn =>
      ElevatedButton(onPressed: _doGet, child: const Text('发送Get请求'));

  get _goPostBtn =>
      ElevatedButton(onPressed: _doPost, child: const Text('发送Post请求'));

  get _goPostJsonBtn => ElevatedButton(
      onPressed: _doPostJson, child: const Text('发送Json数据的Post请求'));

  get _clearJsonBtn =>
      ElevatedButton(onPressed: _doClear, child: const Text('清空请求结果'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('带你玩转Flutter http网络操作'),
      ),
      body: Column(
        children: [
          _goGetBtn,
          _goPostBtn,
          _goPostJsonBtn,
          _clearJsonBtn,
          Text('返回的结果：$resultShow'),
          Text('解析数据msg：$resultShow2'),
          Text('通过Model解析数据：$resultShow3')
        ],
      ),
    );
  }

  void _doGet() async {
    var uri =
        Uri.parse('https://api.devio.org/uapi/test/test?requestPrams=ChatGPT');
    var response = await http.get(uri);
    // http请求成功
    if (response.statusCode == 200) {
      setState(() {
        resultShow = response.body;
      });
    } else {
      setState(() {
        resultShow = '请求失败:code:${response.statusCode}, body:${response.body}';
      });
    }
  }

  void _doPost() async {
    var uri = Uri.parse('https://api.devio.org/uapi/test/test');
    var params = {'requestPrams': 'doPost : ChatGPT'};
    var response = await http.post(uri, body: params);
    // http请求成功
    if (response.statusCode == 200) {
      setState(() {
        resultShow = response.body;
      });
    } else {
      setState(() {
        resultShow = '请求失败:code:${response.statusCode}, body:${response.body}';
      });
    }
  }

  void _doPostJson() async {
    var uri = Uri.parse('https://api.devio.org/uapi/test/testJson');
    var params = {'name': 'ChatGPT'};
    var response = await http.post(uri,
        body: jsonEncode(params),
        headers: {'content-type': 'application/json'});
    // http请求成功
    if (response.statusCode == 200) {
      setState(() {
        resultShow = response.body;
      });
      var map = jsonDecode(response.body);
      var dataModel = DataModel.fromJson(map);
      // var dataModel = DataModel1.fromJson(map);
      setState(() {
        resultShow2 = map['msg'];
        resultShow3 = dataModel.data?.jsonParams?.name ?? '';
      });
    } else {
      setState(() {
        resultShow = '请求失败:code:${response.statusCode}, body:${response.body}';
      });
    }
  }

  void _doClear() {
    setState(() {
      resultShow = '';
      resultShow2 = '';
      resultShow3 = '';
    });
  }
}

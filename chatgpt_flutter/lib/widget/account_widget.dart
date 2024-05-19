import 'package:chatgpt_flutter/provider/theme_provider.dart';
import 'package:chatgpt_flutter/util/hi_const.dart';
import 'package:chatgpt_flutter/util/padding_extension.dart';
import 'package:chatgpt_flutter/util/preferences_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openai_flutter/utils/ai_logger.dart';
import 'package:provider/provider.dart';

class AccountWidget extends StatefulWidget {
  const AccountWidget({super.key});

  @override
  State<AccountWidget> createState() => _AccountWidgetState();
}

class _AccountWidgetState extends State<AccountWidget> {
  get _themeColor => context.watch<ThemeProvider>().themeColor;

  @override
  void initState() {
    super.initState();
    _loadAccount();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _themeColor,
      child: Column(
        children: [
          60.paddingHeight,
          _accountCard(),
          35.paddingHeight,
          _subscribeCard(),
          30.paddingHeight
        ],
      ),
    );
  }

  ///账户信息展示
  ///账户信息展示
  _accountCard() {
    return FutureBuilder<String>(
      future: _loadAccount(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          return Column(
            children: [
              const Icon(Icons.account_circle, size: 46, color: Colors.white),
              8.paddingHeight,
              Text(snapshot.data!,
                  style: const TextStyle(fontSize: 18, color: Colors.white))
            ],
          );
        } else {
          return const Text('No data');
        }
      },
    );
  }

  ///账户信息展示
  _subscribeCard() {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10),
      padding: const EdgeInsets.only(left: 4, right: 4),
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: const BorderRadius.all(Radius.circular(6)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // 设置主轴对齐方式
        children: [
          Icon(Icons.cloud, color: _themeColor),
          Container(
            height: 30,
            decoration: BoxDecoration(
              color: _themeColor,
              borderRadius: const BorderRadius.all(Radius.circular(4)),
            ),
            child: InkWell(
              onTap: () {
                //TODO:跳转订阅页面
                AILogger.log('跳转订阅页面~~~');
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 4, right: 4),
                child: Center(
                  // 使用 Center 使文本在容器中居中
                  child: Text(
                    AppLocalizations.of(context)!.subscribe,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  ///账户信息
  Future<String> _loadAccount() async {
    String accountStr =
        await PreferencesHelper.loadData(HiConst.iCloudUserID) ?? '';
    if (accountStr.isEmpty) {
      accountStr = 'test';
    }
    return 'ID: $accountStr';
  }
}

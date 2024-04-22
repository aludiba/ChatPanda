import 'package:chatgpt_flutter/dao/hi_api_cache.dart';
import 'package:chatgpt_flutter/pages/bottom_navigator.dart';
import 'package:chatgpt_flutter/provider/hi_provider.dart';
import 'package:chatgpt_flutter/provider/theme_provider.dart';
import 'package:chatgpt_flutter/util/custom_Notification.dart';
import 'package:chatgpt_flutter/util/hi_const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hi_cache/flutter_hi_cache.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_splash_screen/flutter_splash_screen.dart';
import 'package:openai_flutter/http/ai_config.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Widget get _loadingPage => const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: doInit(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        Widget widget;
        if (snapshot.connectionState == ConnectionState.done) {
          widget = const BottomNavigator();
        } else {
          return _loadingPage;
        }
        return MultiProvider(
          providers: mainProviders,
          child: Consumer<ThemeProvider>(builder: (BuildContext context,
              ThemeProvider themeProvider, Widget? child) {
            return ChangeNotifierProvider(
              create: (context) => AIToolSharedData(),
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                home: widget,
                theme: themeProvider.getTheme(),
                title: 'ChatGPT',
                localizationsDelegates: const [
                  AppLocalizations.delegate, // Add this line
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate
                ],
                supportedLocales: const [
                  Locale('zh'), // 简体中文
                  Locale('en'), // English
                ],
              ),
            );
          }),
        );
      },
    );
  }

  Future<void> doInit() async {
    hideScreen();
    await HiCache.preInit();
    HiAPICache.init(HiCache.getInstance());
    //获取之前设置过的open ai apikey
    String? cacheKey = HiCache.getInstance().get(HiConst.keyOpenAi);
    AIConfigBuilder.init(cacheKey ?? '');
  }

  ///hide your splash screen
  Future<void> hideScreen() async {
    Future.delayed(const Duration(milliseconds: 1800), () {
      FlutterSplashScreen.hide();
    });
  }
}

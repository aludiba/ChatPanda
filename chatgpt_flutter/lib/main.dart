import 'package:chatgpt_flutter/pages/bottom_navigator.dart';
import 'package:chatgpt_flutter/provider/hi_provider.dart';
import 'package:chatgpt_flutter/provider/theme_provider.dart';
import 'package:chatgpt_flutter/util/custom_Notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_pangle_ads/flutter_pangle_ads.dart';
import 'package:flutter_splash_screen/flutter_splash_screen.dart';
import 'package:provider/provider.dart';

//初始化穿山甲SDK
_initPangleAds() {
  Future<bool> result = FlutterPangleAds.requestIDFA;
  FlutterPangleAds.initAd('5543205');
}

//初始化GromoreAds
// _initGromoreAds() {
//   Future<bool> result = FlutterGromoreAds.requestIDFA;
//   FlutterGromoreAds.initAd('5543205');
// }

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _initPangleAds();
  // _initGromoreAds();
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
    return MultiProvider(
      providers: mainProviders,
      child: Consumer<ThemeProvider>(builder:
          (BuildContext context, ThemeProvider themeProvider, Widget? child) {
        return ChangeNotifierProvider(
          create: (context) => AIToolSharedData(),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: const BottomNavigator(),
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
  }

  ///hide your splash screen
  Future<void> _hideScreen() async {
    Future.delayed(const Duration(milliseconds: 1800), () {
      FlutterSplashScreen.hide();
    });
  }
}

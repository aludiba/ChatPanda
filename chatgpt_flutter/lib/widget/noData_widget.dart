import 'package:chatgpt_flutter/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class NoDataWidget extends StatefulWidget {
  /// 显示图标
  final IconData? hostIcon;

  /// 提示信息
  final String? tip;

  /// 点击回调事件
  final GestureTapCallback? hostTap;

  const NoDataWidget({super.key, this.hostIcon, this.tip, this.hostTap});

  @override
  State<NoDataWidget> createState() => _NoDataWidgetState();
}

class _NoDataWidgetState extends State<NoDataWidget> {
  get _themeColor => context.watch<ThemeProvider>().themeColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.hostTap,
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.hostIcon ?? Icons.hourglass_empty,
            color: _themeColor,
          ),
          Text(widget.tip ?? AppLocalizations.of(context)!.noData,
              style: TextStyle(fontSize: 18, color: _themeColor))
        ],
      )),
    );
  }
}

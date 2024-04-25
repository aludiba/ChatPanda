import 'package:chatgpt_flutter/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

///聊天输入框
class MessageInputWidget extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSend;
  final String hint;
  final bool enable;

  const MessageInputWidget(
      {super.key,
      this.onChanged,
      this.onSend,
      required this.hint,
      this.enable = true});

  @override
  State<MessageInputWidget> createState() => _MessageInputWidgetState();
}

class _MessageInputWidgetState extends State<MessageInputWidget> {
  bool _showSend = false;
  final _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  get _input => Expanded(
          child: TextField(
        focusNode: _focusNode,
        onChanged: _onChanged,
        controller: _controller,
        //回车发送消息
        onSubmitted: (_) {
          _onSend();
        },
        style: const TextStyle(
            fontSize: 18, color: Colors.black, fontWeight: FontWeight.w400),
        decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide:
                    const BorderSide(width: 0, style: BorderStyle.none)),
            filled: true,
            //输入框样式的大小约束
            constraints: const BoxConstraints(maxHeight: 39),
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.only(left: 10),
            hintStyle: const TextStyle(fontSize: 16),
            hintText: widget.hint),
      ));

  get _sendBtn => (color) => Container(
        margin: const EdgeInsets.only(left: 10),
        width: 65,
        child: MaterialButton(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          height: 35,
          disabledColor: color.withOpacity(0.6),
          color: color,
          onPressed: widget.enable ? _onSend : null,
          child: Text(
            AppLocalizations.of(context)!.send,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    var themeProvider = context.watch<ThemeProvider>();
    var color = themeProvider.themeColor;
    var bottom = MediaQuery.of(context).padding.bottom;
    if (bottom == 0.0) {
      //适配iOS刘海屏以外的设备
      bottom = 20;
    }
    return Container(
      height: 50 + bottom,
      padding: EdgeInsets.only(left: 20, right: 20, top: 5, bottom: bottom),
      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2)),
      child: Row(
        children: [_input, if (_showSend) _sendBtn(color)],
      ),
    );
  }

  void _onChanged(String value) {
    if (widget.onChanged != null) widget.onChanged!(value);
    setState(() {
      _showSend = value.isNotEmpty;
    });
  }

  void _onSend() {
    if (widget.onSend != null) {
      _focusNode.unfocus();
      widget.onSend!();
      _controller.clear();
      setState(() {
        _showSend = false;
      });
    }
  }
}

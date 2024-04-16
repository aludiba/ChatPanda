import 'package:chatgpt_flutter/model/helpTip_model.dart';
import 'package:chatgpt_flutter/widget/helpTip_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HelpPage extends StatefulWidget {
  final List<HelpTipModel> tipsList;

  const HelpPage({super.key, required this.tipsList});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  get _dateCount => widget.tipsList.length;

  get _listView => ListView.builder(
      itemCount: _dateCount,
      itemBuilder: (BuildContext context, int index) =>
          _conversationWidget(index));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.help),
          centerTitle: true,
        ),
        body: _listView);
  }

  _conversationWidget(int index) {
    HelpTipModel model = widget.tipsList[index];
    return HelpTipWidget(model: model);
  }
}

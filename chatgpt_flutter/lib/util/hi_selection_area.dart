import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

class HiSelectionAreaWidget extends StatefulWidget {
  final bool? selectAll;
  final bool? copy;
  final bool? transpond;
  final Text child;
  // 定义焦点节点
  final FocusNode? focusNode;

  late List<ContextMenuButtonItem> buttonItems;

  HiSelectionAreaWidget(
      {super.key,
      this.selectAll,
      this.copy,
      this.transpond,
      this.focusNode,
      required this.child});

  @override
  State<HiSelectionAreaWidget> createState() => _HiSelectionAreaWidgetState();
}

class _HiSelectionAreaWidgetState extends State<HiSelectionAreaWidget> {
  @override
  Widget build(BuildContext context) {
    //获取选择的文本
    var selectedText = '';
    return SelectionArea(
      focusNode: widget.focusNode,
      onSelectionChanged: (SelectedContent? selectContent) =>
          selectedText = selectContent?.plainText ?? "",
      contextMenuBuilder: (
        BuildContext context,
        SelectableRegionState selectableRegionState,
      ) {
        bool selectAllEnable = false;
        //若还有可选的内则展示全选菜单
        if (selectedText.length < (widget.child.data?.length ?? 0)) {
          selectAllEnable = true;
        }
        widget.buttonItems = [
          if (widget.selectAll != null)
            if (widget.selectAll! && selectAllEnable)
              ContextMenuButtonItem(
                  label: AppLocalizations.of(context)!.selectAll,
                  onPressed: () {
                    selectableRegionState
                        .selectAll(SelectionChangedCause.toolbar);
                  }),
          if (widget.copy != null)
            if (widget.copy!)
              ContextMenuButtonItem(
                  label: AppLocalizations.of(context)!.copy,
                  onPressed: () {
                    selectableRegionState
                        .copySelection(SelectionChangedCause.toolbar);
                  }),
          if (widget.transpond != null)
            if (widget.transpond!)
              ContextMenuButtonItem(
                  label: AppLocalizations.of(context)!.transpond,
                  onPressed: () {
                    /// 转发(分享)
                    Share.share(selectedText);
                  }),
        ];
        return AdaptiveTextSelectionToolbar.buttonItems(
            buttonItems: widget.buttonItems,
            anchors: selectableRegionState.contextMenuAnchors);
      },
      child: widget.child,
    );
  }
}

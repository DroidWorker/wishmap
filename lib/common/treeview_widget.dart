import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:wishmap/res/colors.dart';

import '../data/models.dart';

class MyTreeView extends StatefulWidget {
  final List<MyTreeNode> roots;
  final bool applyColorChangibg;
  bool fillWidth = false;
  final bool alignRight;
  final Function(int id, String type) onTap;
  final Function(int id, String type)? onDoubleTap;

  MyTreeView(
      {super.key,
      required this.roots,
      required this.onTap,
      this.onDoubleTap,
      this.applyColorChangibg = true,
      this.fillWidth = false,
      this.alignRight = false});

  @override
  State<MyTreeView> createState() => MyTreeViewState();
}

class MyTreeViewState extends State<MyTreeView> {
  late final TreeController<MyTreeNode> treeController;
  int countHidden = 0;

  ScrollController scontroller = ScrollController();

  List<TreeEntry<MyTreeNode>> treeEntries = [];
  List<ValueNotifier<double>> paddingNotifiers = [];

  @override
  void initState() {
    super.initState();
    treeController = TreeController<MyTreeNode>(
      roots: widget.roots,
      childrenProvider: (MyTreeNode node) => node.children,
    );
    treeController.expandAll();
    if (widget.roots.isNotEmpty) {
      for (var root in widget.roots) {
        buildEntries(root, null, 1);
      }
    }
    paddingNotifiers = List.generate(
      treeEntries.length,
      (index) => ValueNotifier<double>(
          8.0), // Инициализация с начальным значением отступа
    );
  }

  @override
  void dispose() {
    // Remember to dispose your tree controller to release resources.
    treeController.dispose();
    for (var notifier in paddingNotifiers) {
      notifier.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //debugPaintSizeEnabled = true;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: !widget.fillWidth
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: buildTree(),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: buildTree(),
            ),
    );
  }

  void buildEntries(
      MyTreeNode node, TreeEntry<MyTreeNode>? parentEntry, int level) {
    final root = node.children;
    int i = 0;
    if (parentEntry == null) {
      treeEntries.add(TreeEntry(
          parent: parentEntry,
          node: node,
          index: 0,
          level: 0,
          isExpanded: true,
          hasChildren: node.children.isNotEmpty));
      parentEntry = treeEntries.first;
    }
    for (var element in root) {
      final newIndex = treeEntries.lastOrNull?.index ?? -1;
      treeEntries.add(TreeEntry(
          parent: parentEntry,
          node: element,
          index: newIndex + 1,
          level: level,
          isExpanded: true,
          hasChildren: element.children.isNotEmpty,
          hasNextSibling: i != root.length - 1));
      i++;
      if (element.children.isNotEmpty)
        buildEntries(element, treeEntries.last, level + 1);
    }
  }

  List<Widget> buildTree() {
    List<Widget> items = [];
    List<String> path = [];
    int curLvl = -1;
    for (int i = 0; i < treeEntries.length; i++) {
      items.add(
        ValueListenableBuilder<double>(
          valueListenable: paddingNotifiers[i],
          builder: (context, padding, _) {
            String curPath = treeEntries[i].level != 0 ? path.join(">") : "";
            curLvl = treeEntries[i].level;
            if (treeEntries.length > i + 1) {
              if (curLvl < treeEntries[i + 1].level && curLvl != 0) {
                path.add(treeEntries[i].node.title);
              } else if (treeEntries[i + 1].level < curLvl) {
                final diff = curLvl - treeEntries[i + 1].level;
                for (var i = 0; i < diff; i++) {
                  path.removeLast();
                }
              } else if (curLvl < 1) {
                path = [treeEntries[i].node.title];
              }
            }
            return MyTreeTile(
              p: curPath,
              padding: padding,
              controller: scontroller,
              fillWidth: widget.fillWidth,
              entry: treeEntries[i],
              applyColorChanging: widget.applyColorChangibg,
              onTap: () {
                widget.onTap(treeEntries[i].node.id, treeEntries[i].node.type);
              },
              onDoubleTap: widget.onDoubleTap == null
                  ? null
                  : () {
                      widget.onDoubleTap!(
                          treeEntries[i].node.id, treeEntries[i].node.type);
                    },
            );
          },
        ),
      );
    }
    return items;
  }

  void changePadding(int countHid) {
    if (countHid < countHidden) {
      paddingNotifiers[countHidden].value = 8;
    }
    countHidden = countHid;
    for (int i = 0; i < countHidden; i++) {
      // Изменяем значение отступа только для необходимых элементов
      paddingNotifiers[i].value = 0;
    }
  }
}

class MyTreeTile extends StatelessWidget {
  const MyTreeTile(
      {Key? key,
      required this.p,
      required this.controller,
      required this.padding,
      required this.fillWidth,
      required this.applyColorChanging,
      required this.entry,
      required this.onTap,
      this.onDoubleTap})
      : super(key: key);

  final String p;
  final bool applyColorChanging;
  final ScrollController controller;
  final bool fillWidth;
  final double padding;
  final TreeEntry<MyTreeNode> entry;
  final VoidCallback onTap;
  final VoidCallback? onDoubleTap;

  @override
  Widget build(BuildContext context) {
    final path = p.replaceAll("HEADERSIMPLETASKHEADER", "");
    return InkWell(
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        child: TreeIndentation(
                  entry: entry,
                  guide: const IndentGuide.connectingLines(
          indent: 20,
          thickness: 1.0,
          origin: 1.0,
          color: AppColors.linesColor),
                  child: AnimatedPadding(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.fromLTRB(
            entry.node.id == 0
                ? 0
                : entry.node.type == 's'
                    ? 0
                    : 10,
            padding,
            4,
            0),
        curve: Curves.easeInOut, // Кривая анимации
        child: entry.node.id == 0 && entry.node.type == 'm'
            ? Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: AppColors.gradientEnd),
              )
            : (entry.node.type=='w'||entry.node.type=='s')&&entry.node.title.contains("HEADERSIMPLETASKHEADER")?
        Image.asset("assets/icons/service_wish.png", height: 22, width: 22): entry.node.type == 's'
                ? Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: AppColors.buttonBackRed)),
                    child: Center(
                        child: Text(entry.node.title,
                            maxLines: 2,
                            style: const TextStyle(fontSize: 10))),
                  )
                : Container(
                    height: fillWidth ? 50 : 25,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(6))),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 8),
                        fillWidth
                            ? Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    path.isNotEmpty
                                        ? SingleChildScrollView(
                                            scrollDirection:
                                                Axis.horizontal,
                                            reverse: true,
                                            child: Text(path,
                                                maxLines: 1,
                                                style: const TextStyle(
                                                    color: AppColors
                                                        .textLightGrey)))
                                        : const Text("Желание",
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight:
                                                    FontWeight.w500)),
                                    Text(
                                      entry.node.title,
                                      maxLines: 1,
                                      style: entry.node.noClickable
                                          ? const TextStyle()
                                          : const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    entry.node.title.replaceAll(
                                        "HEADERSIMPLETASKHEADER", ""),
                                    maxLines: 1,
                                    style: entry.node.noClickable
                                        ? const TextStyle()
                                        : const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                        if (fillWidth) const SizedBox(width: 8),
                        Container(
                          height: fillWidth ? 38.0 : null,
                          width: fillWidth ? 38.0 : null,
                          decoration: fillWidth
                              ? BoxDecoration(
                                  color: AppColors
                                      .lightGrey, // Серый цвет фона
                                  borderRadius: BorderRadius.circular(
                                      10), // Закругленные края
                                )
                              : null,
                          child: Center(
                            child: entry.node.type == "w"
                                ? (entry.node.isHidden
                                    ? Image.asset(
                                        'assets/icons/wish_hidden.png',
                                        width: 30,
                                        height: 30,
                                      )
                                    : entry.node.isChecked
                                        ? Image.asset(
                                            'assets/icons/wish_done.png',
                                            width: 30,
                                            height: 30,
                                          )
                                        : !entry.node.isActive
                                            ? Image.asset(
                                                'assets/icons/wish_unactive.png',
                                                width: 30,
                                                height: 30)
                                            : Image.asset(
                                                'assets/icons/wish_active.png',
                                                width: 30,
                                                height: 30))
                                : (entry.node.type == "a"
                                    ? (entry.node.isChecked
                                        ? Image.asset(
                                            'assets/icons/target_done.png',
                                            width: 16,
                                            height: 16)
                                        : entry.node.isActive
                                            ? Image.asset(
                                                'assets/icons/target_active.png',
                                                width: 16,
                                                height: 16)
                                            : Image.asset(
                                                'assets/icons/target_unactive.png',
                                                width: 16,
                                                height: 16))
                                    : (entry.node.type == "t"
                                        ? (entry.node.isChecked
                                            ? Image.asset(
                                                'assets/icons/task_done.png',
                                                width: 16,
                                                height: 16)
                                            : entry.node.isActive
                                                ? Image.asset(
                                                    'assets/icons/task_active.png',
                                                    width: 16,
                                                    height: 16)
                                                : Image.asset(
                                                    'assets/icons/task_unactive.png',
                                                    width: 16,
                                                    height: 16))
                                        : Container())),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                  ),
                ));
  }
}

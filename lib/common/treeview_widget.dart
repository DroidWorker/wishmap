import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:wishmap/res/colors.dart';

import '../data/models.dart';
import 'customAutoSizeText.dart';

class MyTreeView extends StatefulWidget {
  final List<MyTreeNode> roots;
  final Map<String, List<int>>? spheres;
  List<Color> colors;
  final bool applyColorChangibg;
  bool fillWidth = false;
  final bool alignRight;
  int? currentId;
  final Function(int id, String type) onTap;
  final Function(int id, String type)? onDoubleTap;

  MyTreeView(
      {super.key,
      required this.roots,
      required this.onTap,
      this.currentId,
      this.spheres,
      this.onDoubleTap,
      this.applyColorChangibg = true,
      this.fillWidth = false,
      this.alignRight = false,
        this.colors =const [],});

  @override
  State<MyTreeView> createState() => MyTreeViewState();
}

class MyTreeViewState extends State<MyTreeView> {
  late final TreeController<MyTreeNode> treeController;
  int countHidden = 0;

  ScrollController scontroller = ScrollController();

  List<TreeEntry<MyTreeNode>> treeEntries = [];
  List<ValueNotifier<double>> paddingNotifiers = [];

  List<int> realLevel = [];

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

    var lvl = 0;
    if (level < 5) {
      lvl = level + 1;
      realLevel.add(level);
    } else {
      if (widget.fillWidth) {
        lvl = level;
        realLevel.add(realLevel.last++);
      } else {
        lvl = level + 1;
        realLevel.add(level);
      }
    }

    if (parentEntry == null) {
      treeEntries.add(TreeEntry(
          parent: parentEntry,
          node: node,
          index: 0,
          level: 0,
          isExpanded: true,
          hasChildren: node.children.isNotEmpty));
      parentEntry = treeEntries.last;
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
      if (element.children.isNotEmpty) {
        buildEntries(element, treeEntries.last, lvl);
      }
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
            String curPath = treeEntries[i].level != 0
                ? /*path.join(">")*/ /*path.last*/ treeEntries[i]
                        .parent
                        ?.node
                        .title ??
                    path.last
                : findKeyByValue(treeEntries[i].node.id);
            curLvl = treeEntries[i].level;
            try {
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
            } catch (ex) {
              print("TVW error $ex");
            }
            return MyTreeTile(
              p: curPath,
              padding: padding,
              controller: scontroller,
              fillWidth: widget.fillWidth,
              entry: treeEntries[i],
              selected: widget.currentId == treeEntries[i].node.id,
              applyColorChanging: widget.applyColorChangibg,
              colors: widget.colors,
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

  String findKeyByValue(int value) {
    if (widget.spheres == null) return "";
    for (var entry in widget.spheres!.entries) {
      if (entry.value.contains(value)) {
        return entry.key;
      }
    }
    return "";
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
      required this.selected,
      this.onDoubleTap,
      required this.colors})
      : super(key: key);

  final String p;
  final bool applyColorChanging;
  final bool selected;
  final ScrollController controller;
  final bool fillWidth;
  final double padding;
  final TreeEntry<MyTreeNode> entry;
  final VoidCallback onTap;
  final VoidCallback? onDoubleTap;
  final List<Color> colors;

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
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: colors.firstOrNull??Colors.grey)),
                    child: Center(
                        child: WordWrapWidget(
                            text: entry.node.title,
                            minTextSize: 4,
                            maxTextSize: 16,
                            style: const TextStyle(fontSize: 8))),
                  )
                : (entry.node.type == 'w' || entry.node.type == 's') &&
                        entry.node.title.contains("HEADERSIMPLETASKHEADER")
                    ? Image.asset("assets/icons/service_wish.png",
                        height: 22, width: 22)
                    : entry.node.type == 's'
                        ? Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border:
                                    Border.all(color: colors.length>1?colors.elementAt(1):Colors.grey)),
                            child: Center(
                                child: WordWrapWidget(
                                    text: entry.node.title,
                                    minTextSize: 4,
                                    maxTextSize: 16,
                                    style: const TextStyle(fontSize: 8))),
                          )
                        : Container(
                            height: fillWidth ? 50 : 25,
                            decoration: BoxDecoration(
                                color: selected && entry.node.noClickable ? null : Colors.white,
                                gradient: selected && entry.node.noClickable
                                    ? const LinearGradient(colors: [
                                        AppColors.gradientStart,
                                        AppColors.gradientEnd
                                      ])
                                    : null,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(6))),
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
                                                  ? const TextStyle(
                                                      color: Colors.white)
                                                  : const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            entry.node.title.replaceAll(
                                                "HEADERSIMPLETASKHEADER", ""),
                                            maxLines: 1,
                                            style: entry.node.noClickable
                                                ? const TextStyle(
                                                    color: Colors.white)
                                                : const TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                if (fillWidth) const SizedBox(width: 10),
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
                                                width: 16,
                                                height: 16,
                                              )
                                            : entry.node.isChecked
                                                ? Image.asset(
                                                    'assets/icons/wish_done.png',
                                                    width: 16,
                                                    height: 16,
                                                  )
                                                : !entry.node.isActive
                                                    ? Image.asset(
                                                        'assets/icons/wish_unactive.png',
                                                        width: 16,
                                                        height: 16)
                                                    : Image.asset(
                                                        'assets/icons/wish_active.png',
                                                        width: 16,
                                                        height: 16))
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

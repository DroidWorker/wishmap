import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

import '../data/models.dart';

class MyTreeView extends StatefulWidget {
  final List<MyTreeNode> roots;
  final bool applyColorChangibg;
  bool fillWidth = false;
  final Function(int id, String type) onTap;
  MyTreeView({super.key, required this.roots, required this.onTap, this.applyColorChangibg = true, this.fillWidth=false});

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
    if(widget.roots.isNotEmpty){
      for(var root in widget.roots) {
        buildEntries(root, null, 1);
      }
    }
    paddingNotifiers = List.generate(
      treeEntries.length,
          (index) => ValueNotifier<double>(8.0), // Инициализация с начальным значением отступа
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

    return SizedBox(
      width: MediaQuery.of(context).size.width ,
      child: !widget.fillWidth?SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: buildTree(),
        ),
      ): Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: buildTree(),
      ),
    );
  }

  void buildEntries(MyTreeNode node, TreeEntry<MyTreeNode>? parentEntry, int level){
    final root = node.children;
    int i = 0;
    if(parentEntry==null) {
      treeEntries.add(TreeEntry(parent: parentEntry, node: node, index: 0, level: 0, isExpanded: true, hasChildren: node.children.isNotEmpty));
      parentEntry=treeEntries.first;
    }
    for (var element in root) {
      final newIndex = treeEntries.lastOrNull?.index??-1;
      treeEntries.add(TreeEntry(parent: parentEntry, node: element, index: newIndex+1, level: level, isExpanded: true, hasChildren: element.children.isNotEmpty, hasNextSibling: i!=root.length-1));
      i++;
      if(element.children.isNotEmpty)buildEntries(element, treeEntries.last, level+1);
    }
  }

  List<Widget> buildTree() {
    List<Widget> items = [];
    for (int i = 0; i < treeEntries.length; i++) {
      items.add(
        ValueListenableBuilder<double>(
          valueListenable: paddingNotifiers[i],
          builder: (context, padding, _) {
            return MyTreeTile(
              padding: padding,
              controller: scontroller,
              fillWidth: widget.fillWidth,
              entry: treeEntries[i],
              applyColorChanging: widget.applyColorChangibg,
              onTap: () {
                widget.onTap(treeEntries[i].node.id, treeEntries[i].node.type);
              },
            );
          },
        ),
      );
    }
    return items;
  }

  void changePadding(int countHid) {
    if(countHid<countHidden){
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
  const MyTreeTile({
    Key? key,
    required this.controller,
    required this.padding,
    required this.fillWidth,
    required this.applyColorChanging,
    required this.entry,
    required this.onTap,
  }) : super(key: key);

  final bool applyColorChanging;
  final ScrollController controller;
  final bool fillWidth;
  final double padding;
  final TreeEntry<MyTreeNode> entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
                  child: Ink(
                    child: Row(
                      children: [
                        TreeIndentation(
                          entry: entry,
                          guide: const IndentGuide.connectingLines(indent: 20, roundCorners: true),
                          child: AnimatedPadding( // Используйте AnimatedPadding для анимации изменения отступа
                              duration: const Duration(milliseconds: 300), // Продолжительность анимации
                              padding: EdgeInsets.fromLTRB(0, padding, 4, padding),
                              curve: Curves.easeInOut, // Кривая анимации
                              child: SizedBox(
                                width: 110,
                                child: Text(
                                  entry.node.title,
                                  maxLines: 1,
                                  style: entry.node.noClickable
                                      ? const TextStyle()
                                      : applyColorChanging
                                      ? const TextStyle(decoration: TextDecoration.underline, color: Colors.black12)
                                      : const TextStyle(decoration: TextDecoration.underline),
                                ),
                              )
                          ),
                        ),
                        if(fillWidth)const Spacer(),
                        Center(
                          child: entry.node.type == "w"
                              ? (entry.node.isHidden
                              ? Image.asset('assets/icons/love5110868.png', width: 20, height: 20,)
                              : entry.node.isChecked
                              ? Image.asset('assets/icons/wish_done.png', width: 20, height: 20,)
                              : !entry.node.isActive
                              ? Image.asset('assets/icons/wish_unactive.png', width: 20, height: 20)
                              : Image.asset('assets/icons/wish_active.png', width: 20, height: 20))
                              : (entry.node.type == "a"
                              ? (entry.node.isChecked
                              ? Image.asset('assets/icons/target_done.png', width: 20, height: 20)
                              : entry.node.isActive
                              ? Image.asset('assets/icons/target_active.png', width: 20, height: 20)
                              : Image.asset('assets/icons/target_unactive.png', width: 20, height: 20))
                              : (entry.node.type == "t"
                              ? (entry.node.isChecked
                              ? Image.asset('assets/icons/task_done.png', width: 20, height: 20)
                              : entry.node.isActive
                              ? Image.asset('assets/icons/task_active.png', width: 20, height: 20)
                              : Image.asset('assets/icons/task_unactive.png', width: 20, height: 20))
                              : Container())),
                        )
                      ]
                    )
                  )
    );
  }

}
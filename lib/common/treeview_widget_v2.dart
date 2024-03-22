import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wishmap/res/colors.dart';

import '../data/models.dart';

class TreeViewWidgetV2 extends StatefulWidget {
  final MyTreeNode root;
  final Function(int id, String type) onTap;

  const TreeViewWidgetV2({super.key, required this.root, required this.onTap});

  @override
  _TreeViewWidgetState createState() => _TreeViewWidgetState();
}

class _TreeViewWidgetState extends State<TreeViewWidgetV2> {
  late MyTreeNode _currentNode;
  List<String> _currentPath = [];
  int currentLevel = 0;

  @override
  void initState() {
    super.initState();
    _currentNode = widget.root;
    _currentPath.add(widget.root.title);
  }

  void _onNodePressed( MyTreeNode root, List<String> path) {
    setState(() {
      _currentNode = root;
      _currentPath = path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: _buildPathRow(_currentPath))),
        const SizedBox(height: 8,),
        ..._buildNodes(_currentNode, _currentPath),
      ],
    );
  }

  List<Widget> _buildNodes(MyTreeNode node, List<String> path) {
    return node.children.map((child) {
      String type = child.type == 'm' ? "Я" :
        child.type == 's' ? "Сфера" :
        child.type == 'w' ? "Желание" :
        child.type == 'a' ? "Цель" :
        child.type == 't' ? "Задача" : "";
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                path.add(child.title);
                _onNodePressed(child, path);
              },
                onDoubleTap: (){
                  widget.onTap(child.id, child.type);
                },
              child: Container(
                margin: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10), // Примерно округлые края
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey, // Серый цвет фона
                        borderRadius: BorderRadius.circular(10), // Закругленные края
                      ),
                      padding: EdgeInsets.all(8), // Отступы внутри контейнера
                      child:  Image.asset('assets/icons/folder.png', width: 22, height: 22,),
                    ),
                    const SizedBox(width: 8,),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "${child.title}\n",
                            style: const TextStyle(color: Colors.black, fontSize: 18),
                          ),
                          TextSpan(
                            text: "$type",
                            style: const TextStyle(color: AppColors.textLightGrey, fontSize: 16), // Задайте нужный цвет
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    child.type == "w"
                        ? (child.isHidden
                        ? Image.asset('assets/icons/love5110868.png', width: 20, height: 20,)
                        : child.isChecked? Image.asset('assets/icons/wish_done.png', width: 20, height: 20,)
                        : !child.isActive? Image.asset('assets/icons/wish_unactive.png', width: 20, height: 20)
                        :Image.asset('assets/icons/wish_active.png', width: 20, height: 20))
                        : (child.type == "a"
                        ? (child.isChecked
                        ? Image.asset('assets/icons/target_done.png', width: 20, height: 30)
                        : child.isActive ? Image.asset('assets/icons/target_active.png', width: 20, height: 30)
                        : Image.asset('assets/icons/target_unactive.png', width: 20, height: 30))
                        : (child.type == "t"
                        ? (child.isChecked
                        ? Image.asset('assets/icons/task_done.png', width: 20, height: 30)
                        : child.isActive ? Image.asset('assets/icons/task_active.png', width: 20, height: 30)
                        : Image.asset('assets/icons/task_unactive.png', width: 20, height: 30))
                        : Container())),
                  ],
                ),
              )
            ),
          ],
        );
      }).toList();
  }

  List<Widget> _buildPathRow(List<String> items){
    List<Widget> widgets = [Image.asset('assets/icons/home.png', width: 18, height: 18,)];
    widgets.addAll(items.mapIndexed((i, e) {
      return GestureDetector(
        onTap: (){
          List<String> pathToCurrent = items.take(i + 1).toList();
          _onNodePressed(findNodeByTitle(widget.root, pathToCurrent.lastOrNull??"")??MyTreeNode(id: -1, type: "w", title: "title", isChecked: true), pathToCurrent);
        },
        child: Text("  ⟩  $e", style: const TextStyle(fontSize: 16),),
      );
    }));
    return widgets;
  }

  MyTreeNode? findNodeByTitle(MyTreeNode node, String title) {
    if (node.title == title) {
      return node;
    }

    for (var child in node.children) {
      var result = findNodeByTitle(child, title);
      if (result != null) {
        return result;
      }
    }

    return null;
  }
}
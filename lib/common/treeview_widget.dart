import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

import '../data/models.dart';

class MyTreeView extends StatefulWidget {
  final List<MyTreeNode> roots;
  final bool applyColorChangibg;
  final Function(int id, String type) onTap;
  const MyTreeView({super.key, required this.roots, required this.onTap, this.applyColorChangibg = true});

  @override
  State<MyTreeView> createState() => _MyTreeViewState();
}

class _MyTreeViewState extends State<MyTreeView> {
  // In this example a static nested tree is used, but your hierarchical data
  // can be composed and stored in many different ways.

  // This controller is responsible for both providing your hierarchical data
  // to tree views and also manipulate the states of your tree nodes.
  late final TreeController<MyTreeNode> treeController;

  @override
  void initState() {
    super.initState();
    treeController = TreeController<MyTreeNode>(
      // Provide the root nodes that will be used as a starting point when
      // traversing your hierarchical data.
      roots: widget.roots,
      // Provide a callback for the controller to get the children of a
      // given node when traversing your hierarchical data. Avoid doing
      // heavy computations in this method, it should behave like a getter.
      childrenProvider: (MyTreeNode node) => node.children,
    );
    treeController.expandAll();
  }

  @override
  void dispose() {
    // Remember to dispose your tree controller to release resources.
    treeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This package provides some different tree views to customize how 
    // your hierarchical data is incorporated into your app. In this example,
    // a TreeView is used which has no custom behaviors, if you wanted your
    // tree nodes to animate in and out when the parent node is expanded
    // and collapsed, the AnimatedTreeView could be used instead.
    //
    // The tree view widgets also have a Sliver variant to make it easy
    // to incorporate your hierarchical data in sophisticated scrolling
    // experiences.
    return TreeView<MyTreeNode>(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      // This controller is used by tree views to build a flat representation
      // of a tree structure so it can be lazy rendered by a SliverList.
      // It is also used to store and manipulate the different states of the
      // tree nodes.
      treeController: treeController,
      //physics: const BouncingScrollPhysics(),
      // Provide a widget builder callback to map your tree nodes into widgets.
      nodeBuilder: (BuildContext context, TreeEntry<MyTreeNode> entry) {
        // Provide a widget to display your tree nodes in the tree view.
        //
        // Can be any widget, just make sure to include a [TreeIndentation]
        // within its widget subtree to properly indent your tree nodes.
        return MyTreeTile(
          // Add a key to your tiles to avoid syncing descendant animations.
          key: ValueKey(entry.node),
          applyColorChanging: widget.applyColorChangibg,
          // Your tree nodes are wrapped in TreeEntry instances when traversing
          // the tree, these objects hold important details about its node
          // relative to the tree, like: expansion state, level, parent, etc.
          //
          // TreeEntrys are short lived, each time TreeController.rebuild is
          // called, a new TreeEntry is created for each node so its properties
          // are always up to date.
          entry: entry,
          // Add a callback to toggle the expansion state of this node.
          onTap: () {widget.onTap(entry.node.id, entry.node.type);},
        );
      },
    );
  }
}

class MyTreeTile extends StatelessWidget {
  const MyTreeTile({
    super.key,
    required this.applyColorChanging,
    required this.entry,
    required this.onTap,
  });

  final bool applyColorChanging;
  final TreeEntry<MyTreeNode> entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Ink(
        child: TreeIndentation(
          entry: entry,
          guide: const IndentGuide.connectingLines(indent: 25),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 8, 8, 8),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    entry.node.title,
                    maxLines: 5,
                    style: entry.node.noClickable
                        ? const TextStyle()
                        : applyColorChanging
                        ? const TextStyle(decoration: TextDecoration.underline, color: Colors.black12)
                        : const TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
                const Spacer(),
                entry.node.type == "w" && entry.node.id > 8
                    ? (entry.node.isChecked
                    ? Image.asset('assets/icons/love5110868fill.png', width: 20, height: 20,)
                    : Image.asset('assets/icons/love5110868.png', width: 20, height: 20))
                    : (entry.node.type == "a"
                    ? (entry.node.isChecked
                    ? Image.asset('assets/icons/target1914412.png', width: 20, height: 30)
                    : Image.asset('assets/icons/nountarget423422.png', width: 20, height: 30))
                    : (entry.node.type == "t"
                    ? (entry.node.isChecked
                    ? const Icon(Icons.check_circle_outline, size: 20)
                    : const Icon(Icons.circle_outlined, size: 20))
                    : Container())),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
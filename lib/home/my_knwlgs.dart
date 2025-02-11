import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/interface_widgets/colorButton.dart';
import 'package:wishmap/res/colors.dart';

import '../ViewModel.dart';
import '../navigation/navigation_block.dart';
import '../testModule/testingEngine/ViewModel.dart';

class MyKnwlgsScreen extends StatelessWidget {
  List<LevelData> knowleges = [];

  @override
  Widget build(BuildContext context) {
    final appViewModel = Provider.of<AppViewModel>(context);
    appViewModel.getKnowledges();
    return Consumer<TestViewModel>(builder: (context, viewModel, child) {
      knowleges = appViewModel.knowlegesData;
      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          style: const ButtonStyle(
                            tapTargetSize: MaterialTapTargetSize
                                .shrinkWrap, // the '2023' part
                          ),
                          icon: const Icon(Icons.keyboard_arrow_left,
                              size: 28, color: AppColors.gradientStart),
                          onPressed: () {
                            BlocProvider.of<NavigationBloc>(context)
                                .handleBackPress();
                          }),
                      const Text("Мои знания",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(width: 29)
                    ],
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: knowleges.map((it) {
                        return LevelItem(it.title, it.items);
                      }).toList(),
                    ))
              ],
            ),
          );
        })),
      );
    });
  }
}

class LevelItem extends StatefulWidget {
  final String title;
  final List<LevelItemData> data;

  LevelItem(this.title, this.data, {super.key});

  @override
  LevelItemState createState() => LevelItemState();
}

class LevelItemState extends State<LevelItem> {
  bool expanded = true;
  final levelTexts = {
    "БАЗОВЫЙ УРОВЕНЬ": Colors.green,
    "ПРОДВИНУТЫЙ": Colors.red,
    "НЕОПРЕДЕЛЕННЫЙ": Colors.yellow
  };

  @override
  Widget build(BuildContext context) {
    final levels = widget.data.map((e) {
      return e.level;
    }).toSet();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                expanded = !expanded;
              });
            },
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.darkGrey,
                )
              ],
            ),
          ),
          if (expanded) const Divider(),
          if (expanded)
            Column(
              children: [
                ...levels.map((e) {
                  return IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: const EdgeInsets.fromLTRB(4, 16, 4, 0),
                          padding: const EdgeInsets.all(4),
                          height: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: levelTexts.values.toList()[e].withOpacity(0.3),
                          ),
                          child: RotatedBox(
                            quarterTurns: -1,
                            child: Text(
                              levelTexts.keys.toList()[e],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: levelTexts.values.toList()[e],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Expanded(
                          // Use Expanded to keep the column in place
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                            child: Column(
                              children: widget.data
                                  .where((i) => i.level == e)
                                  .map<Widget>((e) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Subitem(e, () {}),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                })
              ],
            ),
        ],
      ),
    );
  }
}

Widget Subitem(LevelItemData data, Function() onClick) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        width: 1,
        color: Colors.grey.withOpacity(0.3),
      ),
    ),
    padding: const EdgeInsets.all(8),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              // Wrap text in Expanded to prevent overflow
              child: Text(
                data.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: data.status == "Пройден" ? Colors.green : Colors.red,
              ),
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
              child: Text(
                data.status,
                style: const TextStyle(
                    color: Colors.white, fontSize: 12),
              ),
            )
          ],
        ),
        const SizedBox(height: 10),
        Text(
          data.description,
          style: const TextStyle(fontSize: 13, height: 1),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            data.hint,
            style: const TextStyle(color: AppColors.greytextColor, fontSize: 14),
          ),
        ),
        ColorRoundedButton("Изучить", onClick, height: 36),
      ],
    ),
  );
}

class LevelData {
  final String title;
  final List<LevelItemData> items;

  LevelData(this.title, this.items);

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'items': items.map((it) {
        return it.toMap();
      }).toList(),
    };
  }

  factory LevelData.fromMap(Map<String, dynamic> map) {
    var items = (map['items'] as List)
        .map((item) =>
            LevelItemData.fromMap(Map<String, dynamic>.from(item as Map)))
        .toList();
    return LevelData(
      map['title'],
      items,
    );
  }
}

class LevelItemData {
  final int level;
  final String title;
  final String status;
  final String description;
  final String hint;

  LevelItemData(
      this.title, this.status, this.hint, this.level, this.description);

  Map<String, dynamic> toMap() {
    return {
      'level': level,
      'title': title,
      'status': status,
      'description': description,
      'hint': hint
    };
  }

  factory LevelItemData.fromMap(Map<String, dynamic> map) {
    return LevelItemData(map['title'], map['status'], map['hint'], map['level'],
        map['description']);
  }
}

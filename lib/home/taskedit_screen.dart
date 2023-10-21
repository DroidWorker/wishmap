import 'package:flutter/material.dart';
import 'package:wishmap/common/treeview_widget.dart';
import '../data/models.dart';
import '../res/colors.dart';

class TaskEditScreen extends StatelessWidget {

  TaskEditScreen({super.key});

  static const List<MyTreeNode> roots = <MyTreeNode>[
    MyTreeNode(
      title: 'Я',
      children: <MyTreeNode>[
        MyTreeNode(title: 'Вес 90', children: [MyTreeNode(title: "оплатить абонемент")]),
      ],
    )
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(child:Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Цель",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.greytextColor),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "Сохранить",
                            style: TextStyle(color: AppColors.blueTextColor),
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "Удалить",
                        style: TextStyle(color: AppColors.greytextColor),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "Достигнута",
                        style: TextStyle(color: AppColors.pinkTextColor),
                      ),
                    ),
                    Divider(
                      height: 3,
                      color: AppColors.dividerGreyColor,
                      indent: 5,
                      endIndent: 5,
                    ),
                  ],
                ),
                const Text("Вес 90 кг", style:  TextStyle(fontSize: 20),),
                const SizedBox(height: 15,),
                const Text("я хочу весить 90 кг? процент жира не более 5%", style:  TextStyle(fontSize: 16),),
                const SizedBox(height: 15,),
                Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      height: roots.length*100,
                      width: 400,
                      child: MyTreeView(roots: roots,),
                    )
                )
              ]
          ),
        ))
    );
  }
}

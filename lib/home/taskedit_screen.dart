import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/common/treeview_widget.dart';
import '../ViewModel.dart';
import '../data/models.dart';
import '../res/colors.dart';

class TaskEditScreen extends StatelessWidget {

  int aimId = 0;
  TaskEditScreen({super.key, required this.aimId});

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
    return Consumer<AppViewModel>(
        builder: (context, appVM, child) {
          TaskData ai = appVM.currentTask??TaskData(id: -1, text: 'объект не найден', description: "", isChecked: false);
          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: SafeArea(child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Expanded(
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
                              child: GestureDetector(
                                onTap: (){
                                  appVM.updateTask(ai);
                                },
                                child: const Text(
                                  "Сохранить",
                                  style: TextStyle(color: AppColors.blueTextColor),
                                ),
                              )
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: (){
                              appVM.deleteTask(ai.id);
                            },
                            child: const Text(
                              "Удалить",
                              style: TextStyle(color: AppColors.greytextColor),
                            ),
                          )
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: (){
                              appVM.updateTaskStatus(ai.id, true);
                            },
                            child: const Text(
                              "Достигнута",
                              style: TextStyle(color: AppColors.pinkTextColor),
                            ),
                          )
                        ),
                        const Divider(
                          height: 3,
                          color: AppColors.dividerGreyColor,
                          indent: 5,
                          endIndent: 5,
                        ),
                      ],
                    ),
                    Text(ai.text, style: const TextStyle(fontSize: 20),),
                    const SizedBox(height: 15,),
                    Text(ai.description,
                      style: const TextStyle(fontSize: 16),),
                    const SizedBox(height: 15,),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          height: roots.length * 100,
                          width: 400,
                          child: MyTreeView(roots: roots,),
                        )
                    )
                  ]
              ),
        ))
    );
  });
  }
}

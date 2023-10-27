import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/common/treeview_widget.dart';
import '../ViewModel.dart';
import '../data/models.dart';
import '../navigation/navigation_block.dart';
import '../res/colors.dart';

class AimEditScreen extends StatelessWidget {
  int aimId = 0;
  AimEditScreen({super.key,required this.aimId});

  static const List<MyTreeNode> roots = <MyTreeNode>[
    MyTreeNode(
      title: 'Я',
      children: <MyTreeNode>[
        MyTreeNode(title: 'Вес 90'),
      ],
    )
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppViewModel>(
        builder: (context, appVM, child) {
          AimData ai = appVM.currentAim??AimData(id: -1, text: 'объект не найден', description: "", isChecked: false);
          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: SafeArea(child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  appVM.updateAim(ai);
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
                              appVM.deleteAim(aimId);
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
                              appVM.updateAimStatus(aimId, true);
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
                    Text(ai.description, style: const TextStyle(fontSize: 16),),
                    const Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          height: 200,
                          width: 200,
                          child: MyTreeView(roots: roots,),
                        )
                    ),
                    const SizedBox(height: 30),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.fieldFillColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    10), // <-- Radius
                              ),
                            ),
                            onPressed: () {
                              BlocProvider.of<NavigationBloc>(context)
                                  .add(NavigateToTaskCreateScreenEvent(ai.id));
                            },
                            child: const Text("Создать задачу",
                              style: TextStyle(color: AppColors.greytextColor),)
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Укажи задачу дня для достижения цели. Помни! Задача актуальна 24 часа",
                          style: TextStyle(
                              fontSize: 10, color: AppColors.greytextColor),)
                      ],
                    ),
                  ]
              ),
            )
            ));
    });
  }
}

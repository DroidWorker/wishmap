import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wishmap/common/treeview_widget.dart';
import '../data/models.dart';
import '../navigation/navigation_block.dart';
import '../res/colors.dart';

class AimEditScreen extends StatelessWidget {

  AimEditScreen({super.key});

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
    return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(child:Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                const Text("я хочу весить 90 кг? процент жира не более 5%", style:  TextStyle(fontSize: 16),),
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
                  children:[
                ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.fieldFillColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // <-- Radius
                        ),
                      ),
                      onPressed: (){
                        BlocProvider.of<NavigationBloc>(context)
                            .add(NavigateToTaskCreateScreenEvent());
                      },
                      child: const Text("Создать задачу", style: TextStyle(color: AppColors.greytextColor),)
                  ),
                  const SizedBox(height: 5),
                  const Text("Укажи задачу дня для достижения цели. Помни! Задача актуальна 24 часа", style: TextStyle(fontSize: 10, color: AppColors.greytextColor),)
                ],
                ),
              ]
            ),
        )
    ));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../common/colorpicker_widget.dart';
import '../navigation/navigation_block.dart';
import '../res/colors.dart';

class WishScreen extends StatelessWidget {

  const WishScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(child:SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Row(children: [
                IconButton(
                  icon: const Icon(Icons.home_outlined),
                  iconSize: 30,
                  onPressed: () {
                    BlocProvider.of<NavigationBloc>(context)
                        .add(NavigateToMainScreenEvent());
                  },
                ),
                const Expanded(child: SizedBox(),),
                GestureDetector(
                  child: const Text("Cохранить  ", style: TextStyle(color: AppColors.pinkTextColor)),
                  onTap: (){},
                ),
                GestureDetector(
                  child: const Text("Удалить", style: TextStyle(color: AppColors.greytextColor),),
                  onTap: (){},
                )
              ],),
              Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    child: const Text("Исполнено"),
                    onTap: (){},
                  )
              ),
              const SizedBox(height: 5),
              TextField(
                style: const TextStyle(color: Colors.black), // Черный текст ввода
                decoration: InputDecoration(
                  border: InputBorder.none,
                  filled: true, // Заливка фона
                  fillColor: AppColors.fieldFillColor, // Серый фон с полупрозрачностью
                  hintText: 'Запиши желание', // Базовый текст
                  hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)), // Полупрозрачный черный базовый текст
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                minLines: 4,
                maxLines: 15,
                style: const TextStyle(color: Colors.black), // Черный текст ввода
                decoration: InputDecoration(
                  border: InputBorder.none,
                  filled: true, // Заливка фона
                  fillColor: AppColors.fieldFillColor, // Серый фон с полупрозрачностью
                  hintText: 'Опиши подробно свое желание', // Базовый текст
                  hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)), // Полупрозрачный черный базовый текст
                ),
              ),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, constraints) {
                  double leftWidth = (constraints.maxWidth * 4 /7)-2;
                  double rightWidth = constraints.maxWidth - leftWidth - 2;
                  return Row(
                    children: [
                      Container(width: leftWidth, height: leftWidth, color: AppColors.fieldFillColor),
                      const SizedBox(width: 2),
                      Column(children: [
                        Container(width: rightWidth, height: leftWidth/2-2, color: AppColors.fieldFillColor),
                        const SizedBox(height: 2),
                        Container(width: rightWidth, height: leftWidth/2-1, color: AppColors.fieldFillColor),
                      ],)
                    ],
                  );
                },
              ),
              const SizedBox(height: 5),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.fieldFillColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // <-- Radius
                    ),
                  ),
                  onPressed: (){},
                  child: const Text("Добавить", style: TextStyle(color: AppColors.greytextColor),)
              ),
              const SizedBox(height: 10),
              TextField(
                style: const TextStyle(color: Colors.black), // Черный текст ввода
                decoration: InputDecoration(
                  border: InputBorder.none,
                  filled: true, // Заливка фона
                  fillColor: AppColors.fieldFillColor, // Серый фон с полупрозрачностью
                  hintText: 'Напиши аффирмацию', // Базовый текст
                  hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)), // Полупрозрачный черный базовый текст
                ),
              ),
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.centerLeft,
                child:
                Text("Выберите аффирмацию или напишите свою", style: TextStyle(fontSize: 10, color: Colors.black54),),
              ),
              const SizedBox(height: 10),
              Align(
                  alignment: Alignment.centerLeft,
                  child:
                  GestureDetector(child:
                  Column(children: [
                    const Text("Выбери цвет", style: TextStyle(color: Colors.black54, decoration: TextDecoration.underline),),
                    const SizedBox(height: 10),
                    Container(
                      width: 100.0, // Ширина круга
                      height: 100.0, // Высота круга
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle, // Задаем форму круга
                        color: Colors.pink, // Устанавливаем цвет
                      ),
                    )
                  ],),
                    onTap: (){
                      showDialog(
                        context: context,
                        builder: (context) {
                          return const AlertDialog(
                            content: ColorPickerWidget(),
                          );
                        },
                      );
                    },
                  )),
              Align(
                alignment: Alignment.centerLeft,
                child: Column(children: [
                  const Text("Цели и задачи", style: TextStyle(color: Colors.black54, decoration: TextDecoration.underline),),
                  const SizedBox(height: 5),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.fieldFillColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // <-- Radius
                        ),
                      ),
                      onPressed: (){
                        BlocProvider.of<NavigationBloc>(context)
                            .add(NavigateToAimCreateScreenEvent());
                      },
                      child: const Text("Добавить", style: TextStyle(color: AppColors.greytextColor))
                  )
                ],),
              )
            ],
          ),),
      ))
    );
  }
}

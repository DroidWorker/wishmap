import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/navigation/navigation_block.dart';

import '../ViewModel.dart';
import '../common/colorpicker_widget.dart';
import '../data/models.dart';
import '../res/colors.dart';

class SpheresOfLifeScreen extends StatelessWidget {

  const SpheresOfLifeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appViewModel = Provider.of<AppViewModel>(context);
    CircleData curWd = appViewModel.mainScreenState?.allCircles[0]??CircleData(id: 0, text: "", color: Colors.red, parenId: -1);
    TextEditingController text = TextEditingController(text: curWd.text);
    TextEditingController description = TextEditingController(text: curWd.subText);
    TextEditingController affirmation = TextEditingController(text: curWd.affirmation);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(child:Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(children: [
              IconButton(
                icon: const Icon(Icons.menu),
                iconSize: 30,
                onPressed: () {
                  BlocProvider.of<NavigationBloc>(context)
                      .add(NavigateToMainScreenEvent());
                },
              ),
              const Expanded(child: SizedBox(),),
              GestureDetector(
                child: const Text("Cохранить  ", style: TextStyle(color: AppColors.blueTextColor),),
                onTap: () async {
                  await appViewModel.updateSphereWish(WishData(id: curWd.id, parentId: curWd.parenId, text: curWd.text, description: curWd.subText, affirmation: curWd.affirmation, color: curWd.color));
                  BlocProvider.of<NavigationBloc>(context)
                      .add(NavigateToMainScreenEvent());
                },
              ),
              GestureDetector(
                child: const Text("Удалить", style: TextStyle(color: AppColors.greytextColor)),
                onTap: (){},
              )
            ],),
            TextField(
              controller: text,
              style: const TextStyle(color: Colors.black), // Черный текст ввода
              decoration: InputDecoration(
                border: InputBorder.none,
                filled: true, // Заливка фона
                fillColor: AppColors.fieldFillColor, // Серый фон с полупрозрачностью
                hintText: 'Сфера жизни', // Базовый текст
                hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)), // Полупрозрачный черный базовый текст
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: description,
              minLines: 4,
              maxLines: 15,
              style: const TextStyle(color: Colors.black), // Черный текст ввода
              decoration: InputDecoration(
                border: InputBorder.none,
                filled: true, // Заливка фона
                fillColor: AppColors.fieldFillColor, // Серый фон с полупрозрачностью
                hintText: 'Опиши подробнее что значит для тебя эта сфера', // Базовый текст
                hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)), // Полупрозрачный черный базовый текст
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: affirmation,
              style: const TextStyle(color: Colors.black), // Черный текст ввода
              decoration: InputDecoration(
                border: InputBorder.none,
                filled: true, // Заливка фона
                fillColor: AppColors.fieldFillColor, // Серый фон с полупрозрачностью
                hintText: 'Аффирмация для этой сферы', // Базовый текст
                hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)), // Полупрозрачный черный базовый текст
              ),
            ),
            const SizedBox(height: 15),
            const Align(
              alignment: Alignment.centerLeft,
              child:
                Text("Выберите аффирмацию или напишите свою", style: TextStyle(fontSize: 10, color: Colors.black54),),
            ),
            const SizedBox(height: 15),
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
            ))
          ],
        ),),
    ));
  }
}

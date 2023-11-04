import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/navigation/navigation_block.dart';

import '../ViewModel.dart';
import '../common/colorpicker_widget.dart';
import '../data/models.dart';
import '../res/colors.dart';

class SpheresOfLifeScreen extends StatefulWidget {

  const SpheresOfLifeScreen({super.key});

  @override
  _SpheresOfLifeScreenState createState() => _SpheresOfLifeScreenState();
}

class _SpheresOfLifeScreenState extends State<SpheresOfLifeScreen>{
  String saveText = "Сохранить  ";
  CircleData curWd = CircleData(id: -1, text: "", color: Colors.red, parenId: -1);

  @override
  Widget build(BuildContext context) {
    final appViewModel = Provider.of<AppViewModel>(context);
    if(curWd.id==-1)curWd = appViewModel.mainScreenState?.allCircles[0]??CircleData(id: 0, text: "", color: Colors.red, parenId: -1);
    TextEditingController text = TextEditingController(text: curWd.text);
    TextEditingController description = TextEditingController(text: curWd.subText);
    TextEditingController affirmation = TextEditingController(text: curWd.affirmation);
    text.addListener(() { curWd.text=text.text;});
    description.addListener(() { curWd.subText=description.text;});
    affirmation.addListener(() { curWd.affirmation=affirmation.text;});

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
                      .add(NavigateToProfileScreenEvent());
                },
              ),
              const Expanded(child: SizedBox(),),
              GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(saveText, style: const TextStyle(color: AppColors.blueTextColor),),
                ),
                onTap: () async {
                  setState(() {
                    saveText = "Сохранение";
                  });
                  await appViewModel.updateSphereWish(WishData(id: curWd.id, parentId: curWd.parenId, text: curWd.text, description: curWd.subText, affirmation: curWd.affirmation, color: curWd.color));
                  if(appViewModel.mainScreenState!=null)appViewModel.startMainScreen(appViewModel.mainScreenState!.moon);
                  BlocProvider.of<NavigationBloc>(context)
                      .add(NavigateToMainScreenEvent());
                },
              ),
              GestureDetector(
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Text("Удалить", style: TextStyle(color: AppColors.greytextColor)),
                ),
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
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, // Задаем форму круга
                        color: curWd.color, // Устанавливаем цвет
                      ),
                    )
                  ],),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return ColorPickerWidget(onColorSelected: (Color c){setState(() {curWd.color=c;});});
                      },
                    );
                  },
            ))
          ],
        ),),
    ));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';
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
      body: SafeArea(maintainBottomViewPadding: true,
        child:Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(children: [
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_left),
                iconSize: 30,
                onPressed: () {
                  BlocProvider.of<NavigationBloc>(context)
                      .add(NavigateToMainScreenEvent());
                },
              ),
              const Expanded(child: SizedBox(),),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blueButtonBack,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          10), // <-- Radius
                    ),
                  ),
                  onPressed: () async {
                    await appViewModel.updateSphereWish(WishData(id: curWd.id, parentId: curWd.parenId, text: curWd.text, description: curWd.subText, affirmation: curWd.affirmation, color: curWd.color));
                    if(appViewModel.mainScreenState!=null)appViewModel.startMainScreen(appViewModel.mainScreenState!.moon);
                    showDialog(context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('сохранено'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'OK'),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text("Cохранить",
                    style: TextStyle(color: AppColors.greytextColor),)
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blueButtonBack,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          10), // <-- Radius
                    ),
                  ),
                  onPressed: () async {
                    await appViewModel.deleteSphereWish(curWd.id);
                    if(appViewModel.mainScreenState!=null)appViewModel.startMainScreen(appViewModel.mainScreenState!.moon);
                    showDialog(context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('удалено'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, 'OK');
                              if(appViewModel.mainScreenState!=null)appViewModel.startMainScreen(appViewModel.mainScreenState!.moon);
                              BlocProvider.of<NavigationBloc>(context).clearHistory();
                              BlocProvider.of<NavigationBloc>(context)
                                  .add(NavigateToMainScreenEvent());
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text("Удалить",
                    style: TextStyle(color: AppColors.greytextColor),)
              ),
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
            )),
            if(MediaQuery.of(context).viewInsets.bottom!=0) SizedBox(height: 30,
              child: FooterLayout(
                footer: Container(height: 30,color: Colors.white,alignment: Alignment.centerRight, child:
                GestureDetector(
                  onTap: (){FocusManager.instance.primaryFocus?.unfocus();},
                  child: const Text("готово", style: TextStyle(fontSize: 20),),
                )
                  ,),
              ),)
          ],
        ),),
    ));
  }
}

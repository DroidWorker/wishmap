import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/data/models.dart';

import '../ViewModel.dart';
import '../common/colorpicker_widget.dart';
import '../navigation/navigation_block.dart';
import '../res/colors.dart';

class WishScreen extends StatefulWidget {

  WishScreen({super.key});

  @override
  _WishScreenState createState() => _WishScreenState();
}

class _WishScreenState extends State<WishScreen>{
  Color circleColor = Colors.redAccent;

  late TextEditingController _title;
  late TextEditingController _description;
  late TextEditingController _affirmation;
  Color? _color;

  bool isDataLoaded = false;

  TaskItem? wishTasks;
  AimItem? wishAims;

  @override
  Widget build(BuildContext context) {
    final appViewModel = Provider.of<AppViewModel>(context);
    if(_color==null){
      _title = TextEditingController(text: "");
      _description = TextEditingController(text: "");
      _affirmation = TextEditingController(text: "");
      _color = Colors.black12;
    }
    String saveText = "Сохранить  ";

    return  Consumer<AppViewModel>(
        builder: (context, appVM, child){
          if(appVM.wishScreenState!=null&&!isDataLoaded) {
            _title.text = appVM.wishScreenState!.wish.text;
            _description.text = appVM.wishScreenState!.wish.description;
            _affirmation.text = appVM.wishScreenState!.wish.affirmation;
            _color = appVM.wishScreenState!.wish.color;
            isDataLoaded = true;
            appViewModel.getAimsForCircles(appVM.wishScreenState!.wish.id);
          }

          return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: SafeArea(child:SingleChildScrollView(
            child: Padding(
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
                        child: Text(saveText, style: const TextStyle(color: AppColors.pinkTextColor)),
                      ),
                      onTap: () async {
                        if(appVM.wishScreenState!=null){
                          setState(() {
                            saveText = "Сохранение  ";
                          });
                          appVM.wishScreenState!.wish
                            ..text=_title.text
                            ..description=_description.text
                            ..affirmation=_affirmation.text
                            ..color = _color!;
                          await appViewModel.createNewSphereWish(appVM.wishScreenState!.wish);
                          BlocProvider.of<NavigationBloc>(context).handleBackPress();
                        }
                      },
                    ),
                    GestureDetector(
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("Удалить", style: TextStyle(color: AppColors.greytextColor),),                      ),
                      onTap: (){
                        appViewModel.deleteSphereWish(appVM.wishScreenState!.wish.id);
                        BlocProvider.of<NavigationBloc>(context).handleBackPress();
                      },
                    )
                  ],),
                  Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        child: const Text("Исполнено"),
                        onTap: (){
                          appVM.wishScreenState!.wish.isChecked=true;
                          appViewModel.updateWishStatus(appVM.wishScreenState!.wish.id, true);
                        },
                      )
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    controller: _title,
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
                    controller: _description,
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
                    controller: _affirmation,
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
                          decoration: BoxDecoration(
                            shape: BoxShape.circle, // Задаем форму круга
                            color: _color, // Устанавливаем цвет
                          ),
                        )
                      ],),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return ColorPickerWidget(onColorSelected: (Color c){setState(() {_color=c; print("aaaaaaaaasss");});});
                            },
                          );
                        },
                      )),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(children: [
                      const Text("Цели и задачи", style: TextStyle(color: Colors.black54, decoration: TextDecoration.underline),),
                      const SizedBox(height: 5),
                      ...appVM.wishScreenState?.wishAims.asMap()
                          .entries
                          .map((entry) {
                        return GestureDetector(
                          onTap: () async {
                            await appViewModel.getAim(entry.value.id);
                            BlocProvider.of<NavigationBloc>(context)
                                .add(NavigateToAimEditScreenEvent(entry.value.id));
                          },
                          child: Row(
                            children: [
                              Text(entry.value.text),
                              const Expanded(child: SizedBox()),
                              IconButton(
                                icon: entry.value.isChecked?Image.asset('assets/icons/target1914412.png'):Image.asset('assets/icons/nountarget423422.png'),
                                iconSize: 18,
                                onPressed: () {
                                  setState(() {
                                    appViewModel.wishScreenState?.wishAims[entry.key].isChecked=!entry.value.isChecked;
                                    appViewModel.updateAimStatus(entry.value.id, !entry.value.isChecked);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList()??[],
                      ...appVM.wishScreenState?.wishTasks.asMap()
                          .entries
                          .map((entry) {
                        return GestureDetector(
                          onTap: () async {
                            await appViewModel.getTask(entry.value.id);
                            BlocProvider.of<NavigationBloc>(context)
                                .add(NavigateToTaskEditScreenEvent(entry.value.id));
                          },
                          child: Row(
                            children: [
                              Text(entry.value.text),
                              const Expanded(child: SizedBox()),
                              IconButton(
                                icon: entry.value.isChecked?const Icon(Icons.check_circle_outline):const Icon(Icons.circle_outlined),
                                iconSize: 18,
                                onPressed: () {
                                  setState(() {
                                    appViewModel.wishScreenState?.wishTasks[entry.key].isChecked=!entry.value.isChecked;
                                    appViewModel.updateTaskStatus(entry.value.id, !entry.value.isChecked);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList()??[],
                      const SizedBox(height: 5),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.fieldFillColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10), // <-- Radius
                            ),
                          ),
                          onPressed: (){
                            if(appVM.mainScreenState!.allCircles.where((element) => element.id==appVM.wishScreenState!.wish.id).isNotEmpty) {
                              BlocProvider.of<NavigationBloc>(context)
                                  .add(NavigateToAimCreateScreenEvent(
                                  appVM.wishScreenState!.wish.id));
                            }else{
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Необходимо сохранить желание'),
                                  duration: Duration(
                                      seconds: 3), // Установите желаемую продолжительность отображения
                                ),
                              );
                            }
                          },
                          child: const Text("Добавить", style: TextStyle(color: AppColors.greytextColor))
                      )
                    ],),
                  )
                ],
              ),),
          ))
    );});
  }
}

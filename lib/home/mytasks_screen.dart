import 'dart:math';

import 'package:capped_progress_indicator/capped_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../ViewModel.dart';
import '../common/custom_bottom_button.dart';
import '../common/taskitem_widget.dart';
import '../data/models.dart';
import '../data/static.dart';
import '../navigation/navigation_block.dart';
import '../res/colors.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State{
  List<TaskItem> taskList = [];
  List<TaskItem> filteredTaskList = [];
  late AppViewModel appViewModel;

  var isPBActive = false;

  int page = 0;//2 - не исполнено 1 - Исполнено 0 - Все желания

  @override
  Widget build(BuildContext context) {
    appViewModel = Provider.of<AppViewModel>(context);
    return Consumer<AppViewModel>(
        builder: (context, appVM, child) {
          taskList = appVM.taskItems;
          page==1?filteredTaskList = taskList.where((element) => element.isChecked).toList():
          page==2?filteredTaskList = taskList.where((element) => !element.isChecked).toList():
          page==3?filteredTaskList = taskList.where((element) => element.isActive).toList():filteredTaskList = taskList;
          isPBActive=appVM.isinLoading;
          return Scaffold(
              backgroundColor: AppColors.backgroundColor,
              body: SafeArea(child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: Column(
                  children: [
                    Row(children: [
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_left, size: 30,),
                        onPressed: () {
                          BlocProvider.of<NavigationBloc>(context)
                              .add(NavigateToMainScreenEvent());
                        },
                      ),
                      const Spacer(),
                      const Text("Мои задачи", style: TextStyle(fontSize: 18),),
                      const Spacer(),
                    ],
                    ),
                    const Text("за последние 24 часа"),
                    const SizedBox(height: 20),
                    Row(children: [
                      GestureDetector(
                        child: Container(
                          height: 30,
                          child: page==3
                              ? const Text("На сегодня",
                              style: TextStyle(decoration: TextDecoration.underline))
                              : const Text("На сегодня"),
                        ),
                        onTap: () {
                          setState(() {
                            page = 3;
                            filter(page);
                          });
                        },
                      ),
                      const SizedBox(width: 5),
                      GestureDetector(
                        child: Container(
                          height: 30,
                          child:page==2
                              ? const Text("не выполнены",
                              style: TextStyle(decoration: TextDecoration.underline))
                              : const Text("не выполнены"),
                        ),
                        onTap: () {
                          setState((){
                            page = 2;
                            filter(page);
                          });
                        },
                      ),
                      const SizedBox(width: 5),
                      GestureDetector(
                        child: Container(
                          height: 30,
                          child: page==1
                              ? const Text("Выполнены",
                              style: TextStyle(decoration: TextDecoration.underline))
                              : const Text("Выполнены"),
                        ),
                        onTap: () {
                          setState(() {
                            page = 1;
                            filter(page);
                          });
                        },
                      ),
                      const SizedBox(width: 5),
                      GestureDetector(
                        child: Container(
                          height: 30,
                          child: page==0
                              ? const Text("Все задачи",
                              style: TextStyle(decoration: TextDecoration.underline))
                              : const Text("Все задачи"),
                        ),
                        onTap: () {
                          setState(() {
                            page = 0;
                            filter(page);
                          });
                        },
                      ),
                    ],),
                    const SizedBox(height: 10,),
                    Expanded(child:
                    ListView.builder(
                        itemCount: filteredTaskList.length,
                        itemBuilder: (context, index) {
                          return TaskItemWidget(ti: filteredTaskList[index],
                              onSelect: onItemSelect,
                              onClick: onItemClick,
                              onDelete: onItemDelete);
                        }
                    ),),
                    const SizedBox(height: 10),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.fieldFillColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10), // <-- Radius
                          ),
                        ),
                        onPressed: () {
                          if(appViewModel.mainScreenState!=null)appViewModel.startMainScreen(appViewModel.mainScreenState!.moon);
                          appViewModel.hint="Добавление ЗАДАЧ происходит из цели, добавление цели из желания, а желания из сферы. Определяй сферу, создавай желания, ставь цели и выполняй задачи. Твои желания обязательно сбудутся";
                          BlocProvider.of<NavigationBloc>(context)
                              .add(NavigateToMainScreenEvent());
                        },
                        child: const Text("Добавить",
                          style: TextStyle(color: AppColors.greytextColor),)
                    ),
                    const SizedBox(height: 20),
                    !isPBActive?const Divider(
                      height: 2,
                      thickness: 1,
                      indent: 0,
                      endIndent: 0,
                      color: Colors.black,
                    ):const LinearCappedProgressIndicator(
                      backgroundColor: Colors.black26,
                      color: Colors.black,
                      cornerRadius: 0,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CustomBottomButton(
                            onPressed: () {
                              appVM.startMyTasksScreen();
                              BlocProvider.of<NavigationBloc>(context)
                                  .add(NavigateToTasksScreenEvent());
                            },
                            icon:    Image.asset('assets/icons/checklist2665651.png', height: 30, width: 30),
                            label: "Задачи"
                          ),
                          CustomBottomButton(
                              onPressed: () {
                                appVM.startMyAimsScreen();
                                BlocProvider.of<NavigationBloc>(context)
                                    .add(NavigateToAimsScreenEvent());
                              },
                                icon: Image.asset('assets/icons/goal6002764.png', height: 30, width: 30),
                                label: "Цели"
                          ),
                          CustomBottomButton(
                              onPressed: () {
                                if(appVM.mainScreenState!=null){
                                  appVM.mainCircles.clear();
                                  appVM.startMainScreen(appVM.mainScreenState!.moon);
                                }
                                final pressNum = appVM.getHintStates()["wheelClickNum"]??0;
                                if(pressNum>5){
                                  appVM.backPressedCount++;
                                  if(appVM.backPressedCount==appVM.settings.quoteupdateFreq){
                                    appVM.backPressedCount=0;
                                    appVM.hint=quoteBack[Random().nextInt(367)];
                                  }
                                }else{
                                  appVM.hint = "Кнопка “карта” возвращает вас на верхний уровень карты “желаний”. Сейчас вы уже здесь!";
                                }
                                appVM.setHintState("wheelClickNum", (pressNum+1));
                                BlocProvider.of<NavigationBloc>(context)
                                    .add(NavigateToMainScreenEvent());
                              },
                               icon: Image.asset('assets/icons/wheel2526426.png', height: 35, width: 35),
                               label: "Карта"
                          ),
                          CustomBottomButton(
                              onPressed: () {
                                appVM.startMyWishesScreen();
                                BlocProvider.of<NavigationBloc>(context)
                                    .add(NavigateToWishesScreenEvent());
                              },
                              icon:  Image.asset('assets/icons/notelove1648387.png', height: 30, width: 30),
                              label:"Желания"
                              ),
                          CustomBottomButton(
                              onPressed: () {
                                appVM.getDiary();
                                BlocProvider.of<NavigationBloc>(context)
                                    .add(NavigateToDiaryScreenEvent());
                              },
                              icon:  Image.asset('assets/icons/notepad2725914.png', height: 30, width: 30),
                              label:  "Дневник"
                          ),
                        ],
                      ),)
                  ],
                ),
              )
              ));
        });
  }

  onItemSelect(int id) async {
    appViewModel.myNodes.clear();
    appViewModel.currentAim=null;
    await appViewModel.getTask(id);
    BlocProvider.of<NavigationBloc>(context)
        .add(NavigateToTaskEditScreenEvent(id));
  }
  onItemClick(int id){
  }
  onItemDelete(int id){
    setState(() {
      taskList.removeWhere((element) => element.id==id);
    });
    //appViewModel.deleteTask(id);
  }
  filter(int type){
    setState(() {
      page==1?filteredTaskList = taskList.where((element) => element.isChecked).toList():
      page==2?filteredTaskList = taskList.where((element) => !element.isChecked).toList():
      page==3?filteredTaskList = taskList.where((element) => element.isActive).toList():filteredTaskList = taskList;
    });
  }
}

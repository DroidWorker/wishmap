import 'dart:math';

import 'package:capped_progress_indicator/capped_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../ViewModel.dart';
import '../common/bottombar.dart';
import '../common/custom_bottom_button.dart';
import '../common/taskitem_widget.dart';
import '../data/models.dart';
import '../data/static.dart';
import '../interface_widgets/colorButton.dart';
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
          page==3?filteredTaskList = taskList.where((element) => element.isActive&&!element.isChecked).toList():filteredTaskList = taskList;
          isPBActive=appVM.isinLoading;
          return Scaffold(
              backgroundColor: AppColors.backgroundColor,
              body: SafeArea(child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: Column(
                  children: [
                    Row(children: [
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_left, size: 30, color: AppColors.gradientStart),
                        onPressed: () {
                          BlocProvider.of<NavigationBloc>(context)
                              .add(NavigateToMainScreenEvent());
                        },
                      ),
                      const Spacer(),
                      const Text("Мои задачи", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                      const Spacer(),
                      const SizedBox(width: 35)
                    ],
                    ),
                    const SizedBox(height: 15),
                    Container(
                      height: 34,
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(5))
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            flex: 3,
                            child: GestureDetector(
                              child: page==0
                                  ? Container(
                                  margin: const EdgeInsets.all(1),
                                  height: 34,
                                  decoration:  const BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(5)),
                                      gradient: LinearGradient(
                                          colors: [AppColors.gradientStart, AppColors.gradientEnd]
                                      )
                                  ), child: const Center(child: Text("Все", style: TextStyle(color: Colors.white)))): const SizedBox(height:34, child: Center(child: Text("Все", style: TextStyle(color: AppColors.greytextColor)))),
                              onTap: () {
                                setState(() {
                                  page = 0;
                                  filter(page);
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 3, child: VerticalDivider(color: AppColors.backgroundColor, indent: 3, endIndent: 3)),
                          Expanded(
                            flex: 8,
                            child: GestureDetector(
                                child: page==3
                                    ? Container(
                                    margin: const EdgeInsets.all(1),
                                    height: 34,
                                    decoration:  const BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(5)),
                                        gradient: LinearGradient(
                                            colors: [AppColors.gradientStart, AppColors.gradientEnd]
                                        )
                                    ), child: const Center(child: Text("Актуальные", style: TextStyle(color: Colors.white)))): const SizedBox(height:34, child: Center(child: Text("Актуальные", style: TextStyle(color: AppColors.greytextColor)))),
                                onTap: () {
                                  setState(() {
                                    page = 3;
                                    filter(page);
                                  });
                                }
                            ),
                          ),
                          const SizedBox(width: 3, child: VerticalDivider(color: AppColors.backgroundColor, indent: 3, endIndent: 3)),
                          Expanded(
                            flex: 10,
                            child: GestureDetector(
                                child: page==2
                                    ? Container(
                                    margin: const EdgeInsets.all(1),
                                    height: 34,
                                    decoration:  const BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(5)),
                                        gradient: LinearGradient(
                                            colors: [AppColors.gradientStart, AppColors.gradientEnd]
                                        )
                                    ), child: const Center(child: Text("Не достигнуты", style: TextStyle(color: Colors.white)))): const SizedBox(height: 34, child: Center(child: Text("Не достигнуты", style: TextStyle(color: AppColors.greytextColor)))),
                                onTap: () {
                                  setState(() {
                                    page = 2;
                                    filter(page);
                                  });
                                }
                            ),
                          ),
                          const SizedBox(width: 3, child: VerticalDivider(color: AppColors.backgroundColor, indent: 3, endIndent: 3)),
                          Expanded(
                            flex: 8,
                            child: GestureDetector(
                                child: page==1
                                    ? Container(
                                    margin: const EdgeInsets.all(1),
                                    height: 34,
                                    decoration:  const BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(5)),
                                        gradient: LinearGradient(
                                            colors: [AppColors.gradientStart, AppColors.gradientEnd]
                                        )
                                    ), child: const Center(child: Text("Достигнуты", style: TextStyle(color: Colors.white)))): const SizedBox(height: 34, child: Center(child: Text("Достигнуты", style: TextStyle(color: AppColors.greytextColor)))),
                                onTap: () {
                                  setState(() {
                                    page = 1;
                                    filter(page);
                                  });
                                }
                            ),
                          ),
                        ]
                      ),
                    ),
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
                    const SizedBox(height: 3),
                    ColorRoundedButton("Добавить задачу", (){
                      appViewModel.hint="Добавление ЗАДАЧ происходит из цели, добавление цели из желания, а желания из сферы. Определяй сферу, создавай желания, ставь цели и выполняй задачи. Твои желания обязательно сбудутся";
                      appViewModel.mainCircles.clear();
                      if(appViewModel.mainScreenState!=null)appViewModel.startMainScreen(appViewModel.mainScreenState!.moon);
                      BlocProvider.of<NavigationBloc>(context)
                          .add(NavigateToMainScreenEvent());
                    }),
                    const SizedBox(height: 12),
                    !isPBActive?const SizedBox(height: 3,):const LinearCappedProgressIndicator(
                      backgroundColor: Colors.black26,
                      color: Colors.black,
                      cornerRadius: 0,
                    )
                  ],
                ),
              )),
            bottomNavigationBar: BottomBar(
              onAimsTap: (){
                appVM.startMyAimsScreen();
                BlocProvider.of<NavigationBloc>(context)
                    .add(NavigateToAimsScreenEvent());
              },
              onTasksTap: (){

              },
              onMapTap: (){
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
              onWishesTap: (){
                appVM.startMyWishesScreen();
                BlocProvider.of<NavigationBloc>(context)
                    .add(NavigateToWishesScreenEvent());
              },
              onDiaryTap: (){
                appVM.getDiary();
                BlocProvider.of<NavigationBloc>(context)
                    .add(NavigateToDiaryScreenEvent());
              },
            ),
          );
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

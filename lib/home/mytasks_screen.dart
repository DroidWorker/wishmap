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
  List<int> deleteQueue = [];
  late AppViewModel appViewModel;

  var isPBActive = false;
  var trashModeActive = false;

  int page = 3;//2 - не исполнено 1 - Исполнено 0 - Все желания

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
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        style: const ButtonStyle(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap, // the '2023' part
                        ),
                        icon: const Icon(Icons.keyboard_arrow_left, size: 30, color: AppColors.gradientStart),
                        onPressed: () {
                          BlocProvider.of<NavigationBloc>(context)
                              .add(NavigateToMainScreenEvent());
                        },
                      ),
                      const Spacer(),
                      const Text("Мои задачи", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        style: const ButtonStyle(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap, // the '2023' part
                        ),
                        icon: Image.asset("assets/icons/trash.png"),
                        onPressed: () {
                          setState(() {
                            trashModeActive = !trashModeActive;
                            deleteQueue.clear();
                          });
                        },
                      ),
                    ],
                    ),
                    const SizedBox(height: 20),
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
                                    ), child: const Center(child: Text("Актуальные", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)))): const SizedBox(height:34, child: Center(child: Text("Актуальные", style: TextStyle(color: AppColors.greytextColor, fontSize: 11, fontWeight: FontWeight.w600)))),
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
                                    ), child: const Center(child: Text("Не выполнены", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)))): const SizedBox(height: 34, child: Center(child: Text("Не достигнуты", style: TextStyle(color: AppColors.greytextColor, fontSize: 11, fontWeight: FontWeight.w600)))),
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
                                    ), child: const Center(child: Text("Выполнены", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)))): const SizedBox(height: 34, child: Center(child: Text("Достигнуты", style: TextStyle(color: AppColors.greytextColor, fontSize: 11, fontWeight: FontWeight.w600)))),
                                onTap: () {
                                  setState(() {
                                    page = 1;
                                    filter(page);
                                  });
                                }
                            ),
                          ),
                          const SizedBox(width: 3, child: VerticalDivider(color: AppColors.backgroundColor, indent: 3, endIndent: 3)),
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
                                  ), child: const Center(child: Text("Все", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)))): const SizedBox(height:34, child: Center(child: Text("Все", style: TextStyle(color: AppColors.greytextColor, fontSize: 11, fontWeight: FontWeight.w600)))),
                              onTap: () {
                                setState(() {
                                  page = 0;
                                  filter(page);
                                });
                              },
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
                              onDoubleClick: onDoubleClick,
                              outlined: deleteQueue.contains(filteredTaskList[index].id));
                        }
                    ),),
                    const SizedBox(height: 3),
                    !trashModeActive?ColorRoundedButton("Добавить задачу", (){
                      appViewModel.hint="Добавление ЗАДАЧ происходит из цели, добавление цели из желания, а желания из сферы. Определяй сферу, создавай желания, ставь цели и выполняй задачи. Твои желания обязательно сбудутся";
                      appViewModel.mainCircles.clear();
                      if(appViewModel.mainScreenState!=null)appViewModel.startMainScreen(appViewModel.mainScreenState!.moon);
                      BlocProvider.of<NavigationBloc>(context)
                          .add(NavigateToMainScreenEvent());
                    }):
                    ColorRoundedButton("Удалить", c: AppColors.buttonBackRed, (){
                      setState(() {
                        trashModeActive=false;
                        for (var id in deleteQueue) {
                          final task = appVM.taskItems.firstWhere((element) => element.id==id);
                          appVM.deleteTask(id, task.parentId);
                          appVM.taskItems.removeWhere((element) => element.id==id);
                        }
                      });
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
    if(!trashModeActive) {
      appViewModel.myNodes.clear();
      appViewModel.currentAim = null;
      await appViewModel.getTask(id);
      BlocProvider.of<NavigationBloc>(context)
          .add(NavigateToTaskEditScreenEvent(id));
    }else{
      setState(() {
        deleteQueue.contains(id)?deleteQueue.remove(id):deleteQueue.add(id);
      });
    }
  }
  onDoubleClick(int id) async {
    final task = taskList.firstWhere((element) => element.id==id);
    if(!task.isActive&&!task.isChecked){//активировать
      final parentAim = await appViewModel.getAimNow(task.parentId);
      if(parentAim!=null&&parentAim.isActive){
        appViewModel.activateTask(id, true);
        setState(() {
          appViewModel.taskItems.firstWhere((element) => element.id==id).isActive=true;
        });
      }
    }else if(!task.isChecked){//выполнить
      appViewModel.updateTaskStatus(id, true);
      setState(() {
        appViewModel.taskItems.firstWhere((element) => element.id==id).isChecked=true;
      });
    }else{//удалить
      showDialog(context: context,
        builder: (BuildContext c) => AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32.0))),
          title: const Text('Внимание', textAlign: TextAlign.center,),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Задача будет удалена", maxLines: 4, textAlign: TextAlign.center,),
              SizedBox(height: 4,),
              Divider(color: AppColors.dividerGreyColor,),
              SizedBox(height: 4,),
              Text("Удалить?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),)
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, 'OK');
                appViewModel.deleteTask(id ,task.parentId);
                taskList.removeWhere((element) => element.id==id);
              },
              child: const Text('Да'),
            ),
            TextButton(
              onPressed: () { Navigator.pop(context, 'Cancel');},
              child: const Text('Нет'),
            ),
          ],
        ),
      );
    }
  }
  onItemDelete(int id){
  }
  filter(int type){
    setState(() {
      page==1?filteredTaskList = taskList.where((element) => element.isChecked).toList():
      page==2?filteredTaskList = taskList.where((element) => !element.isChecked).toList():
      page==3?filteredTaskList = taskList.where((element) => element.isActive).toList():filteredTaskList = taskList;
    });
  }
}

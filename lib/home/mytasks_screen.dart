import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../ViewModel.dart';
import '../common/bottombar.dart';
import '../common/taskitem_widget.dart';
import '../data/models.dart';
import '../data/static.dart';
import '../dialog/bottom_sheet_action.dart';
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
    if(appViewModel.aimItems.isEmpty)appViewModel.startMyAimsScreen();
    if(appViewModel.wishItems.isEmpty)appViewModel.startMyWishesScreen();
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
                        icon: SvgPicture.asset("assets/icons/trash.svg", width: 28, height: 28),
                        onPressed: () {
                          setState(() {
                            trashModeActive = !trashModeActive;
                            deleteQueue.clear();
                          });
                        },
                      ),
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
                          final parentaim = appVM.aimItems.firstWhereOrNull((e) => e.id==filteredTaskList[index].parentId);
                          final parentwish = parentaim?.parentId==0?WishItem(id: 0, text: "Я", isChecked: false, isActive: true, isHidden: false):parentaim!=null?appVM.wishItems.firstWhereOrNull((e) => e.id==parentaim.parentId):null;
                          return TaskItemWidget(key: UniqueKey(), ti: filteredTaskList[index],
                              p: "${parentwish?.text.replaceAll("HEADERSIMPLETASKHEADER", "")} > ${parentaim?.text.replaceAll("HEADERSIMPLETASKHEADER", "")}",
                              onSelect: onItemSelect,
                              onDoubleClick: onDoubleClick,
                              outlined: deleteQueue.contains(filteredTaskList[index].id));
                        }
                    ),),
                    const SizedBox(height: 3),
                    !trashModeActive?ColorRoundedButton("Добавить общую задачу", (){
                      BlocProvider.of<NavigationBloc>(context)
                          .add(NavigateToSimpleTasksScreenEvent());
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
                    const SizedBox(height: 15),
                    /*!isPBActive?const SizedBox(height: 3,):const LinearCappedProgressIndicator(
                      backgroundColor: Colors.black26,
                      color: Colors.black,
                      cornerRadius: 0,
                    )*/
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
      appViewModel.updateTaskStatus(id, true, needUpdate: false);
      /*setState(() {
        appViewModel.taskItems.firstWhere((element) => element.id==id).isChecked=true;
      });*/
    }else{//удалить
      showModalBottomSheet<void>(
        backgroundColor: AppColors.backgroundColor,
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return ActionBS('Внимание', "Задача будет удалена\nУдалить?", "Да", 'Нет',
              onOk: () {
                Navigator.pop(context, 'OK');
                appViewModel.deleteTask(id ,task.parentId);
                setState(() {
                  taskList.removeWhere((element) => element.id==id);
                });
              },
              onCancel: () { Navigator.pop(context, 'Cancel');
              });
        },
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

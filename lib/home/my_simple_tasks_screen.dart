import 'dart:math';

import 'package:capped_progress_indicator/capped_progress_indicator.dart';
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
import '../navigation/navigation_block.dart';
import '../res/colors.dart';

class SimpleTasksScreen extends StatefulWidget {
  const SimpleTasksScreen({super.key});

  @override
  _SimpleTasksScreenState createState() => _SimpleTasksScreenState();
}

class _SimpleTasksScreenState extends State{
  List<TaskItem> taskList = [];
  late AppViewModel appViewModel;

  final TextEditingController controller = TextEditingController(text: "");

  var isPBActive = false;
  var isReverce = false;

  @override
  Widget build(BuildContext context) {
    appViewModel = Provider.of<AppViewModel>(context);
    return Consumer<AppViewModel>(
        builder: (context, appVM, child) {
          taskList = appVM.taskItems.where((e) => e.text.contains("HEADERSIMPLETASKHEADER")).toList();
          if(!isReverce)taskList = taskList.reversed.toList();
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
                    const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Простые задачи", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        Text("Быстрое создание задач в «Я»", style: TextStyle(color: AppColors.darkGrey),)
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      style: const ButtonStyle(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap, // the '2023' part
                      ),
                      icon: SvgPicture.asset("assets/icons/change.svg", width: 28, height: 28),
                      onPressed: () {
                        setState(() {
                          isReverce = !isReverce;
                        });
                      },
                    ),
                  ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(child:
                  ListView.builder(
                      itemCount: taskList.length+1,
                      itemBuilder: (context, index) {
                        return (isReverce&&index==taskList.length)?Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: controller,
                                  textCapitalization: TextCapitalization.sentences,
                                  style: const TextStyle(color: Colors.black), // Черный текст ввода
                                  decoration: const InputDecoration(
                                    hintText: "Text",
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 0,
                                        style: BorderStyle.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              FloatingActionButton(
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                onPressed: (){
                                  if(controller.text.isNotEmpty){
                                    appVM.addSimpleTask(0, "m", "HEADERSIMPLETASKHEADER${controller.text}");
                                    controller.clear();
                                  }
                                },
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd])
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    size: 25,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ):
                        (!isReverce&&index==0)?Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: controller,
                                  textCapitalization: TextCapitalization.sentences,
                                  style: const TextStyle(color: Colors.black), // Черный текст ввода
                                  decoration: const InputDecoration(
                                    hintText: "Text",
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 0,
                                        style: BorderStyle.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              FloatingActionButton(
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                onPressed: (){
                                  if(controller.text.isNotEmpty){
                                    appVM.addSimpleTask(0, "m", "HEADERSIMPLETASKHEADER${controller.text}");
                                    controller.clear();
                                  }
                                },
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd])
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    size: 25,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ):
                        TaskItemWidget(ti: taskList[!isReverce?index-1:index],
                            p: appVM.aimItems.firstWhere((e) => e.id==taskList[!isReverce?index-1:index].parentId, orElse: ()=> AimItem(id: -1, parentId: -1, text: "", isChecked: false, isActive: true)).text.replaceAll("HEADERSIMPLETASKHEADER", ""),
                            onSelect: onItemSelect,
                            onDoubleClick: onDoubleClick,
                            outlined: false);
                      }
                  ),),
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
                appVM.startMyTasksScreen();
                BlocProvider.of<NavigationBloc>(context)
                    .add(NavigateToTasksScreenEvent());
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
      appViewModel.currentAim = null;
      await appViewModel.getTask(id);
      BlocProvider.of<NavigationBloc>(context)
          .add(NavigateToTaskEditScreenEvent(id));
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
        appViewModel.taskItems.firstWhere((element) => element.id==id).isChecked=true;
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
}

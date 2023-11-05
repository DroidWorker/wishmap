import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../ViewModel.dart';
import '../common/taskitem_widget.dart';
import '../data/models.dart';
import '../navigation/navigation_block.dart';
import '../res/colors.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State{
  List<TaskItem> taskList = [];
  late AppViewModel appViewModel;

  @override
  Widget build(BuildContext context) {
    appViewModel = Provider.of<AppViewModel>(context);
    return Consumer<AppViewModel>(
        builder: (context, appVM, child) {
          taskList = appVM.taskItems;
          return Scaffold(
              backgroundColor: AppColors.backgroundColor,
              body: SafeArea(child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
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
                      const Spacer(),
                      const Text("Мои задачи", style: TextStyle(fontSize: 18),),
                      const Spacer(),
                    ],
                    ),
                    const Text("за последние 24 часа"),
                    const SizedBox(height: 20),
                    Expanded(child:
                    ListView.builder(
                        itemCount: taskList.length,
                        itemBuilder: (context, index) {
                          return TaskItemWidget(ti: taskList[index],
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
                          BlocProvider.of<NavigationBloc>(context)
                              .add(NavigateToMainScreenEvent());
                        },
                        child: const Text("Добавить",
                          style: TextStyle(color: AppColors.greytextColor),)
                    ),
                    const SizedBox(height: 20),
                    const Divider(
                      height: 2,
                      thickness: 1,
                      indent: 0,
                      endIndent: 0,
                      color: Colors.black,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 3, 5, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              appVM.startMyTasksScreen();
                              BlocProvider.of<NavigationBloc>(context)
                                  .add(NavigateToTasksScreenEvent());
                            },
                            style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: Colors.transparent,),                                  child: Column(
                              children: [
                                Image.asset('assets/icons/checklist2665651.png', height: 30, width: 30),
                                const Text("Задачи", style:  TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black),)
                              ]
                          ),
                          ),
                          ElevatedButton(
                              onPressed: () {
                                appVM.startMyAimsScreen();
                                BlocProvider.of<NavigationBloc>(context)
                                    .add(NavigateToAimsScreenEvent());
                              },
                              style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: Colors.transparent,),                                   child: Column(
                              children: [
                                Image.asset('assets/icons/goal6002764.png', height: 30, width: 30),
                                const Text("Задачи", style:  TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black),)
                              ]
                          )
                          ),
                          ElevatedButton(
                              onPressed: () {
                                if(appVM.mainScreenState!=null){
                                  appVM.mainCircles.clear();
                                  appVM.startMainScreen(appVM.mainScreenState!.moon);
                                }
                                BlocProvider.of<NavigationBloc>(context)
                                    .add(NavigateToMainScreenEvent());
                              },
                              style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: Colors.transparent,),                                   child: Column(
                              children: [
                                Image.asset('assets/icons/wheel2526426.png', height: 35, width: 35),
                                const Text("Задачи", style:  TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black),)
                              ]
                          )
                          ),
                          ElevatedButton(
                              onPressed: () {
                                appVM.startMyWishesScreen();
                                BlocProvider.of<NavigationBloc>(context)
                                    .add(NavigateToWishesScreenEvent());
                              },
                              style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: Colors.transparent,),                                   child: Column(
                              children: [
                                Image.asset('assets/icons/notelove1648387.png', height: 30, width: 30),
                                const Text("Задачи", style:  TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black),)
                              ]
                          )
                          ),
                          ElevatedButton(
                              onPressed: () {

                              },
                              style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: Colors.transparent,),                                   child: Column(
                              children: [
                                Image.asset('assets/icons/notepad2725914.png', height: 30, width: 30),
                                const Text("Задачи", style:  TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black),)
                              ]
                          )
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
    await appViewModel.getTask(id);
    BlocProvider.of<NavigationBloc>(context)
        .add(NavigateToTaskEditScreenEvent(id));
  }
  onItemClick(int id){
    bool status = false;
    setState((){
      taskList.where((element) => element.id==id).forEach((element) {element.isChecked=!element.isChecked;status = element.isChecked;});
    });
    appViewModel.updateTaskStatus(id, status);
  }
  onItemDelete(int id){
    setState(() {
      taskList.removeWhere((element) => element.id==id);
    });
    appViewModel.deleteTask(id);
  }
}

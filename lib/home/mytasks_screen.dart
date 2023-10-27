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
                          BlocProvider.of<NavigationBloc>(context)
                              .add(NavigateToMainScreenEvent());
                        },
                        child: const Text("Добавить",
                          style: TextStyle(color: AppColors.greytextColor),)
                    ),
                    const SizedBox(height: 20),
                    const Divider(
                      height: 10,
                      thickness: 5,
                      indent: 0,
                      endIndent: 0,
                      color: Colors.black,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Image.asset(
                                'assets/icons/checklist2665651.png'),
                            iconSize: 30,
                            onPressed: () {
                              appVM.startMyTasksScreen();
                              BlocProvider.of<NavigationBloc>(context)
                                  .add(NavigateToTasksScreenEvent());
                            },
                          ),
                          IconButton(
                            icon: Image.asset('assets/icons/goal6002764.png'),
                            iconSize: 30,
                            onPressed: () {
                              appVM.startMyAimsScreen();
                              BlocProvider.of<NavigationBloc>(context)
                                  .add(NavigateToAimsScreenEvent());
                            },
                          ),
                          IconButton(
                            icon: Image.asset('assets/icons/wheel2526426.png'),
                            iconSize: 40,
                            onPressed: () {
                              BlocProvider.of<NavigationBloc>(context)
                                  .add(NavigateToMainScreenEvent());
                            },
                          ),
                          IconButton(
                            icon: Image.asset(
                                'assets/icons/notelove1648387.png'),
                            iconSize: 30,
                            onPressed: () {
                              appVM.startMyWishesScreen();
                              BlocProvider.of<NavigationBloc>(context)
                                  .add(NavigateToWishesScreenEvent());
                            },
                          ),
                          IconButton(
                            icon: Image.asset(
                                'assets/icons/notepad2725914.png'),
                            iconSize: 30,
                            onPressed: () {
                            },
                          )
                        ],
                      ),)
                  ],
                ),
              )
              ));
        });
  }

  onItemClick(int id){
    bool status = false;
    setState((){
      taskList.where((element) => element.id==id).forEach((element) {element.isChecked=!element.isChecked;status = !element.isChecked;});
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

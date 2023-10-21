import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../common/taskitem_widget.dart';
import '../data/models.dart';
import '../navigation/navigation_block.dart';
import '../res/colors.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key, required this.taskList});
  final List<TaskItem> taskList;

  @override
  _TaskScreenState createState() => _TaskScreenState(this.taskList);
}

class _TaskScreenState extends State{
  _TaskScreenState(this.taskList);

  List<TaskItem> taskList;

  @override
  Widget build(BuildContext context) {
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
                    onPressed: () {},
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
                    itemBuilder: (context, index){
                      return TaskItemWidget(ti: taskList[index], onClick: onItemClick, onDelete: onItemDelete);
                    }
                ),),
                const SizedBox(height: 10),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.fieldFillColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // <-- Radius
                      ),
                    ),
                    onPressed: (){
                      BlocProvider.of<NavigationBloc>(context)
                          .add(NavigateToMainScreenEvent());
                    },
                    child: const Text("Добавить",style: TextStyle(color: AppColors.greytextColor),)
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
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Image.asset('assets/icons/checklist2665651.png'),
                        iconSize: 30,
                        onPressed: () {

                        },
                      ),
                      IconButton(
                        icon: Image.asset('assets/icons/goal6002764.png'),
                        iconSize: 30,
                        onPressed: () {
                          BlocProvider.of<NavigationBloc>(context)
                              .add(NavigateToWishesScreenEvent());
                        },
                      ),
                      IconButton(
                        icon: Image.asset('assets/icons/wheel2526426.png'),
                        iconSize: 30,
                        onPressed: () {
                          BlocProvider.of<NavigationBloc>(context)
                              .add(NavigateToAimsScreenEvent());
                        },
                      ),
                      IconButton(
                        icon: Image.asset('assets/icons/notelove1648387.png'),
                        iconSize: 30,
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Image.asset('assets/icons/notepad2725914.png'),
                        iconSize: 30,
                        onPressed: () {
                          BlocProvider.of<NavigationBloc>(context)
                              .add(NavigateToProfileScreenEvent());
                        },
                      )
                    ],
                  ),)
                ],
            ),
        )
    ));
  }

  onItemClick(int id){
    setState((){
      taskList.where((element) => element.id==id).forEach((element) {element.isChecked=!element.isChecked;});
    });
  }
  onItemDelete(int id){
    setState(() {
      taskList.removeWhere((element) => element.id==id);
    });
  }
}

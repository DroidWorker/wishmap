import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/common/treeview_widget.dart';
import '../ViewModel.dart';
import '../data/models.dart';
import '../navigation/navigation_block.dart';
import '../res/colors.dart';

class TaskEditScreen extends StatelessWidget {

  int aimId = 0;
  TaskEditScreen({super.key, required this.aimId});

  List<MyTreeNode> roots = [];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppViewModel>(
        builder: (context, appVM, child) {
          TaskData ai = appVM.currentTask??TaskData(id: -1, parentId: -1, text: 'объект не найден', description: "", isChecked: false);
          if(appVM.currentAim!=null) {
            AimData ad = appVM.currentAim!;
            var childNodes = MyTreeNode(id: ai.id, type: 't', title: ai.text, children: [MyTreeNode(id: ad.id, type: 'a', title: ad.text)]);
            roots = appVM.convertToMyTreeNodeIncludedAimsTasks(childNodes, ad.parentId);
          }else {
            appVM.getAim(ai.parentId);
          }
          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: SafeArea(child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Expanded(
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "Цель",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: AppColors.greytextColor),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: (){
                                  appVM.updateTask(ai);
                                  BlocProvider.of<NavigationBloc>(context).clearHistory();
                                  BlocProvider.of<NavigationBloc>(context)
                                      .add(NavigateToMainScreenEvent());
                                },
                                child: const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 5, 5),
                                  child: Text("Сохранить", style: TextStyle(color: AppColors.blueTextColor),),
                                ),
                              )
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              appVM.deleteTask(ai.id);
                              BlocProvider.of<NavigationBloc>(context).clearHistory();
                              BlocProvider.of<NavigationBloc>(context)
                                  .add(NavigateToMainScreenEvent());
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(5),
                              child: Text("Удалить", style: TextStyle(color: AppColors.greytextColor),),
                            ),
                          )
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: (){
                              appVM.updateTaskStatus(ai.id, true);
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(5),
                              child: Text("Достигнута", style: TextStyle(color: AppColors.pinkTextColor),),
                            ),
                          )
                        ),
                        const Divider(
                          height: 3,
                          color: AppColors.dividerGreyColor,
                          indent: 5,
                          endIndent: 5,
                        ),
                      ],
                    ),
                    Text(ai.text, style: const TextStyle(fontSize: 20),),
                    const SizedBox(height: 15,),
                    Text(ai.description,
                      style: const TextStyle(fontSize: 16),),
                    const SizedBox(height: 15,),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          height: roots.length * 100,
                          width: 400,
                          child: MyTreeView(roots: roots, onTap: (id,type){
                            if(type=="m"){
                              BlocProvider.of<NavigationBloc>(context).clearHistory();
                              BlocProvider.of<NavigationBloc>(context)
                                  .add(NavigateToSpheresOfLifeScreenEvent());
                            }else if(type=="w"){
                              BlocProvider.of<NavigationBloc>(context).clearHistory();
                              appVM.startWishScreen(id, 0);
                              BlocProvider.of<NavigationBloc>(context)
                                  .add(NavigateToWishScreenEvent());
                            }else if(type=="a"){
                              appVM.getAim(id);
                              BlocProvider.of<NavigationBloc>(context).clearHistory();
                              BlocProvider.of<NavigationBloc>(context)
                                  .add(NavigateToAimEditScreenEvent(id));
                            }else if(type=="t"&&ai.id!=id){
                              appVM.getTask(id);
                              BlocProvider.of<NavigationBloc>(context).clearHistory();
                              BlocProvider.of<NavigationBloc>(context)
                                  .add(NavigateToTaskEditScreenEvent(id));
                            }
                          },),
                        )
                    )
                  ]
              ),
        ))
    );
  });
  }
}

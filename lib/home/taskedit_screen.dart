import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/common/treeview_widget.dart';
import '../ViewModel.dart';
import '../data/models.dart';
import '../navigation/navigation_block.dart';
import '../res/colors.dart';

class TaskEditScreen extends StatefulWidget {

  int aimId = 0;

  TaskEditScreen({super.key, required this.aimId});

  @override
  TaskEditScreenState createState() => TaskEditScreenState();
}

class TaskEditScreenState extends State<TaskEditScreen>{
  List<MyTreeNode> roots = [];

  final text = TextEditingController();
  final description = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppViewModel>(
        builder: (context, appVM, child) {
          TaskData ai = appVM.currentTask??TaskData(id: -1, parentId: -1, text: 'объект не найден', description: "", isChecked: false);
          if(appVM.currentAim!=null) {
            AimData ad = appVM.currentAim!;
            var childNodes = MyTreeNode(id: ad.id, type: 'a', title: ad.text, isChecked: ad.isChecked, children: [MyTreeNode(id: ai.id, type: 't', title: ai.text, isChecked: ai.isChecked)..noClickable=true]);
            roots = appVM.convertToMyTreeNodeIncludedAimsTasks(childNodes, ad.parentId);
          }else {
            appVM.getAim(ai.parentId);
          }
          text.text = ai.text;
          description.text = ai.description;
          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: SafeArea(
                child: Column(children:[Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.keyboard_arrow_left),
                              iconSize: 30,
                              onPressed: () {
                                BlocProvider.of<NavigationBloc>(context)
                                    .handleBackPress();
                              },
                            ),
                            const Spacer(),
                            TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: AppColors.greyBackButton,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                  ),
                                ),
                                onPressed: () async {
                                  appVM.updateTaskStatus(ai.id, !ai.isChecked);
                                  showDialog(context: context,
                                    builder: (BuildContext context) => AlertDialog(
                                      title: ai.isChecked? const Text('достигнута'):const Text(' не достигнута'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () { Navigator.pop(context, 'OK');},
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: const Text("Достигнута",style: TextStyle(color: Colors.black, fontSize: 12))
                            ),
                            const SizedBox(width: 3,),
                            TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: AppColors.greyBackButton,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                  ),
                                ),
                                onPressed: () async {
                                  appVM.deleteTask(ai.id);
                                  showDialog(context: context,
                                    builder: (BuildContext context) => AlertDialog(
                                      title: const Text('удаленa'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () { Navigator.pop(context, 'OK');
                                          BlocProvider.of<NavigationBloc>(context).handleBackPress();},
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                                  ).then((value) {
                                    BlocProvider.of<NavigationBloc>(context).handleBackPress();
                                  });
                                },
                                child: const Text("Удалить",style: TextStyle(color: Colors.black, fontSize: 12))
                            ),
                            const SizedBox(width: 3,),
                            TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: AppColors.greyBackButton,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                  ),
                                ),
                                onPressed: () async {
                                  if(text.text.isEmpty||description.text.isEmpty){
                                    showDialog(context: context,
                                      builder: (BuildContext context) => AlertDialog(
                                        title: const Text('Заполните поля'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, 'OK'),
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ),
                                    );
                                    return;
                                  }else{
                                    ai.text = text.text;
                                    ai.description = description.text;
                                  }
                                  appVM.updateTask(ai);
                                  showDialog(context: context,
                                    builder: (BuildContext context) => AlertDialog(
                                      title: const Text('сохраненa'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, 'OK'),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: const Text("Cохранить задачу",
                                  style: TextStyle(color: AppColors.blueTextColor, fontSize: 12),)
                            ),
                          ],
                        ),
                        const Divider(
                          height: 3,
                          color: AppColors.dividerGreyColor,
                          indent: 5,
                          endIndent: 5,
                        ),
                      ],
                    ),
                    TextField(
                      controller: text,
                      style: const TextStyle(color: Colors.black), // Черный текст ввода
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.fieldFillColor,
                          hintText: 'Название',
                          hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
                          border: InputBorder.none
                      ),
                    ),
                    const SizedBox(height: 15,),
                    TextField(
                      controller: description,
                      style: const TextStyle(color: Colors.black), // Черный текст ввода
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.fieldFillColor,
                          hintText: 'Описание',
                          hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
                          border: InputBorder.none
                      ),
                    ),
                    const SizedBox(height: 15,),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          height: roots.length * 200,
                          child: MyTreeView(key: UniqueKey(),roots: roots, onTap: (id,type){
                            if(type=="m"){
                              BlocProvider.of<NavigationBloc>(context).clearHistory();
                              appVM.cachedImages.clear();
                              BlocProvider.of<NavigationBloc>(context)
                                  .add(NavigateToMainSphereEditScreenEvent());
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
        ),
                  if(MediaQuery.of(context).viewInsets.bottom!=0) SizedBox(height: 30,
                    child: FooterLayout(
                      footer: Container(height: 30,color: Colors.white,alignment: Alignment.centerRight, child:
                      GestureDetector(
                        onTap: (){FocusManager.instance.primaryFocus?.unfocus();},
                        child: const Text("готово", style: TextStyle(fontSize: 20),),
                      )
                        ,),
                    ),)
            ]))
    );
  });
  }
}

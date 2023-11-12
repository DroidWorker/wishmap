import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/common/treeview_widget.dart';
import '../ViewModel.dart';
import '../data/models.dart';
import '../navigation/navigation_block.dart';
import '../res/colors.dart';

class AimEditScreen extends StatelessWidget {
  int aimId = 0;
  AimEditScreen({super.key,required this.aimId});

  List<MyTreeNode> roots = [];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppViewModel>(
        builder: (context, appVM, child) {
          AimData ai = appVM.currentAim??AimData(id: -1, parentId: -1, text: 'объект не найден', description: "", isChecked: false);
          roots = appVM.convertToMyTreeNode(CircleData(id: ai.id, text: ai.text, color: Colors.transparent, parenId: ai.parentId));
          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: SafeArea(child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.blueButtonBack,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        10), // <-- Radius
                                  ),
                                ),
                                onPressed: () async {
                                  appVM.updateAimStatus(aimId, true);
                                  showDialog(context: context,
                                    builder: (BuildContext context) => AlertDialog(
                                      title: const Text('достигнута'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () { Navigator.pop(context, 'OK');},
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: const Text("Достигнута")
                            ),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.blueButtonBack,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        10), // <-- Radius
                                  ),
                                ),
                                onPressed: () async {
                                  appVM.deleteAim(aimId);
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
                                  );
                                },
                                child: const Text("Удалить")
                            ),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.blueButtonBack,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        10), // <-- Radius
                                  ),
                                ),
                                onPressed: () async {
                                  appVM.updateAim(ai);
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
                                child: const Text("Cохранить",
                                  style: TextStyle(color: AppColors.blueTextColor),)
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
                    Text(ai.text, style: const TextStyle(fontSize: 20),),
                    Text(ai.description, style: const TextStyle(fontSize: 16),),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          height: 200,
                          width: 200,
                          child: MyTreeView(roots: roots, onTap: (id, type){
                            if(type=="m"){
                              BlocProvider.of<NavigationBloc>(context).clearHistory();
                              BlocProvider.of<NavigationBloc>(context)
                                  .add(NavigateToSpheresOfLifeScreenEvent());
                            }else if(type=="w"){
                              BlocProvider.of<NavigationBloc>(context).clearHistory();
                              appVM.startWishScreen(id, 0);
                              BlocProvider.of<NavigationBloc>(context)
                                  .add(NavigateToWishScreenEvent());
                            }else if(type=="a"&&aimId!=id){
                              appVM.getAim(id);
                              BlocProvider.of<NavigationBloc>(context).clearHistory();
                              BlocProvider.of<NavigationBloc>(context)
                                  .add(NavigateToAimEditScreenEvent(id));
                            }else if(type=="t"){
                              appVM.currentTask=null;
                              BlocProvider.of<NavigationBloc>(context).clearHistory();
                              BlocProvider.of<NavigationBloc>(context)
                                  .add(NavigateToTaskEditScreenEvent(id));
                            }
                          },),
                        )
                    ),
                    const SizedBox(height: 30),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                  .add(NavigateToTaskCreateScreenEvent(ai.id));
                            },
                            child: const Text("Создать задачу",
                              style: TextStyle(color: AppColors.greytextColor),)
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Укажи задачу дня для достижения цели. Помни! Задача актуальна 24 часа",
                          style: TextStyle(
                              fontSize: 10, color: AppColors.greytextColor),)
                      ],
                    ),
                  ]
              ),
            )
            ));
    });
  }
}

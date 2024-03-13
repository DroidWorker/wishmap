import 'dart:math';

import 'package:capped_progress_indicator/capped_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/common/aimitem_widget.dart';
import '../ViewModel.dart';
import '../common/custom_bottom_button.dart';
import '../data/models.dart';
import '../data/static.dart';
import '../navigation/navigation_block.dart';
import '../res/colors.dart';

class AimsScreen extends StatefulWidget {
  const AimsScreen({super.key});

  @override
  _AimsScreenState createState() => _AimsScreenState();
}

class _AimsScreenState extends State<AimsScreen>{
  int page = 0;//false - Исполнено true - Все желания
  late List<AimItem> allAims;
  List<AimItem> filteredAimList = [];

  late AppViewModel appViewModel;

  var isPBActive = false;

  @override
  Widget build(BuildContext context) {
    appViewModel = Provider.of<AppViewModel>(context);
    return Consumer<AppViewModel>(
        builder: (context, appVM, child) {
          allAims = appVM.aimItems;
          page==1?filteredAimList = allAims.where((element) => element.isChecked).toList():
          page==2?filteredAimList = allAims.where((element) => !element.isChecked).toList():
          page==3?filteredAimList = allAims.where((element) => element.isActive).toList():filteredAimList = allAims;
          isPBActive=appVM.isinLoading;
          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: SafeArea(child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Column(
                children: [
                  Row(children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_left, size: 30,),
                      onPressed: () {
                        BlocProvider.of<NavigationBloc>(context)
                            .add(NavigateToMainScreenEvent());
                      },
                    ),
                    const Spacer(),
                    const Text("Мои цели", style: TextStyle(fontSize: 18),),
                    const Spacer(),
                  ],
                  ),
                  const SizedBox(height: 20),
                  Row(children: [
                    GestureDetector(
                      child: page==3
                          ? const Text("Актуальные",
                          style: TextStyle(decoration: TextDecoration.underline))
                          : const Text("Актуальные"),
                      onTap: () {
                        setState(() {
                          page = 3;
                          filterAims(page);
                        });
                      },
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      child: page==2
                          ? const Text("Не достигнуты",
                          style: TextStyle(decoration: TextDecoration.underline))
                          : const Text("Не достигнуты"),
                      onTap: () {
                        setState(() {
                          page = 2;
                          filterAims(page);
                        });
                      },
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      child: page==1
                          ? const Text("Достигнуты",
                          style: TextStyle(decoration: TextDecoration.underline))
                          : const Text("Достигнуты"),
                      onTap: () {
                        setState(() {
                          page = 1;
                          filterAims(page);
                        });
                      },
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      child: page==0
                          ? const Text("Все цели",
                          style: TextStyle(decoration: TextDecoration.underline))
                          : const Text("Все цели"),
                      onTap: () {
                        setState(() {
                          page = 0;
                          filterAims(page);
                        });
                      },
                    ),
                  ],),
                  const SizedBox(height: 10,),
                  Expanded(child:
                  ListView.builder(
                      itemCount: filteredAimList.length,
                      itemBuilder: (context, index) {
                        return AimItemWidget(ai: filteredAimList[index],
                            onItemSelect: onItemSelect,
                            onClick: onItemClick,
                            onDelete: onItemDelete);
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
                      onPressed: () {
                        if(appViewModel.mainScreenState!=null)appViewModel.startMainScreen(appViewModel.mainScreenState!.moon);
                        BlocProvider.of<NavigationBloc>(context).removeLastFromBS();
                        appViewModel.hint="Добавление ЦЕЛЕЙ происходит  из желания, а желания из сферы. Определяй сферу, создавай желания, ставь цели и выполняй задачи. Твои желания обязательно сбудутся";
                        BlocProvider.of<NavigationBloc>(context)
                            .add(NavigateToMainScreenEvent());
                      },
                      child: const Text("Добавить",
                        style: TextStyle(color: AppColors.greytextColor),)
                  ),
                  const SizedBox(height: 20),
                  !isPBActive?const Divider(
                    height: 2,
                    thickness: 1,
                    indent: 0,
                    endIndent: 0,
                    color: Colors.black,
                  ):const LinearCappedProgressIndicator(
                    backgroundColor: Colors.black26,
                    color: Colors.black,
                    cornerRadius: 0,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CustomBottomButton(
                          onPressed: () {
                            appVM.startMyTasksScreen();
                            BlocProvider.of<NavigationBloc>(context)
                                .add(NavigateToTasksScreenEvent());
                          },
                          icon:  Image.asset('assets/icons/checklist2665651.png', height: 30, width: 30),
                          label:  "Задачи"
                        ),
                        CustomBottomButton(
                            onPressed: () {

                            },
                            icon:  Image.asset('assets/icons/goal6002764.png', height: 30, width: 30),
                            label:  "Цели"
                        ),
                        CustomBottomButton(
                            onPressed: () {
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
                             icon: Image.asset('assets/icons/wheel2526426.png', height: 35, width: 35),
                             label: "Карта"
                        ),
                        CustomBottomButton(
                            onPressed: () {
                              appVM.startMyWishesScreen();
                              BlocProvider.of<NavigationBloc>(context)
                                  .add(NavigateToWishesScreenEvent());
                            },
                            icon:  Image.asset('assets/icons/notelove1648387.png', height: 30, width: 30),
                            label:  "Желания"
                        ),
                        CustomBottomButton(
                            onPressed: () {
                              appVM.getDiary();
                              BlocProvider.of<NavigationBloc>(context)
                                  .add(NavigateToDiaryScreenEvent());
                            },
                            icon:  Image.asset('assets/icons/notepad2725914.png', height: 30, width: 30),
                            label:  "Дневник"
                            ),
                      ],
                    ),)
                ],
              ),
            )
            ));
    });
  }

  filterAims(int type){
    setState(() {
      page==1?filteredAimList = allAims.where((element) => element.isChecked).toList():
      page==2?filteredAimList = allAims.where((element) => !element.isChecked).toList():
      page==3?filteredAimList = allAims.where((element) => element.isActive).toList():
      filteredAimList = allAims;
    });
  }
  onItemSelect(int id) async {
    await appViewModel.getAim(id);
    BlocProvider.of<NavigationBloc>(context)
        .add(NavigateToAimEditScreenEvent(id));
  }
  onItemClick(int id){
  }
  onItemDelete(int id){
    setState(() {
      filteredAimList.removeWhere((element) => element.id==id);
    });
    //appViewModel.deleteAim(id);
  }
}

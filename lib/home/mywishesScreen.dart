import 'dart:math';

import 'package:capped_progress_indicator/capped_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/common/custom_bottom_button.dart';
import '../ViewModel.dart';
import '../common/bottombar.dart';
import '../common/treeview_widget.dart';
import '../data/models.dart';
import '../data/static.dart';
import '../interface_widgets/colorButton.dart';
import '../navigation/navigation_block.dart';
import '../res/colors.dart';

class WishesScreen extends StatefulWidget {
  WishesScreen({super.key});

  @override
  _WishesScreenState createState() => _WishesScreenState();
}

class _WishesScreenState extends State<WishesScreen>{
  int page = 3;//2 - не исполнено 1 - Исполнено 0 - Все желания 3 - актуальные
  List<WishItem> allWishList = [];
  List<WishItem> filteredWishList = [];
  List<MyTreeNode> roots = [];
  List<int> deleteQueue = [];
  AppViewModel? appViewModel;
  bool isWishesRequested = false;

  var isPBActive = false;
  var trashModeActive = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppViewModel>(
        builder: (context, appVM, child) {
          appViewModel=appVM;
          allWishList = appVM.wishItems;
          if(allWishList.isEmpty&&!isWishesRequested){
            appVM.startMyWishesScreen();
            isWishesRequested = true;
          }
          page==1?filteredWishList = allWishList.where((element) => element.isChecked).toList():
          page==2?filteredWishList = allWishList.where((element) => !element.isChecked).toList():
          page==3?filteredWishList = allWishList.where((element) => element.isActive&&!element.isChecked).toList():filteredWishList = allWishList;
          isPBActive=appVM.isinLoading;
          if(filteredWishList.isNotEmpty){
            roots = convertListToMyTreeNodes(filteredWishList);
          }else{roots.clear();}
          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: SafeArea(
                maintainBottomViewPadding: true,
                child: Padding(
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
                    const Text("Мои желания", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    const SizedBox(width: 32)
                    /*IconButton(
                      icon: Image.asset("assets/icons/trash.png"),
                      onPressed: () {
                        setState(() {
                          trashModeActive = !trashModeActive;
                          deleteQueue.clear();
                        });
                      },
                    ),*/
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
                                  ), child: const Center(child: Text("Актуальные", style: TextStyle(color: Colors.white)))): const SizedBox(height:34, child: Center(child: Text("Актуальные", style: TextStyle(color: AppColors.greytextColor)))),
                              onTap: () {
                                setState(() {
                                  page = 3;
                                  filterAims(page);
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
                                  ), child: const Center(child: Text("Не исполнены", style: TextStyle(color: Colors.white)))): const SizedBox(height: 34, child: Center(child: Text("Не достигнуты", style: TextStyle(color: AppColors.greytextColor)))),
                              onTap: () {
                                setState(() {
                                  page = 2;
                                  filterAims(page);
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
                                  ), child: const Center(child: Text("Исполнены", style: TextStyle(color: Colors.white)))): const SizedBox(height: 34, child: Center(child: Text("Достигнуты", style: TextStyle(color: AppColors.greytextColor)))),
                              onTap: () {
                                setState(() {
                                  page = 1;
                                  filterAims(page);
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
                                ), child: const Center(child: Text("Все", style: TextStyle(color: Colors.white)))): const SizedBox(height:34, child: Center(child: Text("Все", style: TextStyle(color: AppColors.greytextColor)))),
                            onTap: () {
                              setState(() {
                                page = 0;
                                filterAims(page);
                              });
                            },
                          ),
                        ),
                      ]
                    ),
                  ),
                  Expanded(child: SingleChildScrollView(child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        child: MyTreeView(key: UniqueKey(), roots: roots, applyColorChangibg: false, fillWidth: true, onTap: (id, type){
                          if(type=="m"){
                            BlocProvider.of<NavigationBloc>(context).clearHistory();
                            appVM.cachedImages.clear();
                            appVM.startMainsphereeditScreen();
                            BlocProvider.of<NavigationBloc>(context)
                                .add(NavigateToMainSphereEditScreenEvent());
                          }else if(type=="w"||type=="s"){
                            appVM.wishScreenState = null;
                            appVM.startWishScreen(id, 0, false);
                            BlocProvider.of<NavigationBloc>(context)
                                .add(NavigateToWishScreenEvent());
                          }else if(type=="a"){
                            appVM.getAim(id);
                            BlocProvider.of<NavigationBloc>(context)
                                .add(NavigateToAimEditScreenEvent(id));
                          }else if(type=="t"){
                            appVM.getTask(id);
                            BlocProvider.of<NavigationBloc>(context)
                                .add(NavigateToTaskEditScreenEvent(id));
                          }
                        },
                        onDoubleTap: (id, type){
                          onDoubleClick(id);
                        },),
                      )
                  );}))),
                  const SizedBox(height: 3),
                  !trashModeActive?ColorRoundedButton("Добавить желание", (){
                    if(appVM.mainScreenState!=null)appVM.startMainScreen(appVM.mainScreenState!.moon);
                    appVM.hint="Добавление ЖЕЛАНИЙ происходит из карты сферы. Определи нужную сферу и создай желание, поставь цели и выполняй задачи. Твои желания обязательно сбудутся";
                    BlocProvider.of<NavigationBloc>(context)
                        .add(NavigateToMainScreenEvent());
                  }):
                  ColorRoundedButton("Удалить", c: AppColors.buttonBackRed, (){
                    setState(() async {
                      trashModeActive=false;
                      for (var id in deleteQueue) {
                        final wish = await appVM.getSphereNow(id);
                        if(wish==null)return;
                        appVM.deleteSphereWish(id, wish.prevId, wish.nextId);
                        appVM.wishItems.removeWhere((element) => element.id==id);
                      }
                    });
                  }),
                  const SizedBox(height: 11),
                  !isPBActive?const SizedBox(height: 4,):const LinearCappedProgressIndicator(
                    backgroundColor: Colors.black26,
                    color: Colors.black,
                    cornerRadius: 0,
                  ),
                ],
              ),
            )
            ),
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
  filterAims(int type){
    setState(() {
      page==1?filteredWishList = allWishList.where((element) => element.isChecked).toList():
      page==2?filteredWishList = allWishList.where((element) => !element.isChecked).toList():
      page==3?filteredWishList = allWishList.where((element) => element.isActive).toList():filteredWishList = allWishList;
    });
  }

  onItemClick(int id) {
    appViewModel?.cachedImages.clear();
    appViewModel?.wishScreenState=null;
    appViewModel?.startWishScreen(id, 0, false);
    BlocProvider.of<NavigationBloc>(context)
        .add(NavigateToWishScreenEvent());
  }
  onDoubleClick(int id) async {
    final wish = await appViewModel?.getSphereNow(id);
    final parentWish = await appViewModel?.getSphereNow(id);
    if (wish == null|| parentWish==null) return;
    if ((!wish.isActive && !wish.isChecked) && ((appViewModel?.settings.wishActualizingMode==1&&appViewModel?.settings.sphereActualizingMode==1) || (parentWish.isActive))) { //активировать
      if (parentWish.isActive) {
        appViewModel?.activateSphereWish(id, true);
        setState(() {
          appViewModel?.wishItems
              .firstWhere((element) => element.id == id)
              .isActive = true;
        });
      }
    } else if (!wish.isChecked) { //выполнить
      appViewModel?.activateSphereWish(id, true);
      setState(() {
        appViewModel?.wishItems
            .firstWhere((element) => element.id == id)
            .isChecked = true;
      });
    } else { //удалить
      showDialog(context: context,
        builder: (BuildContext c) =>
            AlertDialog(
              contentPadding: EdgeInsets.zero,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(32.0))),
              title: const Text('Внимание', textAlign: TextAlign.center,),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Желание будет удалена", maxLines: 4,
                    textAlign: TextAlign.center,),
                  SizedBox(height: 4,),
                  Divider(color: AppColors.dividerGreyColor,),
                  SizedBox(height: 4,),
                  Text("Удалить?", style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),)
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, 'OK');
                    appViewModel?.deleteSphereWish(
                        id, wish.prevId, wish.nextId);
                    allWishList.removeWhere((element) => element.id == id);
                  },
                  child: const Text('Да'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, 'Cancel');
                  },
                  child: const Text('Нет'),
                ),
              ],
            ),
      );
    }
  }
}

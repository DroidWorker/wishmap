import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/common/aimitem_widget.dart';
import 'package:wishmap/interface_widgets/colorButton.dart';
import '../ViewModel.dart';
import '../common/bottombar.dart';
import '../data/models.dart';
import '../data/static.dart';
import '../dialog/bottom_sheet_action.dart';
import '../navigation/navigation_block.dart';
import '../res/colors.dart';

class AimsScreen extends StatefulWidget {
  const AimsScreen({super.key});

  @override
  _AimsScreenState createState() => _AimsScreenState();
}

class _AimsScreenState extends State<AimsScreen>{
  int page = 3;//false - Исполнено true - Все желания
  late List<AimItem> allAims;
  List<AimItem> filteredAimList = [];
  List<int> deleteQueue = [];

  late AppViewModel appViewModel;

  var isPBActive = false;
  var trashModeActive = false;

  @override
  Widget build(BuildContext context) {
    appViewModel = Provider.of<AppViewModel>(context);
    if(appViewModel.wishItems.isEmpty)appViewModel.startMyWishesScreen();
    return Consumer<AppViewModel>(
        builder: (context, appVM, child) {
          allAims = appVM.aimItems.where((item)=>!item.text.contains("HEADERSIMPLETASKHEADER")).toList();
          page==1?filteredAimList = allAims.where((element) => element.isChecked).toList():
          page==2?filteredAimList = allAims.where((element) => !element.isChecked).toList():
          page==3?filteredAimList = allAims.where((element) => element.isActive&&!element.isChecked).toList():filteredAimList = allAims;
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
                    const Text("Мои цели", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
                                  ), child: const Center(child: Text("Актуальные", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)))): const Center(child: Text("Актуальные", style: TextStyle(color: AppColors.greytextColor, fontSize: 11, fontWeight: FontWeight.w600))),
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
                                ), child: const Center(child: Text("Не достигнуты", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)))): const Center(child: Text("Не достигнуты", style: TextStyle(color: AppColors.greytextColor, fontSize: 11, fontWeight: FontWeight.w600))),
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
                                ), child: const Center(child: Text("Достигнуты", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)))): const Center(child: Text("Достигнуты", style: TextStyle(color: AppColors.greytextColor, fontSize: 11, fontWeight: FontWeight.w600))),
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
                                ), child: const Center(child: Text("Все", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)))): const Center(child: Text("Все", style: TextStyle(color: AppColors.greytextColor, fontSize: 11, fontWeight: FontWeight.w600))),
                            onTap: () {
                              setState(() {
                                page = 0;
                                filterAims(page);
                              });
                            },
                          ),
                        ),
                      ],)
                  ),
                  const SizedBox(height: 10,),
                  Expanded(child:
                  ListView.builder(
                      itemCount: filteredAimList.length,
                      itemBuilder: (context, index) {
                        final parent = appVM.wishItems.firstWhere((e) => e.id==filteredAimList[index].parentId, orElse: ()=>WishItem(id: -1, text: "Я", isChecked: true, isActive: true, isHidden: false)).text;
                        return AimItemWidget(ai: filteredAimList[index],
                            parent: parent,
                            onItemSelect: onItemSelect,
                            onDoubleClick: onDoubleClick,
                            outlined: deleteQueue.contains(filteredAimList[index].id));
                      }
                  ),),
                  const SizedBox(height: 3),
                  !trashModeActive?ColorRoundedButton("Добавить цель", (){
                    BlocProvider.of<NavigationBloc>(context).removeLastFromBS();
                    appViewModel.hint="Добавление ЦЕЛЕЙ происходит  из желания, а желания из сферы. Определяй сферу, создавай желания, ставь цели и выполняй задачи. Твои желания обязательно сбудутся";
                    appViewModel.mainCircles.clear();
                    if(appViewModel.mainScreenState!=null)appViewModel.startMainScreen(appViewModel.mainScreenState!.moon);
                    BlocProvider.of<NavigationBloc>(context)
                        .add(NavigateToMainScreenEvent());
                  }):
                  ColorRoundedButton("Удалить", c: AppColors.buttonBackRed, (){
                    setState(() {
                      trashModeActive=false;
                      for (var id in deleteQueue) {
                        final aim = appVM.aimItems.firstWhere((element) => element.id==id, orElse: ()=>AimItem(id: -1, parentId: -1, text: "", isChecked: true, isActive: true));
                        appVM.deleteAim(id, aim.parentId);
                        appVM.aimItems.removeWhere((element) => element.id==id);
                      }
                    });
                  }),
                  const SizedBox(height: 15),
                  /*!isPBActive?const SizedBox(height: 3):const LinearCappedProgressIndicator(
                    backgroundColor: Colors.black26,
                    color: Colors.black,
                    cornerRadius: 0,
                  ),*/
                ],
              ),
            ),),
            bottomNavigationBar: BottomBar(
              onAimsTap: (){

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

  filterAims(int type){
    setState(() {
      page==1?filteredAimList = allAims.where((element) => element.isChecked).toList():
      page==2?filteredAimList = allAims.where((element) => !element.isChecked).toList():
      page==3?filteredAimList = allAims.where((element) => element.isActive).toList():
      filteredAimList = allAims;
    });
  }
  onItemSelect(int id) async {
    if(!trashModeActive) {
      await appViewModel.getAim(id);
      BlocProvider.of<NavigationBloc>(context)
          .add(NavigateToAimEditScreenEvent(id));
    }else{
      setState(() {
        deleteQueue.contains(id)?deleteQueue.remove(id):deleteQueue.add(id);
      });
    }
  }
  onDoubleClick(int id) async {
    final aim = allAims.firstWhere((element) => element.id==id);
    if(!aim.isActive&&!aim.isChecked){//активировать
      final parentWish = await appViewModel.getSphereNow(aim.parentId);
      if(parentWish!=null&&parentWish.isActive){
        appViewModel.activateAim(id, true);
        setState(() {
          appViewModel.aimItems.firstWhere((element) => element.id==id).isActive=true;
        });
      }
    }else if(!aim.isChecked){//выполнить
      appViewModel.updateAimStatus(id, true);
      setState(() {
        appViewModel.aimItems.firstWhere((element) => element.id==id).isChecked=true;
      });
    }else{//удалить
      showModalBottomSheet<void>(
        backgroundColor: AppColors.backgroundColor,
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return ActionBS('Внимание', "Цель будет удалена. Удалить?", "Да", 'Нет',
              onOk: () {
                Navigator.pop(context, 'OK');
                appViewModel.deleteAim(id ,aim.parentId);
                allAims.removeWhere((element) => element.id==id);
              },
              onCancel: () { Navigator.pop(context, 'Cancel');
              });
        },
      );
    }
  }
}

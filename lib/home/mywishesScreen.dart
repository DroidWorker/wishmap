import 'package:capped_progress_indicator/capped_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/common/wishItem_widget.dart';
import '../ViewModel.dart';
import '../data/models.dart';
import '../navigation/navigation_block.dart';
import '../res/colors.dart';

class WishesScreen extends StatefulWidget {
  WishesScreen({super.key});

  @override
  _WishesScreenState createState() => _WishesScreenState();
}

class _WishesScreenState extends State<WishesScreen>{
  int page = 0;//2 - не исполнено 1 - Исполнено 0 - Все желания
  List<WishItem> allWishList = [];
  List<WishItem> filteredWishList = [];
  AppViewModel? appViewModel;

  var isPBActive = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppViewModel>(
        builder: (context, appVM, child) {
          appViewModel=appVM;
          allWishList = appVM.wishItems;
          page==1?filteredWishList = allWishList.where((element) => element.isChecked).toList():
          page==2?filteredWishList = allWishList.where((element) => !element.isChecked).toList():filteredWishList = allWishList;
          isPBActive=appVM.isinLoading;
          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: SafeArea(child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Column(
                children: [
                  Row(children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_left),
                      iconSize: 30,
                      onPressed: () {
                        BlocProvider.of<NavigationBloc>(context)
                            .add(NavigateToMainScreenEvent());
                      },
                    ),
                    const Spacer(),
                    const Text("Мои желания", style: TextStyle(fontSize: 18),),
                    const Spacer(),
                  ],
                  ),
                  const SizedBox(height: 20),
                  Row(children: [
                    GestureDetector(
                      child: Container(
                    height: 30,
                    child: page==0
                        ? const Text("Все желания",
                        style: TextStyle(decoration: TextDecoration.underline))
                        : const Text("Все желания"),
                  ),
                      onTap: () {
                        setState(() {
                          page = 0;
                          filterAims(page);
                        });
                      },
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      child: Container(
                      height: 30,
                        child: page==1
                            ? const Text("Исполнено",
                            style: TextStyle(decoration: TextDecoration.underline))
                            : const Text("Исполнено"),
                      ),
                      onTap: () {
                        setState(() {
                          page = 1;
                          filterAims(page);
                        });
                      },
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      child: Container(
                        height: 30,
                        child:page==2
                            ? const Text("не исполнено",
                            style: TextStyle(decoration: TextDecoration.underline))
                            : const Text("не исполнено"),
                      ),
                      onTap: () {
                        setState(() {
                          page = 2;
                          filterAims(page);
                        });
                      },
                    )
                  ],),
                  Expanded(child:
                  ListView.builder(
                      itemCount: filteredWishList.length,
                      itemBuilder: (context, index) {
                        return WishItemWidget(ti: filteredWishList[index],
                          onItemSelect: onItemClick,
                          onClick: onItemClick,
                          onDelete: onItemDelete,);
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
                        if(appVM.mainScreenState!=null)appVM.startMainScreen(appVM.mainScreenState!.moon);
                        BlocProvider.of<NavigationBloc>(context)
                            .add(NavigateToMainScreenEvent());
                      },
                      child: const Text("Добавить",
                          style: TextStyle(color: AppColors.greytextColor))
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
                              const Text("Цели", style:  TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black),)
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
                              const Text("Карта", style:  TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black),)
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
                              const Text("Желания", style:  TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black),)
                            ]
                        )
                        ),
                        ElevatedButton(
                            onPressed: () {
                              appVM.getDiary();
                              BlocProvider.of<NavigationBloc>(context)
                                  .add(NavigateToDiaryScreenEvent());
                            },
                            style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: Colors.transparent,),                                   child: Column(
                            children: [
                              Image.asset('assets/icons/notepad2725914.png', height: 30, width: 30),
                              const Text("Дневник", style:  TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black),)
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
  filterAims(int type){
    setState(() {
      page==1?filteredWishList = allWishList.where((element) => element.isChecked).toList():
      page==2?filteredWishList = allWishList.where((element) => !element.isChecked).toList():filteredWishList = allWishList;
    });
  }

  onItemClick(int id) {
    appViewModel?.cachedImages.clear();
    appViewModel?.wishScreenState=null;
    appViewModel?.startWishScreen(id, 0);
    BlocProvider.of<NavigationBloc>(context)
        .add(NavigateToWishScreenEvent());
  }
  onItemDelete(int id){
    setState(() {
      filteredWishList.removeWhere((element) => element.id==id);
    });
    appViewModel?.deleteSphereWish(id);
  }
}

import 'package:capped_progress_indicator/capped_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/navigation/navigation_block.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wishmap/common/moon_widget.dart';
import 'package:wishmap/common/solarsystem.dart';
import 'package:wishmap/res/colors.dart';
import 'package:wishmap/data/models.dart';

import '../ViewModel.dart';

class MainScreen extends StatefulWidget {
  MainScreen({super.key});

  final GlobalKey columnKey = GlobalKey();

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>{
  bool isPauseIcon = true;
  @override
  Widget build(BuildContext context) {
    return Consumer<AppViewModel>(
        builder: (context, appVM, child){
          return Scaffold(
              backgroundColor: AppColors.backgroundColor,
              body: SafeArea(child:Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.menu),
                              iconSize: 30,
                              onPressed: () {
                                BlocProvider.of<NavigationBloc>(context)
                                    .add(NavigateToProfileScreenEvent());
                              },
                            )
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                                flex: 4,
                                child: GestureDetector(
                                  onTap: (){
                                    appVM.mainScreenState = null;
                                    appVM.mainCircles.clear();
                                    appVM.currentCircles.clear();
                                    BlocProvider.of<NavigationBloc>(context)
                                        .add(NavigateToCardsScreenEvent());
                                  },
                                  child: Column(
                                    children: [
                                      MoonWidget(fillPercentage: appVM.mainScreenState?.moon.filling??0.01, moonSize: (MediaQuery.of(context).size.height-MediaQuery.of(context).size.width)*0.3,),
                                      Text(appVM.mainScreenState?.moon.date??"")
                                    ],
                                  ),
                                )
                            ),
                            const Expanded(
                                flex: 6,
                                child:
                                Text("подсказка")
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        Expanded(child:
                        LayoutBuilder(
                          builder: (BuildContext context, BoxConstraints constraints) {
                            return const SizedBox();
                          },
                        )
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Image.asset('assets/icons/prev.png'),
                              iconSize: 35,
                              onPressed: () {},
                            ),
                            const SizedBox(width: 20),
                            IconButton(
                              icon: isPauseIcon?Image.asset('assets/icons/plau.png'):Image.asset('assets/icons/pause.png'),
                              iconSize: 35,
                              onPressed: () {
                                setState((){
                                  isPauseIcon=!isPauseIcon;
                                });

                              },
                            ),
                            const SizedBox(width: 15),
                            IconButton(
                              icon: Image.asset('assets/icons/next.png'),
                              iconSize: 35,
                              onPressed: () {},
                            )
                          ],),
                        const SizedBox(height: 10),
                        !appVM.isinLoading?const Divider(
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
                  ),
                  CircularDraggableCircles(circles: appVM.currentCircles, size: MediaQuery.of(context).size.width-20, center: Pair(key: MediaQuery.of(context).size.width/2, value: MediaQuery.of(context).size.height*0.50)),
                ],))
          );
        }
    );
  }
}

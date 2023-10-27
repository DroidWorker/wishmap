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
                                    BlocProvider.of<NavigationBloc>(context)
                                        .add(NavigateToCardsScreenEvent());
                                  },
                                  child: Column(
                                    children: [
                                      MoonWidget(fillPercentage: appVM.mainScreenState?.moon.filling??0.01),
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
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.skip_previous_outlined),
                              iconSize: 50,
                              onPressed: () {},
                            ),
                            const SizedBox(width: 20),
                            IconButton(
                              icon: isPauseIcon?const Icon(Icons.pause_circle_outline):const Icon(Icons.play_circle_outline),
                              iconSize: 50,
                              onPressed: () {
                                setState((){
                                  isPauseIcon=!isPauseIcon;
                                });

                              },
                            ),
                            const SizedBox(width: 20),
                            IconButton(
                              icon: const Icon(Icons.skip_next_outlined),
                              iconSize: 50,
                              onPressed: () {},
                            )
                          ],),
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: Image.asset('assets/icons/checklist2665651.png'),
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
                                icon: Image.asset('assets/icons/notelove1648387.png'),
                                iconSize: 30,
                                onPressed: () {
                                  appVM.startMyWishesScreen();
                                  BlocProvider.of<NavigationBloc>(context)
                                      .add(NavigateToWishesScreenEvent());
                                },
                              ),
                              IconButton(
                                icon: Image.asset('assets/icons/notepad2725914.png'),
                                iconSize: 30,
                                onPressed: () {

                                },
                              )
                            ],
                          ),)
                      ],
                    ),
                  ),
                  CircularDraggableCircles(circles: appVM.currentCircles, size: MediaQuery.of(context).size.height-350<MediaQuery.of(context).size.width-20? MediaQuery.of(context).size.height-350 : MediaQuery.of(context).size.width-20, center: Pair(key: MediaQuery.of(context).size.width/2, value: MediaQuery.of(context).size.height*0.50)),
                ],))
          );
        }
    );
  }
}

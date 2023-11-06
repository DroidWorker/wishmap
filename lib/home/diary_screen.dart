import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../ViewModel.dart';
import '../navigation/navigation_block.dart';
import '../res/colors.dart';

class DiaryScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Consumer<AppViewModel>(
        builder: (context, appVM, child) {
          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                            ),
                            const Spacer(),
                            const Text("Мой дневник", style: TextStyle(fontSize: 18),),
                            const Spacer(),
                          ],
                        ),
                        const SizedBox(height: 7,),
                        const Text("Твое счастье в твоих руках", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                        const SizedBox(height: 5,),
                        const Text("Просто попробуй вести свой дневник, ты увидишь, это потрясающе"),

                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.fieldFillColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10), // <-- Radius
                              ),
                            ),
                            onPressed: () {
                              if(appVM.mainScreenState!=null)appVM.startMainScreen(appVM.mainScreenState!.moon);
                              BlocProvider.of<NavigationBloc>(context).removeLastFromBS();
                              BlocProvider.of<NavigationBloc>(context)
                                  .add(NavigateToMainScreenEvent());
                            },
                            child: const Text("Добавить",
                              style: TextStyle(color: AppColors.greytextColor),)
                        ),
                      ],
                    ),
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
          );
  });
  }
}
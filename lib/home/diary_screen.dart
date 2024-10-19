import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../ViewModel.dart';
import '../common/bottombar.dart';
import '../common/cardWidget.dart';
import '../data/models.dart';
import '../data/static.dart';
import '../navigation/navigation_block.dart';
import '../res/colors.dart';

class DiaryScreen extends StatefulWidget {

  @override
  DiaryScreenState createState()=>DiaryScreenState();
}
  class DiaryScreenState extends State<DiaryScreen>{
  @override
  Widget build(BuildContext context){
    List<CardData> cardData = [];
    return Consumer<AppViewModel>(
        builder: (context, appVM, child) {
          cardData = appVM.diaryItems.reversed.toList();
          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: SafeArea(
              child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  style: const ButtonStyle(
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap, // the '2023' part
                                  ),
                                  icon: const Icon(Icons.keyboard_arrow_left, size: 28, color: AppColors.gradientStart),
                                  onPressed: () {
                                    appVM.backPressedCount++;
                                    if (appVM.backPressedCount ==
                                        appVM.settings.quoteupdateFreq) {
                                      appVM.backPressedCount = 0;
                                      appVM.hint =
                                      quoteBack[Random().nextInt(367)];
                                    }
                                    BlocProvider.of<NavigationBloc>(context)
                                        .clearHistory();
                                    BlocProvider.of<NavigationBloc>(context)
                                        .add(NavigateToMainScreenEvent());
                                  }
                                ),
                                const Text("Мой дневник", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                const SizedBox(width: 40, height: 40,)
                              ],
                            ),
                            Flexible(
                              child: GridView.builder(
                                padding: const EdgeInsets.all(16),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 4.0,
                                  mainAxisSpacing: 4.0,
                                ),
                                itemCount: cardData.length,
                                itemBuilder: (context, index) {
                                  return SizedBox(
                                    height: 150,
                                    child: GestureDetector(
                                      onTap: (){
                                        appVM.articles.clear();
                                        appVM.getDiaryArticles(cardData[index].id);
                                        BlocProvider.of<NavigationBloc>(context)
                                            .add(NavigateToDiaryEditScreenEvent(cardData[index].id));
                                      },
                                      child: CardWidget(data: cardData[index]),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                    )
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.transparent,
              elevation: 0,
              onPressed: (){
                final newid = cardData.first.id+1;
                appVM.articles.clear();
                appVM.addDiary(CardData(id: newid, emoji: "➕", title: "заголовок", description: "описание", text: "текст", color: Colors.deepPurple));
                BlocProvider.of<NavigationBloc>(context)
                    .add(NavigateToDiaryEditScreenEvent(newid));
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd])
                ),
                child: const Icon(
                  Icons.add,
                  size: 30,
                  color: Colors.white,
                ),
              ),
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
                BlocProvider.of<NavigationBloc>(context)
                    .add(NavigateToMainScreenEvent());
              },
              onWishesTap: (){
                appVM.startMyWishesScreen();
                BlocProvider.of<NavigationBloc>(context)
                    .add(NavigateToWishesScreenEvent());
              },
              onDiaryTap: (){},
            ),
          );
  });
  }
}
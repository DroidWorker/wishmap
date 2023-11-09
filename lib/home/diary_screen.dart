import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:provider/provider.dart';

import '../ViewModel.dart';
import '../common/cardWidget.dart';
import '../data/models.dart';
import '../navigation/navigation_block.dart';
import '../res/colors.dart';

class DiaryScreen extends StatefulWidget {

  @override
  DiaryScreenState createState()=>DiaryScreenState();
}
  class DiaryScreenState extends State<DiaryScreen>{
    int selectedPage = 0;
    final PageController _pageController = PageController();
  @override
  Widget build(BuildContext context){
    List<CardData> cardData = [];
    return Consumer<AppViewModel>(
        builder: (context, appVM, child) {
          cardData = appVM.diaryItems;
          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: SafeArea(
              child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SizedBox(
                      height: constraints.maxHeight,
                        child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      const SizedBox(width: 30)
                                    ],
                                  ),
                                  const SizedBox(height: 7,),
                                  const Text("Твое счастье в твоих руках", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                                  const SizedBox(height: 5,),
                                  const Text("Просто попробуй вести свой дневник, ты увидишь, это потрясающе", textAlign: TextAlign.center,),
                                  SizedBox(
                                    height: constraints.maxHeight-220,
                                    child: PageView.builder(
                                      controller: _pageController,
                                      onPageChanged: (index){setState(() {
                                        selectedPage = index;
                                      });},
                                      itemCount: (cardData.length / 6).ceil(),
                                      itemBuilder: (context, index) {
                                      final start = index * 6;
                                      final end = (index + 1) * 6;
                                      final sublist = cardData.sublist(start, end > cardData.length ? cardData.length : end);

                                      return GridView.builder(
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 4.0,
                                      mainAxisSpacing: 4.0,
                                      ),
                                      itemCount: sublist.length,
                                      itemBuilder: (context, index) {
                                      return SizedBox(
                                        height: (constraints.maxHeight-270)/3,
                                        child: GestureDetector(
                                          onTap: (){
                                            BlocProvider.of<NavigationBloc>(context)
                                                .add(NavigateToDiaryEditScreenEvent(sublist[index].id));
                                          },
                                          child: CardWidget(data: sublist[index]),
                                        ),
                                      );
                                      },
                                      );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 5,),
                            SizedBox(height: 25,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.fieldFillColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10), // <-- Radius
                                  ),
                                ),
                                onPressed: () {
                                  final newid = cardData.last.id+1;
                                  appVM.addDiary(CardData(id: newid, emoji: "➕", title: "заголовок", description: "описание", text: "текст", color: Colors.deepPurple));
                                  BlocProvider.of<NavigationBloc>(context)
                                      .add(NavigateToDiaryEditScreenEvent(newid));
                                },
                                child: const Text("Добавить",
                                  style: TextStyle(color: AppColors.greytextColor),)
                            ),),
                                  const SizedBox(height: 5,),
                                  PageViewDotIndicator(
                                      currentItem: selectedPage,
                                      count: (cardData.length/6).ceil(),
                                      unselectedColor: Colors.black45,
                                      selectedColor: Colors.black,
                                      duration: const Duration(milliseconds: 200),
                                      onItemClicked: (index) {
                                        _pageController.animateToPage(
                                          index,
                                          duration: const Duration(milliseconds: 300), // Длительность анимации (по желанию)
                                          curve: Curves.ease, // Эффект анимации (по желанию)
                                        );
                                      }
                                  ),
                            const Divider(
                              height: 2,
                              thickness: 1,
                              indent: 0,
                              endIndent: 0,
                              color: Colors.black,
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(5, 3, 5, 0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
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
                    ));
            })
            ),
          );
  });
  }
}
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/common/bottombar.dart';
import 'package:wishmap/data/static.dart';
import 'package:wishmap/navigation/navigation_block.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wishmap/common/solarsystem_redesign.dart';
import 'package:wishmap/provider/audio_manager.dart';
import 'package:wishmap/provider/file_loader.dart';
import 'package:wishmap/res/colors.dart';
import 'package:wishmap/data/models.dart';

import '../ViewModel.dart';
import '../common/moon_widget.dart';
import '../common/selector_text_widget.dart';
import '../dialog/bottom_sheet_action.dart';

class MainScreen extends StatefulWidget {
  MainScreen({super.key});

  final GlobalKey columnKey = GlobalKey();

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>{
  ReceivePort _port = ReceivePort();
  AppViewModel? vm;

  bool isPauseIcon = !AudioPlayerManager().state();
  bool clearData = true;
  int hintId = 0;

  int ppPressCount = 0;
  int pnPressCount = 0;

  final GlobalKey<CircularDraggableCirclesState> _CDWidgetKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppViewModel>(
        builder: (context, appVM, child){
          vm=appVM;
          final hintStates = appVM.getHintStates();
          if(hintStates["firstOpenSphere"]==1&&appVM.mainScreenState!.allCircles.first.isActive){
            appVM.hint="Создай свою карту желаний. Сначала заполни область своего “Я”. Потом последовательно заполни все сферы, и лишь потом приступай к синтезу желаний.";
            appVM.setHintState("firstOpenSphere", 0);
          }else if(appVM.mainScreenState!=null&&appVM.mainScreenState!.allCircles.where((e) => e.isActive).isEmpty){
            appVM.hint = textIActualize[Random().nextInt(35)];
          }
          else {
            final sphereid = appVM.mainCircles.lastOrNull?.id??0;
            final sphere = appVM.mainScreenState?.allCircles.where((element) => element.id==sphereid).first ?? CircleData(id: 0, prevId: 0, nextId: 0, text: '', color: Colors.transparent, parenId: 0);
            if(appVM!=null&&appVM.hint=="") {
              if (sphere.shuffle && hintId != sphereid) {
                final affirmations = sphere.affirmation.split("|");
                if (sphere.lastShuffle.split("|")[1] != DateTime
                    .now()
                    .weekday
                    .toString()) {
                  sphere.lastShuffle = "${affirmations[Random().nextInt(
                      affirmations.length)]}|${DateTime
                      .now()
                      .weekday
                      .toString()}";
                  appVM.hint =
                  sphere.lastShuffle.split("|")[0];
                  appVM.saveShuffle(sphere.id, true, sphere.lastShuffle);
                }
              } else {
                if(sphere.lastShuffle=="|")
                {
                  appVM.saveShuffle(sphere.id, false, sphere.affirmation.split("|")[0]);
                  sphere.lastShuffle="${sphere.affirmation.split("|")[0]}|";
                }
                appVM.hint = sphere.lastShuffle.split("|")[0];
              }
              hintId = sphereid;
            }
          }
          //calculate topmessagebox
          final centerY = MediaQuery.of(context).size.height*0.50;
          final SSSize = MediaQuery.of(context).size.width-20;
          final maxHeight = centerY-SSSize/2-50;

          SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
            if(!appVM.alarmChecked&&await appVM.alarmsExists){
              showModalBottomSheet<bool>(
                backgroundColor: AppColors.backgroundColor,
                context: context,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return ActionBS('В профиле есть несохраненные будильники', "Перейти в настройки?", "Да", 'Нет',
                      onOk: () async {
                        appVM.getAlarms();
                        BlocProvider.of<NavigationBloc>(context)
                            .add(NavigateToAlarmScreenEvent());
                        Navigator.pop(context, true);
                      },
                      onCancel: () {
                        Navigator.pop(context, true);
                      }
                  );
                },
              );
            }
          });
          Widget w = Scaffold(
              backgroundColor: AppColors.backgroundColor,
              body: SafeArea(child:Stack(
                children: [
                  Center(
                    child: Column(
                      children: [
                        Expanded(child:
                        LayoutBuilder(
                          builder: (BuildContext context, BoxConstraints constraints) {
                            return const SizedBox();
                          },
                        )
                        ),
                        const SizedBox(height: 30),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.all(Radius.circular(25)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 3,
                                blurRadius: 7, // changes position of shadow
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: SvgPicture.asset('assets/icons/prev.svg', height: 20, width: 20),
                                onPressed: () async {
                                  final audioUrl = await appVM.getAudio();
                                  if(audioUrl.isEmpty)return;
                                  if(audioUrl.length>1){
                                    final num = appVM.audioNum;
                                    appVM.audioNum = num-1<0?audioUrl.length-1:num-1;
                                    AudioPlayerManager().playLocal(audioUrl.keys.toList()[appVM.audioNum]);
                                  }
                                    setState(() {
                                      isPauseIcon=false;
                                      appVM.hint = audioUrl.keys.toList()[appVM.audioNum];
                                    });
                                },
                              ),
                              const SizedBox(width: 5),
                              IconButton(
                                icon: isPauseIcon?Image.asset('assets/icons/plau.png', height: 35, width: 35):SvgPicture.asset('assets/icons/pause.svg', height: 35, width: 35),
                                onPressed: () async {
                                  final audioUrl = await appVM.getAudio();
                                  if(audioUrl.isEmpty)return;
                                  if(!isPauseIcon){
                                    AudioPlayerManager().pause();
                                  }else {
                                    AudioPlayerManager().playLocal(audioUrl.keys.toList()[appVM.audioNum]);
                                  }
                                  setState((){
                                    ppPressCount++;
                                    if(ppPressCount==5){
                                      ppPressCount=0;
                                      if(!isPauseIcon){
                                          appVM.hint = quotesQuite[Random().nextInt(55)];
                                      }
                                    }else{
                                        appVM.hint = audioUrl.keys.toList()[appVM.audioNum];
                                    }
                                    isPauseIcon=!isPauseIcon;
                                    clearData=false;
                                  });
                                },
                              ),
                              const SizedBox(width: 5),
                              IconButton(
                                icon: SvgPicture.asset('assets/icons/next.svg', height: 20, width: 20),
                                onPressed: () async {
                                  final audioUrl = await appVM.getAudio();
                                  if(audioUrl.isEmpty)return;
                                  if(audioUrl.length>1){
                                    final num = appVM.audioNum;
                                    appVM.audioNum = num+1>audioUrl.length-1?0:num+1;
                                    AudioPlayerManager().playLocal(audioUrl.keys.toList()[appVM.audioNum]);
                                    setState(() {
                                      isPauseIcon=false;
                                      appVM.hint = audioUrl.keys.toList()[appVM.audioNum];print("aaaaaaaaaaaaaaaaa${appVM.hint}");
                                    });
                                  }
                                },
                              )
                            ],),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    height: 800,
                    child: CircularDraggableCircles(key: _CDWidgetKey,circles: appVM.currentCircles, size: MediaQuery.of(context).size.width-20, center: Pair(key: MediaQuery.of(context).size.width/2, value: MediaQuery.of(context).size.height*0.53), clearData: clearData,),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 16.0, 8, 16),
                    child: SizedBox(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(width: 16),
                          Expanded(
                              flex: 5,
                              child: SelectorTextWidget(appViewModel: appVM, maxHeight: maxHeight,)//Text("${appVM.hint}")
                          ),
                          const SizedBox(width: 32),
                          Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  InkWell(child:IconButton(
                                    style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all(Colors.white),
                                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8.0),
                                            )
                                        )),
                                    icon: const Icon(Icons.menu, size: 30,),
                                    onPressed: () {
                                      appVM.mainCircles.clear();
                                      BlocProvider.of<NavigationBloc>(context)
                                          .add(NavigateToProfileScreenEvent());
                                    },
                                  ),
                                    onLongPress: (){
                                      appVM.createReport();
                                      appVM.addError("Bug Report");
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  InkWell(
                                    onTap: (){
                                      appVM.mainScreenState = null;
                                      appVM.mainCircles.clear();
                                      appVM.currentCircles.clear();
                                      BlocProvider.of<NavigationBloc>(context)
                                          .add(NavigateToCardsScreenEvent());
                                    },
                                    child: Container(
                                      height: (MediaQuery.of(context).size.height-MediaQuery.of(context).size.width)*0.1,
                                      width: (MediaQuery.of(context).size.height-MediaQuery.of(context).size.width)*0.1,
                                      child: MoonWidget(
                                        date: parseDateString(appVM.mainScreenState?.moon.date??"01.01.2020")??DateTime.now(),
                                        size: (MediaQuery.of(context).size.height-MediaQuery.of(context).size.width)*0.1,
                                        resolution: ((MediaQuery.of(context).size.height-MediaQuery.of(context).size.width)*0.1)*100,
                                      ),
                                    ),
                                  )
                                ],
                              )
                          ),
                          const SizedBox(width: 16)
                        ],
                      ),
                    ),
                  ),
                ],)),
              bottomNavigationBar: BottomBar(
                onAimsTap: (){
                  _CDWidgetKey.currentState?.stateSnapshot();
                  appVM.startMyAimsScreen();
                  BlocProvider.of<NavigationBloc>(context)
                      .add(NavigateToAimsScreenEvent());
                },
                onTasksTap: (){
                  _CDWidgetKey.currentState?.stateSnapshot();
                  appVM.startMyTasksScreen();
                  BlocProvider.of<NavigationBloc>(context)
                      .add(NavigateToTasksScreenEvent());
                },
                onMapTap: (){
                  if(appVM.mainScreenState!=null){
                    appVM.mainCircles.clear();
                    appVM.currentCircles.clear();
                    appVM.startMainScreen(appVM.mainScreenState!.moon);
                    setState(() {});
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
                },
                onWishesTap: (){
                  _CDWidgetKey.currentState?.stateSnapshot();
                  appVM.startMyWishesScreen();
                  BlocProvider.of<NavigationBloc>(context)
                      .add(NavigateToWishesScreenEvent());
                },
                onDiaryTap: (){
                  appVM.getDiary();
                  _CDWidgetKey.currentState?.stateSnapshot();
                  BlocProvider.of<NavigationBloc>(context)
                      .add(NavigateToDiaryScreenEvent());
                },
              ),
          );
          clearData=true;
          return w;
        }
    );
  }
  DateTime? parseDateString(String dateString) {
    List<String> parts = dateString.split('.');
    if (parts.length == 3) {
      int? day = int.tryParse(parts[0]);
      int? month = int.tryParse(parts[1]);
      int? year = int.tryParse(parts[2]);

      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }

    // Вернуть null в случае некорректного формата строки
    return null;
  }
}
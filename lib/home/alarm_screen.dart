import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/common/reminder_item.dart';
import 'package:wishmap/data/models.dart';

import '../ViewModel.dart';
import '../common/bottombar.dart';
import '../interface_widgets/colorButton.dart';
import '../navigation/navigation_block.dart';
import '../res/colors.dart';

class AlarmScreen extends StatefulWidget{
  @override
  AlarmScreenState createState() => AlarmScreenState();
}

class AlarmScreenState extends State<AlarmScreen>{
  bool deleteMode = false;

  List<Alarm> alarms = [];
  @override
  Widget build(BuildContext context) {
    return Consumer<AppViewModel>(
        builder: (context, appVM, child) {
          alarms = appVM.alarms;
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
                              BlocProvider.of<NavigationBloc>(context).handleBackPress();
                            }
                        ),
                        const Text("Будильник", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                        deleteMode?IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          style: TextButton.styleFrom(
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap
                          ),
                          onPressed: () async {
                            setState(() {
                              deleteMode = !deleteMode;
                            });
                          },
                          icon: SvgPicture.asset("assets/icons/trash.svg", width: 28, height: 28),
                        ):const SizedBox(width: 40, height: 40,)
                      ],
                    ),
                    alarms.isEmpty?//noalarms
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Spacer(),
                              Image.asset('assets/icons/alarm.png', fit: BoxFit.fitWidth,),
                              const SizedBox(height: 24),
                              const Text("Пока будильников нет", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                              const Text("Вы можете добавить будильник по кнопке ниже"),
                              const Spacer(flex: 2),
                              ColorRoundedButton("Добавить будильник", (){
                                BlocProvider.of<NavigationBloc>(context)
                                    .add(NavigateToAlarmSettingsScreenEvent(0));
                              }),
                              const SizedBox(height: 24)
                            ],
                          ),
                        ),
                      )
                    :Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                  itemCount: alarms.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return ReminderItem(alarms[index]);
                                  }
                              ),
                            ),
                            deleteMode?ColorRoundedButton("Удалить", (){
                      
                              setState(() {
                                deleteMode = false;
                              });
                            }):FloatingActionButton(
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              onPressed: (){
                                BlocProvider.of<NavigationBloc>(context)
                                    .add(NavigateToAlarmSettingsScreenEvent(alarms.length));
                              },
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white
                                ),
                                child: const Icon(
                                  Icons.add,
                                  size: 30,
                                  color: AppColors.gradientEnd,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
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
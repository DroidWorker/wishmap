import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/common/reminder_item.dart';
import 'package:wishmap/data/models.dart';
import 'package:wishmap/services/reminder_service.dart';

import '../ViewModel.dart';
import '../common/bottombar.dart';
import '../dialog/bottom_sheet_notify.dart';
import '../interface_widgets/colorButton.dart';
import '../navigation/navigation_block.dart';
import '../res/colors.dart';

class AlarmScreen extends StatefulWidget{
  @override
  AlarmScreenState createState() => AlarmScreenState();
}

class AlarmScreenState extends State<AlarmScreen>{
  bool deleteMode = false;
  List<int> deleteQueue= [];

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
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
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
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            style: TextButton.styleFrom(
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap
                            ),
                            onPressed: () async {
                              setState(() {
                                deleteMode = !deleteMode;
                                deleteQueue.clear();
                              });
                            },
                            icon: SvgPicture.asset("assets/icons/trash.svg", width: 28, height: 28),
                          )
                        ],
                      ),
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
                                    .add(NavigateToAlarmSettingsScreenEvent(1));
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
                                    return ReminderItem(alarms[index], outlined: deleteQueue.contains(index),
                                    onTap: (id){
                                      if(deleteMode){
                                        setState(() {
                                          if(deleteQueue.contains(index)){deleteQueue.remove(index);}else{deleteQueue.add(index);}
                                        });
                                      }else{
                                        BlocProvider.of<NavigationBloc>(context)
                                            .add(NavigateToAlarmSettingsScreenEvent(alarms[index].id));
                                      }
                                    },
                                    onChangeState: (id, state) async {
                                      final alarm = (alarms.firstWhere((e)=>e.id==id)..remindEnabled = state);
                                      if(state){
                                        if(alarm.remindDays.isNotEmpty){
                                          final dayOffset = getDayOffsetToClosest(alarm.remindDays.map((e)=> int.parse(e)).toList(), alarm.dateTime.weekday);
                                          alarm.dateTime = alarm.dateTime.add(Duration(days: dayOffset));
                                        }else {
                                          if(alarm.dateTime.isBefore(DateTime.now())){
                                            alarm.dateTime = alarm.dateTime.copyWith(day: DateTime.now().day);
                                            if(alarm.dateTime.isBefore(DateTime.now())){
                                              alarm.dateTime = alarm.dateTime.add(const Duration(days: 1));
                                            }
                                          }
                                        }
                                        final notifId = await setAlarm(alarm, false);
                                        if(notifId.isEmpty){
                                          showModalBottomSheet<void>(
                                            backgroundColor: AppColors.backgroundColor,
                                            context: context,
                                            isScrollControlled: true,
                                            builder: (BuildContext context) {
                                              return NotifyBS('Будильник не установлен!', "", 'OK',
                                                  onOk: () => Navigator.pop(context));
                                            },
                                          );
                                        }else{
                                          alarm.notificationIds=notifId;
                                        }
                                      }else{
                                        final notifIds = alarm.notificationIds;
                                        if(notifIds.isEmpty)return;
                                        cancelAlarmManager(notifIds.first);
                                      }
                                      appVM.updateAlarm(alarm);
                                    },
                                    );
                                  }
                              ),
                            ),
                            deleteMode?ColorRoundedButton("Удалить", (){
                              for (var e in deleteQueue) {
                                appVM.deleteAlarm(alarms[e].id);
                              }
                              deleteQueue.clear();
                              setState(() {
                                deleteMode = false;
                              });
                            }):FloatingActionButton(
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              onPressed: (){
                                final id = (alarms.lastOrNull?.id??0)+1;
                                BlocProvider.of<NavigationBloc>(context)
                                    .add(NavigateToAlarmSettingsScreenEvent(id));
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
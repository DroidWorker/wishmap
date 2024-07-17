import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:wishmap/data/models.dart';
import 'package:wishmap/dialog/bottom_sheet_repeat.dart';
import 'package:wishmap/services/reminder_service.dart';

import '../ViewModel.dart';
import '../common/bottombar.dart';
import '../common/switch_widget.dart';
import '../import_extension/custom_string_picker.dart';
import '../navigation/navigation_block.dart';
import '../res/colors.dart';

class AlarmSettingScreen extends StatefulWidget{
  final int alarmId;

  AlarmSettingScreen(this.alarmId);
  @override
  AlarmSettingScreenState createState() => AlarmSettingScreenState();
}

class AlarmSettingScreenState extends State<AlarmSettingScreen>{
  TextEditingController textEditingController = TextEditingController();
  DateTime selectedDatetime = DateTime.now();

  int settingScreen = 0;//0-default 1-otlojit 2-disable
  String daysString = "pn-vs";
  String setdownText = "5 мин., 3 раза";
  double _volume = 0;

  late Alarm alarm;

  @override
  void initState() {
    alarm = Alarm(widget.alarmId, -1, selectedDatetime, [], '', true, "");
    textEditingController.addListener((){
      alarm.text = textEditingController.text;
    });
    VolumeController().listener((v) {
      setState(() => _volume = v);
    });

    VolumeController().getVolume().then((v) => _volume = v);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppViewModel>(
        builder: (context, appVM, child) {
          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: SafeArea(
                child: Column(
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
                            onPressed: () async {
                              if(alarm.music.isEmpty) {
                                final path = await getAlarmSoundUri();
                                if(path!=null) alarm.music = path;
                                return;
                              }
                              if(alarm.remindDays.isNotEmpty){
                                setAlarm(alarm, true);
                              }else{
                                setAlarm(alarm, false);
                              }
                              BlocProvider.of<NavigationBloc>(context).handleBackPress();
                            }
                        ),
                        const Text("Добавить будильник", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                        const SizedBox(width: 40, height: 40,)
                      ],
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                  controller: textEditingController,
                                  style: const TextStyle(color: Colors.black), // Черный текст ввода
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 19),
                                    filled: true,
                                    fillColor: Colors.white,
                                    hintText: 'Введите название',
                                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(
                                        width: 0,
                                        style: BorderStyle.none,
                                      ),
                                    ),
                                  )
                              ),
                              const SizedBox(height: 24),
                              const Text("Выберите время:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  StringPicker(itemWidth: 70, minValue: 0, maxValue: 59, value: selectedDatetime.hour, onChanged: (v){
                                    selectedDatetime = selectedDatetime.copyWith(hour: v);
                                    alarm.dateTime = selectedDatetime;
                                  }),
                                  const Text(":", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                  StringPicker(itemWidth: 70, minValue: 0, maxValue: 59, value: selectedDatetime.minute, onChanged: (v){
                                    selectedDatetime = selectedDatetime.copyWith(minute: v);
                                    alarm.dateTime = selectedDatetime;
                                  }),
                                ],
                              ),
                              const Text("Миссия (Отключить будильник)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),
                              const SizedBox(height: 16),
                              Row(

                                children: [
                                  Container(height: 70, width: 70, color: Colors.blue,)
                                ],
                              ),
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.grey)
                                ),
                                child: Column(
                                  children: [
                                    InkWell(
                                      onTap: (){
                                        showModalBottomSheet<void>(
                                          backgroundColor: AppColors.backgroundColor,
                                          context: context,
                                          isScrollControlled: true,
                                          builder: (BuildContext context) {
                                            return RepeatBS((repaetDays, string){
                                              setState(() {
                                                alarm.remindDays = repaetDays;
                                                daysString = string;
                                              });
                                            }, []);
                                          },
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          const Text("Повторить"),
                                          const Spacer(),
                                          Text(daysString),
                                          const Icon(Icons.arrow_forward_ios)
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    InkWell(
                                      onTap: () async {
                                        final path = await getAlarmSoundUri();
                                        if(path!=null)alarm.music = path;
                                      },
                                      child: Row(
                                        children: [
                                          const Text("Сигнал напоминания"),
                                          const Spacer(),
                                          Text(alarm.music.isEmpty?"не выбрано":alarm.music.split("/").last),
                                          const Icon(Icons.arrow_forward_ios)
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Icon(Icons.volume_up_rounded),
                                        Expanded(
                                          child: Slider(value: _volume, onChanged: (v){
                                            _volume = v;
                                            VolumeController().setVolume(v);
                                            setState(() {});
                                          }),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Text("Вибрация во время звонка"),
                                        const Spacer(),
                                        MySwitch(value: false, onChanged: (v){
                                          //reminder.vibration = v;
                                        },)
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.grey)
                                  ),
                                  child: Row(
                                    children: [
                                      const Text("Отложить"),
                                      const Spacer(),
                                      Text(setdownText),
                                      const Icon(Icons.arrow_forward_ios)
                                    ],
                                  )
                              )
                            ],
                          ),
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
  Future<String?> getAlarmSoundUri() async {
    try {
      String? filePath = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      ).then((result) => result?.files.single.path);

      if (filePath != null) {
        print('Selected file path: $filePath');
        // Здесь можно использовать filePath для дальнейшей обработки
        return filePath;
      } else {
        print('File picking canceled');
        return null;
      }
    } catch (e) {
      print('Error getting alarm sound URI: $e');
      return null;
    }
  }
}
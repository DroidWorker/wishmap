import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lecle_volume_flutter/lecle_volume_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/common/snoozeRepeatsSettings.dart';
import 'package:wishmap/data/models.dart';
import 'package:wishmap/data/static.dart';
import 'package:wishmap/dialog/bottom_sheet_repeat.dart';
import 'package:wishmap/home/Aalarm_settings_off_screen.dart';
import 'package:wishmap/home/snooze_settings_screen.dart';
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
  String setdownText = "";
  int _volume = 1;
  int _maxVol = 1;

  late Alarm alarm;
  bool firstLaunch = true;
  bool shouldUpdate = false;

  List<File> audioFiles = [];

  @override
  void initState() {
    textEditingController.addListener((){
      alarm.text = textEditingController.text;
    });
    _initVolume();
    _copyAudio();
    _loadAudios();
    super.initState();
  }

  _initVolume() async {
    await Volume.initAudioStream(AudioManager.streamNotification);

    // get Max Volume
    Volume.getMaxVol.then((v)=>_maxVol = v);
    // get Current Volume
    Volume.getVol.then((v)=>_volume = v);

    setState(() {});
  }

  void setVol({int androidVol = 0, double iOSVol = 0.0, bool showVolumeUI = true}) async {
    await Volume.setVol(
      androidVol: androidVol,
      iOSVol: iOSVol,
      showVolumeUI: showVolumeUI,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppViewModel>(
        builder: (context, appVM, child) {
          if(firstLaunch){
            final searched = appVM.alarms.where((e)=>e.id==widget.alarmId);
            alarm = searched.isNotEmpty?searched.first:Alarm(widget.alarmId, -1, selectedDatetime, [], '', true, "", notificationIds: [], offMods: [], offModsParams: {});
            if(searched.isNotEmpty){
              selectedDatetime = alarm.dateTime;
              shouldUpdate = true;
            }
            final sn = alarm.snooze.split("|");
            alarm.snooze.isNotEmpty?setdownText = "${repeatInterval[int.parse(sn[0])]}., ${repeatCount[int.parse(sn[1])]}":setdownText="нет";
          firstLaunch = false;
          }
          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: SafeArea(
                child: settingScreen==2?AlarmSettingsOffScreen((type, params){
                  if(type == -1) {
                    setState(() {
                      settingScreen = 0;
                    });
                    return;
                  }
                  alarm.offMods.add(type);
                  alarm.offModsParams.addAll(params);
                  setState(() {
                    settingScreen = 0;
                  });
                }): settingScreen==1?
                   SnoozeSettingsScreen(alarm.snooze, (snooze){
                     alarm.snooze = snooze;
                     setState(() {
                       final sn = snooze.split("|");
                       snooze.isNotEmpty?setdownText = "${repeatInterval[int.parse(sn[0])]}., ${repeatCount[int.parse(sn[1])]}":setdownText="нет";
                       settingScreen = 0;
                     });
                   }) : Column(
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
                              List<int> alarmIds = [];
                              if(alarm.remindDays.isNotEmpty){
                                alarmIds = await setAlarm(alarm, true);
                              }else{
                                alarmIds = await setAlarm(alarm, false);
                              }
                              shouldUpdate?appVM.updateAlarm(Alarm(alarm.id, alarm.TaskId, alarm.dateTime, alarm.remindDays, alarm.music, alarm.remindEnabled, alarm.text, vibration: alarm.vibration, notificationIds: alarmIds, offMods: alarm.offMods, offModsParams: alarm.offModsParams, snooze: alarm.snooze)):
                              appVM.addAlarm(Alarm(alarm.id, alarm.TaskId, alarm.dateTime, alarm.remindDays, alarm.music, alarm.remindEnabled, alarm.text, vibration: alarm.vibration, notificationIds: alarmIds, offMods: alarm.offMods, offModsParams: alarm.offModsParams, snooze: alarm.snooze));
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
                                  InkWell(
                                    onTap: (){
                                      setState(() {
                                        settingScreen = 2;
                                      });
                                    }, child: ShaderMask(
                                      blendMode: BlendMode.srcIn,
                                      shaderCallback: (bounds) => const LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd]).createShader(
                                        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                                      ),
                                      child: Container(height: 70, width: 70,
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(width: 1, color: Colors.white)),
                                        child: Center(child: alarm.offMods.contains(0)?Column(mainAxisSize: MainAxisSize.min, children: [SvgPicture.asset('assets/icons/tablerswipe.svg', height: 40, width: 40),const Text("желаний")],):const Icon(Icons.add, size: 25,)),
                                      )
                                  )
                                  ),
                                  const SizedBox(width: 16),
                                  InkWell(
                                      onTap: (){
                                        setState(() {
                                          settingScreen = 2;
                                        });
                                      }, child: ShaderMask(
                                      blendMode: BlendMode.srcIn,
                                      shaderCallback: (bounds) => const LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd]).createShader(
                                        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                                      ),
                                      child: Container(height: 70, width: 70,
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(width: 1, color: Colors.white)),
                                        child: Center(child: alarm.offMods.contains(1)?Column(mainAxisSize: MainAxisSize.min, children: [SvgPicture.asset('assets/icons/fluenttasklist.svg', height: 40, width: 40),const Text("задачи")],):const Icon(Icons.add, size: 25,)),
                                      )
                                  )
                                  ),
                                  const SizedBox(width: 16),
                                  InkWell(
                                      onTap: (){
                                        setState(() {
                                          settingScreen = 2;
                                        });
                                      }, child: ShaderMask(
                                      blendMode: BlendMode.srcIn,
                                      shaderCallback: (bounds) => const LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd]).createShader(
                                        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                                      ),
                                      child: Container(height: 70, width: 70,
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(width: 1, color: Colors.white)),
                                        child: Center(child: alarm.offMods.contains(2)?Column(mainAxisSize: MainAxisSize.min, children: [SvgPicture.asset('assets/icons/magemessage.svg', height: 40, width: 40),const Text("аффирмац")],):const Icon(Icons.add, size: 25,)),
                                      )
                                  )
                                  ),
                                  const SizedBox(width: 16),
                                  InkWell(
                                      onTap: (){
                                      }, child: Container(height: 70, width: 70,
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(width: 1, color: AppColors.darkGrey)),
                                    child: const Center(child: Icon(Icons.lock, size: 25, color: AppColors.darkGrey)),
                                  )
                                  )
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
                                              Navigator.pop(context);
                                            }, alarm.remindDays);
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
                                      onTap: () {
                                        showModalBottomSheet(
                                            backgroundColor: AppColors.backgroundColor,
                                          context: context,
                                          isScrollControlled: true,
                                              builder: (BuildContext context) {
                                            return Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Padding(
                                                  padding: EdgeInsets.all(16.0),
                                                  child: Center(child: Text("Выберите аудио")),
                                                ),
                                                ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount: audioFiles.length,
                                                  itemBuilder: (context, index){
                                                    return ListTile(
                                                      title: Text(audioFiles[index].path.split("/").last),
                                                      leading: const Icon(Icons.audiotrack),
                                                      onTap: (){
                                                        setState(() {
                                                          alarm.music=audioFiles[index].path;
                                                        });
                                                        Navigator.pop(context);
                                                      },
                                                    );
                                                  },
                                                )
                                              ],
                                            );
                                          },
                                        );
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
                                          child: Slider(value: _volume.toDouble(), max: _maxVol.toDouble(), onChanged: (v){
                                            _volume = v.toInt();
                                             setVol(androidVol: v.toInt());
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
                              InkWell(
                                onTap: () async {
                                  setState(() {
                                    settingScreen = 1;
                                  });
                                },
                                child: Container(
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
                                ),
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
  Future _copyAudio() async{
    final appDir =await getApplicationDocumentsDirectory();
    final audioDir = Directory('${appDir.path}/audios');
    if(!await audioDir.exists()){
      await audioDir.create();
      const audioAsset = 'assets/audio/notification.mp3';
      final bytes = await rootBundle.load(audioAsset);
      final audioFile = File('${audioDir.path}/not1.mp3');
      await audioFile.writeAsBytes(bytes.buffer.asUint8List());
    }
  }
  Future _loadAudios() async{
    final appDir =await getApplicationDocumentsDirectory();
    final audioDir = Directory('${appDir.path}/audios');
    if(await audioDir.exists()){
      final files = await audioDir.list().toList();
      audioFiles = files.whereType<File>().toList();
    }
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

  Future<int> showSnoozeRepeatsSettings(int count) async {
    return await showModalBottomSheet(backgroundColor: AppColors.backgroundColor,
        context: context,
        isScrollControlled: true,
        builder: (buildContext){
          return Snoozerepeatssettings(count, (count){
            Navigator.pop(context, count);
          });
        });
  }
}
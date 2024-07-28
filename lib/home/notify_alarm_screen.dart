import 'dart:async';
import 'dart:ffi';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/data/date_static.dart';
import 'package:wishmap/interface_widgets/colorButton.dart';

import 'package:wishmap/repository/local_repository.dart';
import 'package:wishmap/services/reminder_service.dart';

import '../ViewModel.dart';
import '../data/models.dart';
import '../data/static.dart';
import '../data/static_affirmations_men.dart';
import '../res/colors.dart';

class NotifyAlarmScreen extends StatefulWidget {
  final Function() onClose;
  final int alarmId;

  const NotifyAlarmScreen(this.onClose, this.alarmId, {super.key});

  @override
  NotifyAlarmScreenState createState() => NotifyAlarmScreenState();
}

class NotifyAlarmScreenState extends State<NotifyAlarmScreen>{
  static const intervals = [3, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60];
  DateTime current = DateTime.now();
  Alarm? alarm;
  String snooze = "";
  bool repeatState = false;
  @override
  void initState(){
    super.initState();
    Timer.periodic(const Duration(minutes: 1), (timer) {_updateDT();});
  }

  void _updateDT(){
    setState(() {
      current = DateTime.now();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final appViewModel = Provider.of<AppViewModel>(context);
    if(alarm==null) {
      appViewModel.getAlarmById(widget.alarmId).then((v){setState(() {
        alarm = v;
        if(v!=null){
          snooze = v.snooze;
        }
      });
      });
    }
    return Stack(
      children: [
        Image.asset(
          "assets/icons/space.png",
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        Scaffold(
          backgroundColor: Colors.white.withAlpha(0),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height*0.12),
                Text("${fullDayOfWeek[current.weekday]}, ${current.day} ${monthOfYear[current.month]} ${current.year}", style: const TextStyle(color: Colors.white),),
                Text(DateFormat('HH:mm').format(current), style: const TextStyle(fontSize: 64, color: Colors.white)),
                ColorRoundedButton("Посмотреть задачи", (){

                }),
                const Spacer(),
                Text(IMenAffirmations[Random().nextInt(IMenAffirmations.length)], textAlign: TextAlign.center, style: const TextStyle(color: Colors.white,  fontWeight: FontWeight.w500, fontSize: 16)),
                const Spacer(),
                if(repeatState)Container(
                  height: 137,
                  width: double.infinity,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.white.withOpacity(0.4)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 12),
                      SvgPicture.asset('assets/icons/ring.svg', height: 32, width: 32),
                      Text(repeatInterval[int.parse(snooze.split("|")[0])], style: const TextStyle(fontSize: 40, color: Colors.white),),
                      Text("Повторить сигнал ${repeatCount[int.parse(snooze.split("|")[1])]}", style: const TextStyle(color: Colors.white))
                    ],
                  ),
                ),
                if(snooze.isNotEmpty&&!repeatState)InkWell(
                  onTap: (){
                    setState(() {
                      repeatState = true;
                    });
                    if(alarm!=null)setAlarm(Alarm(alarm!.id, alarm!.TaskId, alarm!.dateTime.add(Duration(minutes: intervals[int.parse(snooze.split("|")[1])])), alarm!.remindDays, alarm!.music, alarm!.remindEnabled, alarm!.text), false);
                  },
                  child:Container(
                    height: 46,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(23)),
                    child:Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: double.infinity,),
                        ShaderMask(
                            blendMode: BlendMode.srcIn,
                            shaderCallback: (bounds) => const LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd]).createShader(
                              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                            ),
                            child: const Text("Отложить будильник ")),
                        Text(repeatCount[int.parse(snooze.split("|")[1])])
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ColorRoundedButton("Отключить", (){
                    widget.onClose();
                })
              ],
            ),
          )
        )
      ],
    );
  }
}
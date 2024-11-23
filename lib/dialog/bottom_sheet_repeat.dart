import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wishmap/data/date_static.dart';
import 'package:wishmap/interface_widgets/colorButton.dart';
import 'package:wishmap/interface_widgets/sq_checkbox.dart';
import 'package:wishmap/res/colors.dart';

class RepeatBS extends StatefulWidget {
  RepeatBS(this.onClose, this.remindDays, {super.key});

  Function(List<String>, String) onClose;
  List<String> remindDays = [];

  @override
  RepeatBSState createState() => RepeatBSState();
}

class RepeatBSState extends State<RepeatBS>{
  late List<DateTime> dayList;

  List<bool> checkStates = List.generate(8, (i)=> false);
  @override
  void initState() {
    checkStates.indexed.forEach((item){
      if(widget.remindDays.contains(item.$1.toString())) (checkStates[item.$1] = true);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final daysString = buildDays(widget.remindDays);
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Будильник", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: ColorRoundedButton("Выходные", c: AppColors.transPink, radius: 6, textColor: AppColors.gradientStart, (){
                    setState(() {
                      checkStates = List.generate(8, (i)=>false);
                      checkStates[6]=true;
                      checkStates[7]=true;
                    });
                  })),
                  const SizedBox(width: 8),
                  Expanded(child: ColorRoundedButton("Будни", radius: 6, (){
                    setState(() {
                      checkStates = List.generate(8, (i)=>true);
                      checkStates[0]=false;
                      checkStates[6]=false;
                      checkStates[7]=false;
                    });
                  }))
                ],),
                const SizedBox(height: 20),
                SquareCheckbox(state: checkStates[0], "Выбрать все", (state){
                  if(state) {
                    setState(() {
                      checkStates = List.generate(8, (i)=>true);
                    });
                  }else{
                    checkStates[0]=false;
                  }
                }),
                SquareCheckbox(state: checkStates[1], "Понедельник", (state){checkStates[1]=state;}),
                SquareCheckbox(state: checkStates[2], "Вторник", (state){checkStates[2]=state;}),
                SquareCheckbox(state: checkStates[3], "Среда", (state){checkStates[3]=state;}),
                SquareCheckbox(state: checkStates[4], "Четверг", (state){checkStates[4]=state;}),
                SquareCheckbox(state: checkStates[5], "Пятница", (state){checkStates[5]=state;}),
                SquareCheckbox(state: checkStates[6], "Суббота", (state){checkStates[6]=state;}),
                SquareCheckbox(state: checkStates[7], "Воскресенье", (state){checkStates[7]=state;}),
                const SizedBox(height: 20),
                ColorRoundedButton("Готово", (){
                  widget.remindDays.clear();
                  for (var e in checkStates.indexed) {
                    if(e.$2)widget.remindDays.add(e.$1.toString());
                  }
                  widget.onClose(widget.remindDays, buildDays(widget.remindDays));
                })
              ],
            ),
          );
        }
    );
  }
}

String buildDays(List<String> remindDays){
  String daysString = "";
  int prevDay = int.parse(remindDays.firstOrNull??"-1");
  bool isInterval = false;
  for (var e in remindDays) {
    final day = int.parse(e);
    if(day!=0){
      daysString+="${shortDayOfWeek[day]}";
      if(day==prevDay+1){
        prevDay = day;
        isInterval=true;
      }else{isInterval=false;}
    }
  }
  if(isInterval){
    daysString = "${shortDayOfWeek[int.parse(remindDays.firstOrNull??"0")]}-${shortDayOfWeek[int.parse(remindDays.lastOrNull??"0")]}";
  }
  return daysString;
}
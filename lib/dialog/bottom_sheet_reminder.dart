import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wishmap/data/date_static.dart';
import 'package:wishmap/import_extension/custom_string_picker.dart';
import 'package:wishmap/interface_widgets/colorButton.dart';
import 'package:wishmap/interface_widgets/sq_checkbox.dart';
import 'package:wishmap/res/colors.dart';

import '../common/switch_widget.dart';
import '../data/models.dart';

enum IntervalLabel {
  none('не выбран', 0),
  thrt('30 мин', 30),
  on('1 час', 60),
  tw('2 часа', 120),
  th('3 часа', 180),
  six('6 часов', 360),
  twlw('12 часов', 780);

  const IntervalLabel(this.label, this.v);
  final String label;
  final int v;
}

class ReminderBS extends StatefulWidget {
  ReminderBS(this.onClose, this.parentTaskId, {super.key});

  Function() onClose;
  int parentTaskId;

  @override
  ColorPickerBSState createState() => ColorPickerBSState();
}

class ColorPickerBSState extends State<ReminderBS>{
  String datetime = "";
  DateTime selectedDatetime = DateTime.now().add(const Duration(minutes: 30));
  IntervalLabel selectedItem = IntervalLabel.th;

  final TextEditingController intervalController = TextEditingController();
  late List<DateTime> dayList;

  int settingScreen = 0;//0-none 1-remind in 2-repeat
  List<bool> checkStates = List.generate(8, (i)=> false);

  late Reminder reminder;

  @override
  void initState() {
    super.initState();

    reminder = Reminder(-1, widget.parentTaskId, selectedDatetime, [], "default", false);
    datetime = "${fullDayOfWeek[selectedDatetime.weekday]}, ${selectedDatetime.day} ${monthOfYear[selectedDatetime.month]} ${selectedDatetime.year}";
    dayList = List<DateTime>.generate(62, (i) =>
        DateTime.utc(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        ).add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: settingScreen==0?Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Напоминание", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                  const Text("Напомнить через"),
                  const Spacer(),
                    Theme(
                      data: Theme.of(context).copyWith(
                        canvasColor: Colors.blue,
                        dropdownMenuTheme: DropdownMenuThemeData(
                          inputDecorationTheme: InputDecorationTheme(
                            fillColor: AppColors.grey,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                width: 0,
                                style: BorderStyle.none,
                              ),
                            ),
                          )
                        )
                      ),
                      child: DropdownMenu<IntervalLabel>(
                        initialSelection: selectedItem,
                        controller: intervalController,
                        onSelected: (IntervalLabel? interval) {
                          if(interval==IntervalLabel.none)return;
                          if(interval!=null){
                            setState(() {
                              selectedDatetime = DateTime.now().add(Duration(minutes: interval.v));
                            });
                          }
                        },
                        dropdownMenuEntries: IntervalLabel.values
                            .map<DropdownMenuEntry<IntervalLabel>>(
                                (IntervalLabel interval) {
                              return DropdownMenuEntry<IntervalLabel>(
                                value: interval,
                                label: interval.label
                              );
                            }).toList(),
                      ),
                    ),
                ],),
                const SizedBox(height: 20),
                const Align(alignment: Alignment.centerLeft,child: Text("Выберите дату и время:", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
                Align(alignment: Alignment.centerLeft,child: Text(datetime, style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: AppColors.greytextColor))),
                const SizedBox(height: 8),
                Row(
                  children: [
                    StringPicker(itemWidth: 130, minValue: 0, maxValue: 60, value: dayList.indexWhere((e)=>e.day==selectedDatetime.day&&e.month==selectedDatetime.month), text: dayList.map((e)=>"${e.day} ${monthOfYear[e.month]?.toLowerCase()}").toList(), onChanged: (v){
                        selectedDatetime = selectedDatetime.copyWith(day: dayList[v].day, month: dayList[v].month);
                          setState(() {
                            datetime = "${fullDayOfWeek[selectedDatetime.weekday]}, ${selectedDatetime.day} ${monthOfYear[selectedDatetime.month]} ${selectedDatetime.year}";
                          selectedItem = IntervalLabel.none;
                        });
                    }),
                    const Spacer(),
                    StringPicker(itemWidth: 70, minValue: 0, maxValue: 23, value: selectedDatetime.hour, onChanged: (v){
                        selectedDatetime = selectedDatetime.copyWith(hour: v);
                        if(selectedItem!=IntervalLabel.none) {
                          setState(() {
                            selectedItem = IntervalLabel.none;
                          });
                        }
                    }),
                    const Text(":", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    StringPicker(itemWidth: 70, minValue: 0, maxValue: 59, value: selectedDatetime.minute, onChanged: (v){
                        selectedDatetime = selectedDatetime.copyWith(minute: v);
                        if(selectedItem!=IntervalLabel.none) {
                          setState(() {
                            selectedItem = IntervalLabel.none;
                          });
                        }
                    }),
                  ]
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.grey
                  ),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: (){
                          setState(() {
                            settingScreen = 2;
                          });
                        },
                        child: const Row(
                          children: [
                            Text("Повторить"),
                            Spacer(),
                            Text("pn - vs"),
                            Icon(Icons.arrow_forward_ios)
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Row(
                        children: [
                          Text("Сигнал напоминания"),
                          Spacer(),
                          Text("type"),
                          Icon(Icons.arrow_forward_ios)
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text("Повторить"),
                          const Spacer(),
                          MySwitch(value: false, onChanged: (v){

                          },)
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                ColorRoundedButton("Сохранить", (){

                })
              ],
            ):
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Напоминание", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: ColorRoundedButton("Выходные", c: AppColors.transPink, radius: 6, textColor: AppColors.gradientStart, (){
                    setState(() {
                      checkStates = List.generate(8, (i)=>false);
                      checkStates[1]=true;
                      checkStates[7]=true;
                    });
                  })),
                  const SizedBox(width: 8),
                  Expanded(child: ColorRoundedButton("Будни", radius: 6, (){
                    setState(() {
                      checkStates = List.generate(8, (i)=>true);
                      checkStates[0]=false;
                      checkStates[1]=false;
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
                SquareCheckbox(state: checkStates[1], "Воскресенье", (state){}),
                SquareCheckbox(state: checkStates[2], "Понедельник", (state){}),
                SquareCheckbox(state: checkStates[3], "Вторник", (state){}),
                SquareCheckbox(state: checkStates[4], "Среда", (state){}),
                SquareCheckbox(state: checkStates[5], "Четверг", (state){}),
                SquareCheckbox(state: checkStates[6], "Пятница", (state){}),
                SquareCheckbox(state: checkStates[7], "Суббота", (state){}),
                const SizedBox(height: 20),
                ColorRoundedButton("Готово", (){
                  setState(() {
                    settingScreen = 0;
                  });
                })
              ],
            ),
          );
        }
    );
  }
}
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  ReminderBS(this.onClose, this.parentTaskId, this.moonId, {this.reminder, super.key});

  Function(Reminder) onClose;
  int parentTaskId;
  int moonId;
  Reminder? reminder;

  @override
  ReminderBSState createState() => ReminderBSState();
}

class ReminderBSState extends State<ReminderBS>{
  String datetime = "";
  DateTime selectedDatetime = DateTime.now();
  IntervalLabel selectedItem = IntervalLabel.none;

  final TextEditingController intervalController = TextEditingController();
  late List<DateTime> dayList;

  int settingScreen = 0;//0-none 1-remind in 2-repeat
  List<bool> checkStates = List.generate(8, (i)=> false);

  late Reminder reminder;

  String daysString = "";

  @override
  void initState() {
    super.initState();

    if(widget.reminder!=null){
      selectedDatetime =widget.reminder!.dateTime;
      checkStates = List.generate(8, (i)=>false);
      widget.reminder!.remindDays.forEach((i){
        if(i!="")checkStates[int.parse(i)]= true;
      });
    }
    reminder = widget.reminder??Reminder(-1, widget.parentTaskId, widget.moonId, selectedDatetime, [], "default", false);
    datetime = "${fullDayOfWeek[selectedDatetime.weekday]}, ${selectedDatetime.day} ${monthOfYear[selectedDatetime.month]} ${selectedDatetime.year}";
    dayList = widget.reminder==null?List<DateTime>.generate(62, (i) =>
        DateTime.utc(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        ).add(Duration(days: i))):List<DateTime>.generate(62, (i) =>
        selectedDatetime.add(Duration(days: i)));
    daysString = buildDays();
  }

  String buildDays(){
    if(reminder.remindDays.firstOrNull=="")return "";
    String daysString = "";
    int prevDay = int.parse(reminder.remindDays.firstOrNull??"-1");
    bool isInterval = false;
    for (var e in reminder.remindDays) {
      final day = int.parse(e);
      if(day!=0){
        daysString+="${shortDayOfWeek[day-1]}";
        if(day==prevDay+1){
          prevDay = day;
          isInterval=true;
        }
      }
    }
    if(isInterval){
      daysString = "${shortDayOfWeek[int.parse(reminder.remindDays.firstOrNull??"0")]}-${shortDayOfWeek[int.parse(reminder.remindDays.lastOrNull??"0")]}";
    }
    return daysString;
  }

  @override
  Widget build(BuildContext context) {
    daysString = buildDays();
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
                InkWell(onTap:() async {
                    var results = await showCalendarDatePicker2Dialog(
                      context: context,
                      config: CalendarDatePicker2WithActionButtonsConfig(

                      ),
                      dialogSize: const Size(325, 400),
                      borderRadius: BorderRadius.circular(15),

                    );
                    if(results!=null){
                      setState(() {
                        selectedDatetime = selectedDatetime.copyWith(year:  results.first?.year, month: results.first?.month, day: results.first?.day);
                        final startdate = selectedDatetime.subtract(const Duration(days: 20));
                        dayList = List<DateTime>.generate(82, (i) =>
                            DateTime.utc(
                              startdate.year,
                              startdate.month,
                              startdate.day,
                            ).add(Duration(days: i)));
                      });
                    }
                    },
                    child: Align(alignment: Alignment.centerLeft,child:Text(datetime, style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: AppColors.greytextColor)))),
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
                    StringPicker(itemWidth: 70, minValue: 0, maxValue: 59, infiniteLoop: true, zeroPad: true, value: selectedDatetime.minute, onChanged: (v){
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
                      const Row(
                        children: [
                          Text("Сигнал напоминания"),
                          Spacer(),
                          Text("signal"),
                          Icon(Icons.arrow_forward_ios)
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text("вибрация"),
                          const Spacer(),
                          MySwitch(value: reminder.vibration, onChanged: (v){
                            reminder.vibration = v;
                          },)
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                ColorRoundedButton("Сохранить", (){
                  reminder.dateTime = selectedDatetime;
                  reminder.remindEnabled = true;
                  widget.onClose(reminder);
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
                SquareCheckbox(state: checkStates[1], "Воскресенье", (state){checkStates[7]=state;}),
                SquareCheckbox(state: checkStates[2], "Понедельник", (state){checkStates[1]=state;}),
                SquareCheckbox(state: checkStates[3], "Вторник", (state){checkStates[2]=state;}),
                SquareCheckbox(state: checkStates[4], "Среда", (state){checkStates[3]=state;}),
                SquareCheckbox(state: checkStates[5], "Четверг", (state){checkStates[4]=state;}),
                SquareCheckbox(state: checkStates[6], "Пятница", (state){checkStates[5]=state;}),
                SquareCheckbox(state: checkStates[7], "Суббота", (state){checkStates[6]=state;}),
                const SizedBox(height: 20),
                ColorRoundedButton("Готово", (){
                  reminder.remindDays.clear();
                  for (var e in checkStates.indexed) {
                    if(e.$2)reminder.remindDays.add(e.$1.toString());
                  }
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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:wishmap/common/switch_widget.dart';
import 'package:wishmap/data/date_static.dart';
import 'package:wishmap/data/models.dart';
import 'package:wishmap/res/colors.dart';

class ReminderItem extends StatefulWidget{

  ReminderInterface reminder;
  Function(int id)? onDelete;
  Function(int id)? onTap;
  Function(int id, bool state)? onChangeState;

  bool outlined = false;

  ReminderItem(this.reminder, { this.onTap, this.onDelete, this.onChangeState, this.outlined = false, super.key});

  @override
  State<ReminderItem> createState() => ReminderItemState();
}

class ReminderItemState extends State<ReminderItem>{

  DateTime getNextReminder() {
    // Получаем текущую дату и время
    DateTime now = DateTime.now();

    // Получаем текущий день недели
    String today = DateFormat('EEEE').format(now);

    // Проверяем, если сегодня напоминание и время еще не прошло
    /*if (now.isBefore(DateTime(now.year, now.month, now.day, widget.reminder.dateTime.hour, widget.reminder.dateTime.minute))) {
      return DateTime(now.year, now.month, now.day, widget.reminder.dateTime.hour, widget.reminder.dateTime.minute);
    }*/

    // Если сегодня уже прошло или не в списке дней, ищем следующий ближайший день
      for (int i = 1; i <= 7; i++) {
      DateTime nextDay = now.add(Duration(days: i));
      String nextDayName = DateFormat('EEEE').format(nextDay);

      if (widget.reminder.remindDays.contains(nextDayName)) {
        return DateTime(nextDay.year, nextDay.month, nextDay.day, widget.reminder.dateTime.hour, widget.reminder.dateTime.minute);
      }
    }

    // Если список remindDays пустой или напоминание выключено
    return widget.reminder.dateTime;
  }

  @override
  Widget build(BuildContext context) {
    final nextReminder = getNextReminder();
    Duration difference = nextReminder.difference(DateTime.now());

    return InkWell(
      onTap: (){
        widget.onTap!(widget.reminder.id);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(14)),
          border: widget.outlined?Border.all(color: AppColors.gradientStart, width: 2):null,
          color: Colors.white
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                widget.reminder.remindEnabled?Text(difference.inMinutes>0?"Сработает через ${difference.inHours}ч ${difference.inMinutes-(difference.inHours*60)}мин":"Будильник уже сработал", style: const TextStyle(fontSize: 14, color: AppColors.greytextColor),):const SizedBox(),
                if(widget.reminder is Reminder)InkWell(onTap: (){
                  if(widget.onDelete!=null)widget.onDelete!(widget.reminder.id);
                }, child: SvgPicture.asset("assets/icons/trash.svg", width: 28, height: 28)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        Text("${nextReminder.hour}:${nextReminder.minute.toString().padLeft(2, "0")}", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w500)),
                        const SizedBox(width: 8),
                        if(widget.reminder is Alarm)Text((widget.reminder as Alarm).text, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500))
                      ],
                    ),
                    Text(fullDayOfWeek[nextReminder.weekday]??"", style: const TextStyle(fontSize: 14, color: AppColors.greytextColor))
                  ],
                ),
                MySwitch(value: widget.reminder.remindEnabled, onChanged: (v){
                  if(widget.onChangeState!=null)widget.onChangeState!(widget.reminder.id, v);
                },)
              ],
            )
          ],
        ),
      ),
    );
  }

}
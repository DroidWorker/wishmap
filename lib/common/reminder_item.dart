import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:wishmap/common/switch_widget.dart';
import 'package:wishmap/data/date_static.dart';
import 'package:wishmap/data/models.dart';
import 'package:wishmap/res/colors.dart';

class ReminderItem extends StatefulWidget{

  Reminder reminder;
  Function(int id)? onDelete;
  Function(int id)? onTap;
  Function(int id, bool state)? onChangeState;

  ReminderItem(this.reminder, {this.onTap, this.onDelete, this.onChangeState, super.key});

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
    Duration? difference = nextReminder?.difference(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        color: Colors.white
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              difference!=null?Text("Сработает через ${difference.inHours}ч ${difference.inMinutes}мин", style: const TextStyle(fontSize: 14, color: AppColors.greytextColor),):const SizedBox(),
              InkWell(onTap: (){
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
                  Text("${nextReminder.hour}:${nextReminder.minute}", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w500),),
                  Text(fullDayOfWeek[nextReminder.weekday]??"", style: const TextStyle(fontSize: 14, color: AppColors.greytextColor))
                ],
              ),
              MySwitch(value: true, onChanged: (v){
                if(widget.onChangeState!=null)widget.onChangeState!(widget.reminder.id, v);
              },)
            ],
          )
        ],
      ),
    );
  }

}
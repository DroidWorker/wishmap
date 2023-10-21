import 'package:flutter/material.dart';

import '../data/models.dart';

class TaskItemWidget extends StatefulWidget{
  TaskItemWidget({super.key, required this.ti, required this.onClick,required this.onDelete});

  TaskItem ti;
  Function(int id) onClick;
  Function(int id) onDelete;

  @override
  _TaskItem createState() => _TaskItem();
}

class _TaskItem extends State<TaskItemWidget>{
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: widget.ti.isChecked ? Text(widget.ti.text,style: const TextStyle(decoration: TextDecoration.lineThrough),) : Text(widget.ti.text) ),
      IconButton(
          icon: widget.ti.isChecked?const Icon(Icons.check_circle_outline):const Icon(Icons.circle_outlined),
          iconSize: 30,
          onPressed: () {
            widget.onClick(widget.ti.id);
          },
      ),
      IconButton(
        icon: Image.asset('assets/icons/delete6161554.png'),
        iconSize: 30,
        onPressed: () {
          widget.onDelete(widget.ti.id);
        },
      )
    ],);
  }

}
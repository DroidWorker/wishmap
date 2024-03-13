import 'package:flutter/material.dart';

import '../data/models.dart';

class TaskItemWidget extends StatefulWidget{
  TaskItemWidget({super.key, required this.ti, required this.onSelect, required this.onClick,required this.onDelete});

  TaskItem ti;
  Function(int id) onSelect;
  Function(int id) onClick;
  Function(int id) onDelete;

  @override
  _TaskItem createState() => _TaskItem();
}

class _TaskItem extends State<TaskItemWidget>{
  var c = Colors.black;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.onSelect(widget.ti.id);
      },
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                widget.onSelect(widget.ti.id);
              },
              child: widget.ti.isChecked
                  ? Text(
                widget.ti.text,
                style: const TextStyle(decoration: TextDecoration.lineThrough),
              )
                  : Text(widget.ti.text),
            ),
          ),
          IconButton(
            icon: widget.ti.isChecked ? Image.asset('assets/icons/task_done.png', width: 30, height: 30) : widget.ti.isActive?Image.asset('assets/icons/task_active.png', width: 30, height: 30) : Image.asset('assets/icons/task_unactive.png', width: 30, height: 30),
            onPressed: () {
              widget.onClick(widget.ti.id);
            },
          ),
        ],
      ),
    );
  }

}
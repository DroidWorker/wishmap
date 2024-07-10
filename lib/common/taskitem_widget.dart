import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../data/models.dart';
import '../res/colors.dart';

class TaskItemWidget extends StatefulWidget{
  TaskItemWidget({super.key, required this.ti, required this.path, required this.onSelect, required this.onDoubleClick, this.onDelete, this.outlined = false});

  TaskItem ti;
  String path;
  bool outlined;
  Function(int id) onSelect;
  Function(int id) onDoubleClick;
  Function(int id)? onDelete;

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
        onDoubleTap: (){
          widget.onDoubleClick(widget.ti.id);
          if(widget.ti.isActive&&!widget.ti.isChecked) {
            setState(() {
            widget.ti.isChecked = true;
          });
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 1),
          padding: const EdgeInsets.all(2),
          decoration: widget.outlined?const BoxDecoration(
            gradient: LinearGradient(
                colors: [AppColors.gradientStart, AppColors.gradientEnd]
            ),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ):null,
          child: Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              height: 50,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.path, maxLines: 1, style: const TextStyle(color: AppColors.textLightGrey)),
                      widget.ti.isChecked ? Expanded(
                        child:
                            Text(widget.ti.text.replaceAll("HEADERSIMPLETASKHEADER", ""),
                          style: const TextStyle(decoration: TextDecoration.lineThrough, decorationColor: AppColors.greytextColor, color: AppColors.greytextColor),),
                      ) : Text(widget.ti.text.replaceAll("HEADERSIMPLETASKHEADER", "")),
                    ],
                  ),
                  Container(
                    height: 44,
                    width: 44,
                    decoration: const BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.all(Radius.circular(7)),
                    ),
                    child: Center(child: widget.ti.isChecked ? Image.asset('assets/icons/task_done.png', width: 30, height: 30) : widget.ti.isActive?Image.asset('assets/icons/task_active.png', width: 30, height: 30) : Image.asset('assets/icons/task_unactive.png', width: 30, height: 30),),
                  )
                ],
              ),
            ),
        )
    );
  }

}
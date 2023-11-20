import 'package:flutter/material.dart';

import '../data/models.dart';

class AimItemWidget extends StatefulWidget{
  AimItemWidget({super.key, required this.ai, required this.onItemSelect, required this.onClick, required this.onDelete});

  AimItem ai;
  Function(int id) onItemSelect;
  Function(int id) onClick;
  Function(int id) onDelete;

  @override
  _AimItem createState() => _AimItem();
}

class _AimItem extends State<AimItemWidget>{
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child:
      GestureDetector(
        onTap: (){
          widget.onItemSelect(widget.ai.id);
        },
        child: widget.ai.isChecked ? Text(widget.ai.text,style: const TextStyle(decoration: TextDecoration.lineThrough),) : Text(widget.ai.text),
      )),
      IconButton(
        icon: widget.ai.isChecked?Image.asset('assets/icons/target1914412.png'):Image.asset('assets/icons/nountarget423422.png'),
        iconSize: 30,
        onPressed: () {
          widget.onClick(widget.ai.id);
        },
      ),
      // IconButton(
      //   icon: Image.asset('assets/icons/delete6161554.png'),
      //   iconSize: 30,
      //   onPressed: () {
      //       widget.onDelete(widget.ai.id);
      //     },
      // )
    ],);
  }

}
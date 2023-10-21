import 'package:flutter/material.dart';

import '../data/models.dart';

class WishItemWidget extends StatefulWidget{
  WishItemWidget({super.key, required this.ti, required this.onClick, required this.onDelete});

  WishItem ti;
  Function(int id) onClick;
  Function(int id) onDelete;

  @override
  _TaskItem createState() => _TaskItem();
}

class _TaskItem extends State<WishItemWidget>{
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Text(widget.ti.text)),
      IconButton(
        icon: widget.ti.isChecked?Image.asset('assets/icons/love5110868fill.png'):Image.asset('assets/icons/love5110868.png'),
        iconSize: 30,
        onPressed: () {
          widget.onClick(widget.ti.id);
        },
      ),
      if(widget.ti.isChecked)
        IconButton(
          icon: Image.asset('assets/icons/delete6161554.png'),
          iconSize: 30,
          onPressed: () {
            widget.onDelete(widget.ti.id);
          },
        )
      else const SizedBox(height: 30, width: 50,)
    ],);
  }

}
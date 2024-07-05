import 'dart:ui';

import 'package:flutter/material.dart';

showPopupMenu(Offset offset, BuildContext context, Function onDelete, Function onEdit) async {
  double left = offset.dx;
  double top = offset.dy;
  await showMenu(
    context: context,
    position: RelativeRect.fromLTRB(left, top, 0, 0),
    items: [
     const PopupMenuItem(value: 0, child: Text("Изменить")),
      const PopupMenuItem(value: 1, child: Text("Удалить"))
    ],
    elevation: 1.0,
  ).then((value){
    if(value==1){
      onDelete();
    } else if(value == 0){
      onEdit();
    }
  });
}

showDeletePopupMenu(Offset offset, BuildContext context, Function onDelete) async {
  double left = offset.dx;
  double top = offset.dy;
  await showMenu(
    context: context,
    position: RelativeRect.fromLTRB(left, top, MediaQuery.of(context).size.width - offset.dx, MediaQuery.of(context).size.height - offset.dy),
    items: [
      const PopupMenuItem(value: 0, child: Text("Удалить"))
    ],
    elevation: 1.0,
  ).then((value){
    if(value==0){
      onDelete();
    }
  });
}
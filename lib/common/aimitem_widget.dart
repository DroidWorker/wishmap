import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../data/models.dart';
import '../res/colors.dart';

class AimItemWidget extends StatefulWidget{
  AimItemWidget({super.key, required this.ai, required this.onItemSelect, required this.onDoubleClick, this.onDelete, this.outlined = true});

  AimItem ai;
  bool outlined;
  Function(int id) onItemSelect;
  Function(int id) onDoubleClick;
  Function(int id)? onDelete;

  @override
  _AimItem createState() => _AimItem();
}

class _AimItem extends State<AimItemWidget>{
  int touchCount=0;
  Timer? _timer;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _timer?.cancel();
        touchCount++;
        if (touchCount>1) {
          widget.onDoubleClick(widget.ai.id);
          touchCount=0;
        } else {
          _timer=Timer(const Duration(milliseconds: 150), () {
            widget.onItemSelect(widget.ai.id);
            touchCount=0;
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
            children: [
              widget.ai.isChecked ? Text(
                widget.ai.text,
                style: const TextStyle(decoration: TextDecoration.lineThrough, decorationColor: AppColors.greytextColor, color: AppColors.greytextColor),
              ) : Text(widget.ai.text),
              const Spacer(),
              Container(
                height: 44,
                width: 44,
                decoration: const BoxDecoration(
                    color: AppColors.lightGrey,
                  borderRadius: BorderRadius.all(Radius.circular(7))
                ),
                child: Center(child: widget.ai.isChecked ? Image.asset('assets/icons/target_done.png', width: 20, height: 20): widget.ai.isActive? Image.asset('assets/icons/target_active.png', width: 20, height: 20) : Image.asset('assets/icons/target_unactive.png', width: 20, height: 20)),
              )
            ],
          ),
        ),
      )
    );
  }

}
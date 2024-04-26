import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../data/models.dart';
import '../res/colors.dart';

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
    return InkWell(
      onTap: () {
        widget.onItemSelect(widget.ai.id);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.all(5),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        height: 50,
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: const BoxDecoration(
                  color: AppColors.lightGrey,
                borderRadius: BorderRadius.all(Radius.circular(7))
              ),
              child: Center(child: widget.ai.isChecked ? Image.asset('assets/icons/target_done.png', width: 20, height: 20): widget.ai.isActive? Image.asset('assets/icons/target_active.png', width: 20, height: 20) : Image.asset('assets/icons/target_unactive.png', width: 20, height: 20)),
            ),
            const SizedBox(width: 10),
            widget.ai.isChecked ? Text(
              widget.ai.text,
              style: const TextStyle(decoration: TextDecoration.lineThrough, decorationColor: AppColors.greytextColor, color: AppColors.greytextColor),
            ) : Text(widget.ai.text),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 12,)
          ],
        ),
      )
    );
  }

}
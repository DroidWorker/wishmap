import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../res/colors.dart';

class CustomCheckbox extends StatefulWidget {
  bool isCircle;
  Function(bool value) onChanged;
  CustomCheckbox({Key? key, required this.isCircle, required this.onChanged}) : super(key: key);

  @override
  State<CustomCheckbox> createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 20,
        width: 20,
        child:GestureDetector(
          onTap: () {
            setState(() => isChecked = !isChecked);
            widget.onChanged(isChecked);
          },
          child: AnimatedContainer(
              height: 20,
              width: 20,
              alignment: Alignment.center,
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastLinearToSlowEaseIn,
              decoration: BoxDecoration(color: AppColors.fieldFillColor, borderRadius: widget.isCircle?BorderRadius.circular(10):BorderRadius.circular(1.0), border: Border.all(width: 0)),
              child: isChecked ? const Text("v") : null),
        )
    );
  }
}
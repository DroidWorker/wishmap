import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../res/colors.dart';

class SquareCheckbox extends StatefulWidget{
  bool state;
  String text;
  Function(bool) stateChanged;
  SquareCheckbox(this.text, this.stateChanged, { this.state = false, super.key});
  @override
  SquareCheckboxState createState() => SquareCheckboxState();
}

class SquareCheckboxState extends State<SquareCheckbox>{
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: InkWell(
        onTap: (){
          widget.state = !widget.state;
          widget.stateChanged(widget.state);
          setState(() {});
        },
        child: Row(
          children: [
            Container(width: 20,height: 20,
              padding: const EdgeInsets.all(2),
              decoration:  BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(3)),
                  border: Border.all(color: AppColors.gradientStart)
              ),
              child: widget.state?Container(
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                    gradient: LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd])
                ),
              ):const SizedBox(),
            ),
            const SizedBox(width: 12),
            Text(widget.text, style: const TextStyle(fontSize: 20))
          ],
        ),
      ),
    );
  }
}
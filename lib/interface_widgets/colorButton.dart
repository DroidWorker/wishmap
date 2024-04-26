import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../res/colors.dart';

class ColorRoundedButton extends StatelessWidget{
  String text;
  Function() onPressed;
  ColorRoundedButton( this.text, this.onPressed, {super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(padding: EdgeInsets.zero),
        onPressed: ()=>onPressed(),
        child: Container(
          height: 46,
          decoration:  const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(23)),
              gradient: LinearGradient(
                  colors: [AppColors.gradientStart, AppColors.gradientEnd]
              )
          ),
            child: Center(child: Text(text, style: const TextStyle(color: Colors.white),))
        )
    );
  }

}
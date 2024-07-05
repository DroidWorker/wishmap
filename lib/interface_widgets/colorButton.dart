import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../res/colors.dart';

class ColorRoundedButton extends StatelessWidget{
  String text;
  Color? c;
  Color? textColor;
  double? radius;
  Function() onPressed;
  ColorRoundedButton( this.text, this.onPressed, {this.c, this.radius, this.textColor, super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(padding: EdgeInsets.zero),
        onPressed: ()=>onPressed(),
        child: Container(
          height: 46,
          decoration:  BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(radius??23)),
              gradient: c==null?const LinearGradient(
                  colors: [AppColors.gradientStart, AppColors.gradientEnd]
              ):null,
            color: c
          ),
            child: Center(child: Text(text, style: TextStyle(color: textColor??Colors.white),))
        )
    );
  }

}
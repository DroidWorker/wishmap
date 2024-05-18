import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wishmap/res/colors.dart';

class OutlinedGradientButton extends StatelessWidget{
  OutlinedGradientButton(this.text, this.onTap, {super.key, this.widgetBeforeText, this.filledButtonColor});

  String text;
  Widget? widgetBeforeText;
  Color? filledButtonColor;
  Function() onTap;
  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(padding: EdgeInsets.zero, backgroundColor: filledButtonColor),
        onPressed: ()=>onTap(),
        child: filledButtonColor==null?ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => const LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd]).createShader(
            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
          ),
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              border: Border.all(width: 2),
                borderRadius: const BorderRadius.all(Radius.circular(23))
            ),
            child: Center(child: Row(mainAxisSize: MainAxisSize.min,
              children: [
                widgetBeforeText??const SizedBox(),
                Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),)
              ],)),
          ),
        ):
        Center(child: Row(mainAxisSize: MainAxisSize.min,
            children: [
              widgetBeforeText??const SizedBox(),
              Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),)
            ],),
        )
    );
  }
}
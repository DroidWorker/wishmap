import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wishmap/res/colors.dart';

class OutlinedGradientButton extends StatelessWidget{
  OutlinedGradientButton(this.text, this.onTap, {super.key, this.widgetBeforeText});

  String text;
  Widget? widgetBeforeText;
  Function() onTap;
  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: ()=>onTap(),
        child: ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => const LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd]).createShader(
            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
          ),
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              border: Border.all(width: 3),
                borderRadius: const BorderRadius.all(Radius.circular(23))
            ),
            child: Center(child: Row(mainAxisSize: MainAxisSize.min,
              children: [
                widgetBeforeText??const SizedBox(),
                Text(text)
              ],)),
          ),
        )
    );
  }
}
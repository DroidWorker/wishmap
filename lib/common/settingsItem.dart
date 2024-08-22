import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wishmap/res/colors.dart';

Widget settingsWidget(String iconPath, String text, Function onTap){
  return InkWell(
    onTap: (){
      onTap();
    },
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.grey)
        )
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Container(
              width: 30, height: 30,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: AppColors.oceanBgColor),
              child: iconPath.contains(".svg")?SvgPicture.asset(iconPath,fit: BoxFit.scaleDown, width: 20, height: 20,):Image.asset(iconPath),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16),)),
          const Icon(Icons.arrow_forward_ios_outlined, size: 25, color: AppColors.darkGrey)
        ],
      ),
    ),
  );
}
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../res/colors.dart';

Widget getButton(String num){
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      border: Border.all(width: 1, color: AppColors.grey)
    ),
    child: Center(child: Text(num, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w600))),
  );
}
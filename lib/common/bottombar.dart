import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'custom_bottom_button.dart';

class BottomBar extends StatelessWidget{
  BottomBar({required this.onTasksTap, required this.onAimsTap, required this.onMapTap, required this.onWishesTap, required this.onDiaryTap});

  Function() onTasksTap;
  Function() onAimsTap;
  Function() onMapTap;
  Function() onWishesTap;
  Function() onDiaryTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(15))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CustomBottomButton(
              onPressed: ()=>onTasksTap(),
              icon: Image.asset('assets/icons/bot_task.png', height: 24, width: 24),
              label: "Задачи"
          ),
          CustomBottomButton(
              onPressed: ()=>onAimsTap(),
              icon: Image.asset('assets/icons/bot_aim.png', height: 24, width: 24),
              label: "Цели"
          ),
          IconButton(onPressed: ()=>onMapTap(), icon: Image.asset('assets/icons/bot_center.png')),
          CustomBottomButton(
              onPressed: ()=>onWishesTap(),
              icon: Image.asset('assets/icons/bot_wishes.png', height: 24, width: 24),
              label: "Желания"
          ),
          CustomBottomButton(
              onPressed: ()=>onDiaryTap(),
              icon: Image.asset('assets/icons/bot_diary.png', height: 24, width: 24),
              label: "Дневник"
          ),
        ],
      ),
    );
  }
}
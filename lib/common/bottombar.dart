import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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
              icon: SvgPicture.asset('assets/icons/tasks.svg', height: 24, width: 24),
              label: "Задачи"
          ),
          CustomBottomButton(
              onPressed: ()=>onAimsTap(),
              icon: SvgPicture.asset('assets/icons/goals.svg', height: 24, width: 24),
              label: "Цели"
          ),
          IconButton(onPressed: ()=>onMapTap(), padding: EdgeInsets.zero, constraints: const BoxConstraints(), icon: SvgPicture.asset('assets/icons/map.svg',  width: 58, height: 47,)),
          CustomBottomButton(
              onPressed: ()=>onWishesTap(),
              icon: SvgPicture.asset('assets/icons/favourites.svg', height: 24, width: 24),
              label: "Желания"
          ),
          CustomBottomButton(
              onPressed: ()=>onDiaryTap(),
              icon: SvgPicture.asset('assets/icons/diary.svg', height: 24, width: 24),
              label: "Дневник"
          ),
        ],
      ),
    );
  }
}
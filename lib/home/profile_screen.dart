import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wishmap/common/aimitem_widget.dart';
import 'package:wishmap/common/wishItem_widget.dart';
import '../data/models.dart';
import '../navigation/navigation_block.dart';
import '../res/colors.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({super.key, required this.pi});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();

  ProfileItem pi;
}

class _ProfileScreenState extends State<ProfileScreen>{
  bool page = false;//false - Исполнено true - Все ж
  Random r = Random();
  late Color bgColor;// елания

  late ProfileItem pi = widget.pi;

  @override
  void initState() {
    bgColor = Color.fromARGB(255, r.nextInt(255), r.nextInt(255), r.nextInt(255));
    pi = ProfileItem(id: 0, name: "name", surname: "surname", email: "email@e.mail", bgcolor: bgColor);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(child:Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                child: const Text("<Назад", style: TextStyle(color: AppColors.greytextColor),),
                onTap: (){
                  BlocProvider.of<NavigationBloc>(context)
                      .add(NavigateToMainScreenEvent());
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(5, 15, 5, 15),
                child: Row(children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: pi.bgcolor, // Use your randomly generated color
                      boxShadow: [
                        BoxShadow(
                          color: pi.bgcolor,
                          blurRadius: 2, // Adjust the glow effect as needed
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        pi.name.characters.first.toUpperCase() + pi.surname.characters.first.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 25,
                          color: Colors.black, // Text color
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text("name"),
                    Text("surname"),
                    Text("email", style: TextStyle(fontSize: 10),)
                  ],)
                ],),
              ),
              const Divider(
                height: 3,
                color: AppColors.dividerGreyColor,
                indent: 5,
                endIndent: 5,
              ),
              const SizedBox(height: 5),
              const Text("Еще", style: TextStyle(fontSize: 10, color: AppColors.greytextColor)),
              const SizedBox(height: 5),
              GestureDetector(
                child: const Text("Ваш уровень(баллы)"),
                onTap: (){},
              ),
              GestureDetector(
                child: const Text("Пройти тест"),
                onTap: (){},
              ),
              GestureDetector(
                child: const Text("Колесо жизни"),
                onTap: (){},
              ),
              GestureDetector(
                child: const Text("Статистика"),
                onTap: (){},
              ),
              const SizedBox(height: 10),
              const Text("Настройки", style: TextStyle(fontSize: 10, color: AppColors.greytextColor))
            ],
          ),
        ))
    );
  }
}

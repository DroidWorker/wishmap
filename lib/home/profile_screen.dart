import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../ViewModel.dart';
import '../data/models.dart';
import '../navigation/navigation_block.dart';
import '../res/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();

}

class _ProfileScreenState extends State<ProfileScreen>{
  bool page = false;//false - Исполнено true - Все ж
  Random r = Random();
  late Color bgColor;// елания

  late ProfileItem pi;

  @override
  void initState() {
    bgColor = Color.fromARGB(255, r.nextInt(255), r.nextInt(255), r.nextInt(255));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appViewModel = Provider.of<AppViewModel>(context);
    if(appViewModel.profileData!=null) {
      pi = ProfileItem(id: appViewModel.profileData!.id,
          name: appViewModel.profileData!.name,
          surname: appViewModel.profileData!.surname,
          email: appViewModel.authData!.login,
          bgcolor: bgColor);
    }

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
                  if(appViewModel.mainScreenState!=null)appViewModel.startMainScreen(appViewModel.mainScreenState!.moon);
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text(pi.name),
                    Text(pi.surname),
                    Text(pi.email , style: const TextStyle(fontSize: 10),)
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

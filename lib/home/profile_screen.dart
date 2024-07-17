import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/data/static.dart';
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
              IconButton(onPressed: (){
                appViewModel.backPressedCount++;
                appViewModel.mainCircles.clear();
                if(appViewModel.mainScreenState!=null)appViewModel.startMainScreen(appViewModel.mainScreenState!.moon);
                if(appViewModel.backPressedCount==appViewModel.settings.quoteupdateFreq){
                  appViewModel.backPressedCount=0;
                  appViewModel.hint=quoteBack[Random().nextInt(367)];
                }
                BlocProvider.of<NavigationBloc>(context)
                    .add(NavigateToMainScreenEvent());
              }, icon: const Icon(Icons.arrow_back_ios)),
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
              const SizedBox(height: 5),
              const Text("Настройки", style: TextStyle(fontSize: 10, color: AppColors.greytextColor)),
              const SizedBox(height: 5),
              const Divider(
                height: 3,
                color: AppColors.dividerGreyColor,
                indent: 5,
                endIndent: 5,
              ),
              const SizedBox(height: 5),
             InkWell(
               onTap: (){
                 BlocProvider.of<NavigationBloc>(context)
                     .add(NavigateToMainSettingsScreenEvent());
               },
               child: const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                 Text("Основные"),
                 Icon(Icons.arrow_forward_ios)
               ],),
             ),
              InkWell(
                onTap: (){
                  BlocProvider.of<NavigationBloc>(context)
                      .add(NavigateToAlarmScreenEvent());
                },
                child: const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  Text("Напоминания"),
                  Icon(Icons.arrow_forward_ios)
                ],),
              ),
              InkWell(
                onTap: (){},
                child: const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  Text("Пин-код"),
                  Icon(Icons.arrow_forward_ios)
                ],),
              ),
              InkWell(
                onTap: (){
                  BlocProvider.of<NavigationBloc>(context)
                      .add(NavigateToSoundsSettingsScreenEvent());
                },
                child: const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  Text("Звуки"),
                  Icon(Icons.arrow_forward_ios)
                ],),
              ),
              const SizedBox(height: 10,),
              const Text("Обо мне", style: TextStyle(fontSize: 10, color: AppColors.greytextColor)),
              const SizedBox(height: 5),
              const Divider(
                height: 3,
                color: AppColors.dividerGreyColor,
                indent: 5,
                endIndent: 5,
              ),
              const SizedBox(height: 5),
              InkWell(
                onTap: (){
                  BlocProvider.of<NavigationBloc>(context)
                      .add(NavigateToPersonalSettingsScreenEvent());
                },
                child: const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  Text("Личные данные"),
                  Icon(Icons.arrow_forward_ios)
                ],),
              ),
              InkWell(
                onTap: (){},
                child: const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  Text("Тестирование"),
                  Icon(Icons.arrow_forward_ios)
                ],),
              ),
              InkWell(
                onTap: (){},
                child: const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  Text("Уровень"),
                  Icon(Icons.arrow_forward_ios)
                ],),
              ),
              const SizedBox(height: 10,),
              const Text("Помощь", style: TextStyle(fontSize: 10, color: AppColors.greytextColor)),
              const SizedBox(height: 5),
              const Divider(
                height: 3,
                color: AppColors.dividerGreyColor,
                indent: 5,
                endIndent: 5,
              ),
              const SizedBox(height: 5),
              InkWell(
                onTap: (){},
                child: const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  Text("Обращения"),
                  Icon(Icons.arrow_forward_ios)
                ],),
              ),
              InkWell(
                onTap: (){},
                child: const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  Text("Частые вопросы"),
                  Icon(Icons.arrow_forward_ios)
                ],),
              ),
              InkWell(
                onTap: (){},
                child: const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  Text("Связаться с нами"),
                  Icon(Icons.arrow_forward_ios)
                ],),
              ),
              InkWell(
                onTap: (){},
                child: const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  Text("Пожелания"),
                  Icon(Icons.arrow_forward_ios)
                ],),
              ),
              const SizedBox(height: 5),
              const Divider(
                height: 3,
                color: AppColors.dividerGreyColor,
                indent: 5,
                endIndent: 5,
              ),
              const SizedBox(height: 5),
              InkWell(
                onTap: () async {
                  await appViewModel.signOut().then((value){
                    BlocProvider.of<NavigationBloc>(context).clearHistory();
                    BlocProvider.of<NavigationBloc>(context)
                        .add(NavigateToAuthScreenEvent());
                  });
                },
                child: const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Выход"),
                    Icon(Icons.arrow_forward_ios)
                  ],),
              ),
            ],
          ),
        ))
    );
  }
}

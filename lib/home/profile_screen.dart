import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/data/static.dart';
import '../ViewModel.dart';
import '../common/settingsItem.dart';
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      style: const ButtonStyle(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap, // the '2023' part
                      ),
                      icon: const Icon(Icons.keyboard_arrow_left, size: 28, color: AppColors.gradientStart),
                      onPressed: () {
                        appViewModel.backPressedCount++;
                        appViewModel.mainCircles.clear();
                        if(appViewModel.mainScreenState!=null)appViewModel.startMainScreen(appViewModel.mainScreenState!.moon);
                        if(appViewModel.backPressedCount==appViewModel.settings.quoteupdateFreq){
                          appViewModel.backPressedCount=0;
                          appViewModel.hint=quoteBack[Random().nextInt(367)];
                        }
                        BlocProvider.of<NavigationBloc>(context)
                            .add(NavigateToMainScreenEvent());
                      }
                  ),
                  const Text("Настройки", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(width: 28),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Приложение", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          settingsWidget("assets/icons/settings_settings.svg" ,"Основное", (){
                            BlocProvider.of<NavigationBloc>(context)
                              .add(NavigateToMainSettingsScreenEvent());
                          }),
                          settingsWidget("assets/icons/setting_alarm.svg" ,"Будильник", (){
                            appViewModel.getAlarms();
                            BlocProvider.of<NavigationBloc>(context)
                                .add(NavigateToAlarmScreenEvent());
                          }),
                          settingsWidget("assets/icons/setting_key.svg" ,"Пароль", (){
                            BlocProvider.of<NavigationBloc>(context)
                                .add(NavigateToLockSettingsScreenEvent());
                          }),
                          settingsWidget("assets/icons/setting_music.svg" ,"Музыка на главном", (){
                            BlocProvider.of<NavigationBloc>(context)
                                .add(NavigateToSoundsSettingsScreenEvent());
                          }),
                                       const SizedBox(height: 24),
                          const Text("Профиль", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          settingsWidget("assets/icons/setting_personal.svg" ,"Личные данные", (){
                            BlocProvider.of<NavigationBloc>(context)
                                .add(NavigateToPersonalSettingsScreenEvent());
                          }),
                          settingsWidget("assets/icons/setting_testing.svg" ,"Мое тестирование", (){}),
                          settingsWidget("assets/icons/setting_level.svg" ,"Уровень", (){}),
                          const SizedBox(height: 24),
                                    const Text("Помощь", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 8),
                                    /*settingsWidget("assets/icons/setting_message.svg" ,"Обращения", (){}),
                                    settingsWidget("assets/icons/seting_question.svg" ,"Частые вопросы", (){
                                      appViewModel.fetchQ();
                                      BlocProvider.of<NavigationBloc>(context)
                                          .add(NavigateToQuestionsScreenEvent());
                                    }),*/
                                    settingsWidget("assets/icons/setting_mail.svg" ,"Связаться с нами", (){
                                      BlocProvider.of<NavigationBloc>(context)
                                          .add(NavigateToContactScreenEvent());
                                    }),
                                    /*settingsWidget("assets/icons/setting_feedback.svg" ,"Пожелания", (){
                                      BlocProvider.of<NavigationBloc>(context)
                                          .add(NavigateToProposalScreenEvent());
                                    }),*/
                                    const SizedBox(height: 24),
                        ],
                      ),
                    ),
                    InkWell(
                        onTap: () async {
                          appViewModel.alarmChecked = false;
                          appViewModel.disableAllAlarms();
                          await appViewModel.signOut().then((value){
                            BlocProvider.of<NavigationBloc>(context).clearHistory();
                            BlocProvider.of<NavigationBloc>(context)
                                .add(NavigateToAuthScreenEvent());
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset("assets/icons/profile_exit.svg"),
                            const Text(" Выйти из аккаунта", style: TextStyle(color: AppColors.redTextColor))
                          ],
                        )),
                  ],
                ),
              )
            ],
          ),
        ))
    );
  }
}

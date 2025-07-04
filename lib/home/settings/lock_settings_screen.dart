import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/ViewModel.dart';
import 'package:wishmap/common/switch_widget.dart';
import 'package:wishmap/interface_widgets/colorButton.dart';

import '../../common/numbutton_simplewidget.dart';
import '../../data/models.dart';
import '../../navigation/navigation_block.dart';
import '../../res/colors.dart';

class LockSettingsScreen extends StatefulWidget{

  @override
  LockSettingsScreenState createState() => LockSettingsScreenState();
}

class LockSettingsScreenState extends State<LockSettingsScreen>{
  AppViewModel? appViewModel;
  LockParams? lockParams;
  String password= "";
  bool fingerprintState = false;
  String passwordRepeat = "";
  String message = "Введите пароль";

  @override
  Widget build(BuildContext context) {
    appViewModel??=Provider.of<AppViewModel>(context);
    lockParams??= appViewModel?.lockParams;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding:const EdgeInsets.all(16),
          child: Column(
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
                        BlocProvider.of<NavigationBloc>(context).handleBackPress();
                      }
                  ),
                  const Text("Пароль", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(width: 28),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock),
                  MySwitch(key: UniqueKey(),value: appViewModel?.lockEnabled==true, onChanged: (state){
                    appViewModel?.lockParams = LockParams(password: "", allowFingerprint: false);
                    setState(() {
                      appViewModel?.lockEnabled=false;
                    });
                  })
                ],
              ),
              const Spacer(),
              Text(message, style: const TextStyle(fontSize: 24)),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(width: 40, height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: password.isEmpty?AppColors.blueTextColor:AppColors.darkGrey)
                  ),
                  child: Center(child: Text(password.isNotEmpty?password[0]:""))),
                  Container(width: 40, height: 50,
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: password.length==1?AppColors.blueTextColor:AppColors.darkGrey)
                      ),
                      child: Center(child: Text(password.length>=2?password[1]:""))),
                  Container(width: 40, height: 50,
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: password.length==2?AppColors.blueTextColor:AppColors.darkGrey)
                      ),
                      child: Center(child: Text(password.length>=3?password[2]:""))),
                  Container(width: 40, height: 50,
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: password.length==3?AppColors.blueTextColor:AppColors.darkGrey)
                      ),
                      child: Center(child: Text(password.length>=4?password[3]:"")))
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: InkWell(borderRadius: BorderRadius.circular(40), child: getButton("1"), onTap: (){if(password.length<4) {
                      setState(() {
                      password+="1";
                    });
                    }}),
                  ),
                  Expanded(
                    child: InkWell(borderRadius: BorderRadius.circular(40), child: getButton("2"), onTap: (){if(password.length<4) {
                      setState(() {
                      password+="2";
                    });
                    }}),
                  ),
                  Expanded(
                    child: InkWell(borderRadius: BorderRadius.circular(40), child: getButton("3"), onTap: (){if(password.length<4) {
                      setState(() {
                      password+="3";
                    });
                    }}),
                  )
                ],),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: InkWell(borderRadius: BorderRadius.circular(40), child: getButton("4"), onTap: (){if(password.length<4) {
                      setState(() {
                      password+="4";
                    });
                    }}),
                  ),
                  Expanded(
                    child: InkWell(borderRadius: BorderRadius.circular(40), child: getButton("5"), onTap: (){if(password.length<4) {
                      setState(() {
                      password+="5";
                    });
                    }}),
                  ),
                  Expanded(
                    child: InkWell(borderRadius: BorderRadius.circular(40), child: getButton("6"), onTap: (){if(password.length<4) {
                      setState(() {
                      password+="6";
                    });
                    }}),
                  )
                ],),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: InkWell(borderRadius: BorderRadius.circular(40), child: getButton("7"), onTap: (){if(password.length<4) {
                      setState(() {
                      password+="7";
                    });
                    }}),
                  ),
                  Expanded(
                    child: InkWell(borderRadius: BorderRadius.circular(40), child: getButton("8"), onTap: (){if(password.length<4) {
                      setState(() {
                      password+="8";
                    });
                    }}),
                  ),
                  Expanded(
                    child: InkWell(borderRadius: BorderRadius.circular(40), child: getButton("9"), onTap: (){if(password.length<4) {
                      setState(() {
                      password+="9";
                    });
                    }}),
                  )
                ],),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: InkWell(borderRadius: BorderRadius.circular(40), child: Container(margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), width: 50, height: 50, child: const Center(child: Icon(Icons.backspace, color: Colors.white))), onTap: (){setState(() {
                      password=password.substring(0, password.length-1);
                    });}),
                  ),
                  Expanded(
                    child: InkWell(borderRadius: BorderRadius.circular(40), child: getButton("0"), onTap: (){if(password.length<4) {
                      setState(() {
                      password+="0";
                    });
                    }}),
                  ),
                  const Expanded(child: SizedBox(width: 80))
                ],),
              /*const SizedBox(height: 16),
              SquareCheckbox("Fingerprint", (state) async {
                final LocalAuthentication auth = LocalAuthentication();
                final bool canAuthenticate = await auth.canCheckBiometrics || await auth.isDeviceSupported();
                lockParams?.allowFingerprint=canAuthenticate?state:false;
              }),*/
              const SizedBox(height: 16),
              ColorRoundedButton(lockParams!.password.isEmpty?"Сохранить":"Сбросить пароль", (){
                appViewModel?.addError("Для доступа к расширенному функционалу воспользуйтесь мобильным приложением!");
              })
            ],
          )
        ),
      ),
    );
  }
}
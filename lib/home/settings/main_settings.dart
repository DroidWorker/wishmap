import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../ViewModel.dart';
import '../../navigation/navigation_block.dart';
import '../../res/colors.dart';

class MainSettings extends StatefulWidget{

  @override
  MainSettingsState createState() => MainSettingsState();
}

class MainSettingsState extends State<MainSettings>{
  @override
  Widget build(BuildContext context) {
    final appViewModel = Provider.of<AppViewModel>(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(onPressed: (){
                    if(appViewModel.mainScreenState!=null)appViewModel.startMainScreen(appViewModel.mainScreenState!.moon);
                    BlocProvider.of<NavigationBloc>(context).handleBackPress();
                  }, icon: const Icon(Icons.arrow_back_ios, size: 15,)),
                  const Text("Основные"),
                  const SizedBox(width: 15,)
                ],),
              const SizedBox(height: 10,),
              const Center(child: Text("Актуализация Я", style: TextStyle(fontSize: 18, color: AppColors.greytextColor),),),
              const SizedBox(height: 8,),
              const Center(child: Text("нажатие кнопки 'Осознать' при входе в экран редакции центрального элемента при актуализации карты (последняя из ранее актуальных)", style: TextStyle(fontSize: 14, color: AppColors.greytextColor),),),
              const SizedBox(height: 10,),
              buildSettingItem("Быстрая", "при двойном быстром нажатии лейбла 'Я'", false, (changed) => null),
              const SizedBox(height: 5,),
              const Divider(
                height: 3,
                color: AppColors.dividerGreyColor,
                indent: 5,
                endIndent: 5,
              ),
              const SizedBox(height: 10,),
              const Center(child: Text("Актуализация сфер", style: TextStyle(fontSize: 18, color: AppColors.greytextColor),),),
              const SizedBox(height: 8,),
              const Center(child: Text("при нажатии кнопки 'Представить' при входе в экран редакции сферы при актуализации наследованных задач из последней ранее актуальной карты", style: TextStyle(fontSize: 14, color: AppColors.greytextColor),),),
              const SizedBox(height: 10,),
              buildSettingItem("Автоматическая", "при актуализации вышестоящего 'Я'", false, (changed) => null),
              const Center(child: Text("или")),
              buildSettingItem("Автоматическая", "при актуализации нижестоящего желания", false, (changed) => null),
              const SizedBox(height: 10),
              buildSettingItem("Быстая", "двойным нажатием по лейблу сферы", false, (changed) => null),
              const SizedBox(height: 5,),
              const Divider(
                height: 3,
                color: AppColors.dividerGreyColor,
                indent: 5,
                endIndent: 5,
              ),
              const SizedBox(height: 10,),
              const Center(child: Text("Актуализация желаний", style: TextStyle(fontSize: 18, color: AppColors.greytextColor),),),
              const SizedBox(height: 8,),
              const Center(child: Text("нажатие кнопки 'Воплотить' при входе в экран редакции желания при актуализации наследованных желаний из последней ранее актуальной карты", style: TextStyle(fontSize: 14, color: AppColors.greytextColor),),),
              const SizedBox(height: 10,),
              buildSettingItem("Автоматическая", "при актуализации вышестоящего 'над-желания'", false, (changed) => null),
              const Center(child: Text("или")),
              buildSettingItem("Автоматическая", "при актуализации нижестоящего 'под-желания'", false, (changed) => null),
              const SizedBox(height: 10),
              buildSettingItem("Быстая", "двойным нажатием по лейблу сферы", false, (changed) => null),
              const SizedBox(height: 5,),
              const Divider(
                height: 3,
                color: AppColors.dividerGreyColor,
                indent: 5,
                endIndent: 5,
              ),
              const SizedBox(height: 10,),
              const Center(child: Text("Актуализация задач", style: TextStyle(fontSize: 18, color: AppColors.greytextColor),),),
              const SizedBox(height: 8,),
              const Center(child: Text("нажатие кнопки 'Актуализировать' при входе в экран редакции задачи при актуализации наследованных желаний из последней ранее актуальной карты", style: TextStyle(fontSize: 14, color: AppColors.greytextColor),),),
              const SizedBox(height: 10,),
              buildSettingItem("Автоматическая", "при актуализации вышестоящего желания", false, (changed) => null),
              const Center(child: Text("или")),
              buildSettingItem("Ручная", "при актуализации вышестоящего 'желания'", false, (changed) => null),
              const SizedBox(height: 10),
              const Divider(
                height: 3,
                color: AppColors.dividerGreyColor,
                indent: 5,
                endIndent: 5,
              ),
              const SizedBox(height: 10,),
              const Center(child: Text("Оюновление цитат", style: TextStyle(fontSize: 18, color: AppColors.greytextColor),),),
              const SizedBox(height: 8,),
              const Center(child: Text("сообщение в поле подсказок, выпадающее при возвращении в карту", style: TextStyle(fontSize: 14, color: AppColors.greytextColor),),),
              const SizedBox(height: 10,),
              buildSettingItem("Редко", "с  каждым 20-м возвращением", false, (changed) => null),
              const Center(child: Text("или")),
              buildSettingItem("Средне", "с  каждым 10-м возвращением", false, (changed) => null),
              const Center(child: Text("или")),
              buildSettingItem("Часто", "с  каждым 5-м возвращением",false,  (changed) => null),
              const SizedBox(height: 5,),
            ],
          ),
        )
      ),
    );
  }

  Widget buildSettingItem(String title, String subtitle, bool isActive, Function(bool changed) onChanged){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
      Expanded(child:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 20, color: Colors.black),),
            Text(subtitle, maxLines: 2, style: const TextStyle(fontSize: 14, color: AppColors.greytextColor),)
          ],
      )),
      Switch(
        value: isActive,
        onChanged: (changed){onChanged(changed);},
      )
    ],);
  }
}
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../ViewModel.dart';
import '../../common/switch_widget.dart';
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
                        BlocProvider.of<NavigationBloc>(context).handleBackPress();
                      }
                  ),
                  const Text("Основнoе", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(width: 28),
                ],
              ),
              const SizedBox(height: 10,),
              const Text("Актуализация Я", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8,),
              const Center(child: Text("нажатие кнопки 'Осознать' при входе в экран редакции центрального элемента при актуализации карты (последняя из ранее актуальных)", style: TextStyle(fontSize: 12),),),
              const SizedBox(height: 10,),
              buildSettingItem("Быстрая актуализация", "Двойное нажатие на лейбл “Я”", appViewModel.settings.fastActMainSphere, (changed){appViewModel.settings.fastActMainSphere=changed;appViewModel.saveSettings();}),
              const SizedBox(height: 24,),
              const Divider(
                height: 3,
                color: AppColors.grey,
              ),
              const SizedBox(height: 16),
              const Text("Актуализация сфер", style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600)),
              const SizedBox(height: 8,),
              const Center(child: Text("При нажатии кнопки “Представить” экран редакции сферы при активации наследственных задач из последней актуальной карты", style: TextStyle(fontSize: 12),),),
              const SizedBox(height: 10,),
              buildSettingItem("Автоматическая", "При актуализации вышестоящего “Я”", appViewModel.settings.sphereActualizingMode==0, (changed){
                appViewModel.settings.sphereActualizingMode=changed?0:1;
                appViewModel.saveSettings();
                setState(() {});
              }),
              const SizedBox(height: 10),
              buildSettingItem("Автоматическая", "При актуализации нижестоящего желания", appViewModel.settings.sphereActualizingMode==1, (changed){
                appViewModel.settings.sphereActualizingMode=changed?1:0;
                appViewModel.saveSettings();
                setState(() {});
              }),
              const SizedBox(height: 10),
              buildSettingItem("Быстая", "Двойное нажатие по лейблу “Сфера”", appViewModel.settings.fastActSphere, (changed){appViewModel.settings.fastActSphere=changed;appViewModel.saveSettings();}),
              const SizedBox(height: 24),
              const Divider(
                height: 3,
                color: AppColors.grey,
              ),
              const SizedBox(height: 16),
              const Text("Актуализация желаний", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8,),
              const Center(child: Text("Нажатие кнопки “Воплотить” при входе на экран редакции желания при актуализации наследственных желаний из последней ранее актуальной карты", style: TextStyle(fontSize: 12),),),
              const SizedBox(height: 10,),
              buildSettingItem("Автоматическая", "При актуализации вышестоящего “наджелания”", appViewModel.settings.wishActualizingMode==0, (changed){setState(() {
                appViewModel.settings.wishActualizingMode=changed?0:1;
                appViewModel.saveSettings();
              });}),
              const Center(child: Text("или")),
              buildSettingItem("Автоматическая", "При актуализации нижестоящего “поджелания”", appViewModel.settings.wishActualizingMode==1, (changed){setState(() {
                appViewModel.settings.wishActualizingMode=changed?1:0;
                appViewModel.saveSettings();
              });}),
              const SizedBox(height: 10),
              buildSettingItem("Быстая", "Двойное нажатие по лейблу “Сфера”", appViewModel.settings.fastActWish, (changed){appViewModel.settings.fastActWish=changed;appViewModel.saveSettings();}),
              const SizedBox(height: 24),
              const Divider(
                height: 3,
                color: AppColors.grey,
              ),
              const SizedBox(height: 16),
              const Text("Актуализация задачи", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8,),
              const Center(child: Text("Нажатие кнопки “Актуализировать” при входе на экран редакции желания при актуализации наследственных желаний из последней ранее актуальной карты", style: TextStyle(fontSize: 14, color: AppColors.greytextColor),),),
              const SizedBox(height: 10,),
              buildSettingItem("Автоматическая", "При актуализации вышестоящего “наджелания”", appViewModel.settings.taskActualizingMode==0, (changed){setState(() {
                appViewModel.settings.taskActualizingMode=changed?0:1;
                appViewModel.saveSettings();
              });}),
              const Center(child: Text("или")),
              buildSettingItem("Ручная", "При актуализации вышестоящего “желания”", appViewModel.settings.taskActualizingMode==1, (changed){setState(() {
                appViewModel.settings.taskActualizingMode=changed?1:0;
                appViewModel.saveSettings();
              });}),
              const SizedBox(height: 24),
              const Divider(
                height: 3,
                color: AppColors.grey,
              ),
              const SizedBox(height: 16),
              const Text("Обновление цитат", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8,),
              const Center(child: Text("Сообщение в поле подсказок, выпадающее при возвращении в карту", style: TextStyle(fontSize: 14, color: AppColors.greytextColor),),),
              const SizedBox(height: 10,),
              buildSettingItem("Редко", "С каждым 20-м возвращением", appViewModel.settings.quoteupdateFreq==20, (changed){setState(() {
                appViewModel.settings.quoteupdateFreq=changed?20:10;
                appViewModel.saveSettings();
              });}),
              const Center(child: Text("или")),
              buildSettingItem("Средне", "С каждым 10-м возвращением", appViewModel.settings.quoteupdateFreq==10, (changed){setState(() {
                appViewModel.settings.quoteupdateFreq=changed?10:5;
                appViewModel.saveSettings();
              });}),
              const Center(child: Text("или")),
              buildSettingItem("Часто", "С каждым 5-м возвращением", appViewModel.settings.quoteupdateFreq==5, (changed){setState(() {
                appViewModel.settings.quoteupdateFreq=changed?5:20;
                appViewModel.saveSettings();
              });}),
              const SizedBox(height: 24),
              const Divider(
                height: 3,
                color: AppColors.grey,
              ),
              const SizedBox(height: 16),
              const Text("Вид дерева объектов", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10,),
              buildSettingItem("Старый", "", appViewModel.settings.treeView==0, (changed){setState(() {
                appViewModel.settings.treeView=changed?0:1;
                appViewModel.saveSettings();
              });}),
              const Center(child: Text("или")),
              buildSettingItem("Новый", "", appViewModel.settings.treeView==1, (changed){setState(() {
                appViewModel.settings.treeView=changed?1:0;
                appViewModel.saveSettings();
              });}),
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
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),),
            Text(subtitle, maxLines: 2, style: const TextStyle(fontSize: 14, color: Colors.black),)
          ],
      )),
      MySwitch(
        value: isActive,
        onChanged: (changed){onChanged(changed);}
      )
    ],);
  }
}
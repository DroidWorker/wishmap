import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/common/checkbox_widget.dart';

import '../../ViewModel.dart';
import '../../navigation/navigation_block.dart';
import '../../res/colors.dart';

class PersonalSettings extends StatefulWidget{

  @override
  PersonalSettingsState createState() => PersonalSettingsState();
}

class PersonalSettingsState extends State<PersonalSettings>{
  TextEditingController _name = TextEditingController();
  TextEditingController _sname = TextEditingController();
  TextEditingController _lname = TextEditingController();
  TextEditingController _phone = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _tg = TextEditingController();

  List<String> days = List.generate(31, (index) => (index + 1).toString());
  List<String> months = List.generate(12, (index) => (index + 1).toString());
  List<String> years = List.generate(90, (index) => (1950 + index).toString());

  String selectedDay = '1';
  String selectedMonth = '1';
  String selectedYear = '1970';
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
                  IconButton(onPressed: (){
                    if(appViewModel.mainScreenState!=null)appViewModel.startMainScreen(appViewModel.mainScreenState!.moon);
                    BlocProvider.of<NavigationBloc>(context).handleBackPress();
                  }, icon: const Icon(Icons.arrow_back_ios, size: 15,)),
                  const Text("Личные данные"),
                  const SizedBox(width: 15,)
                ],),
              const SizedBox(height: 10,),
              const Text("Имя", style: TextStyle(color: AppColors.greytextColor),),
              TextField(
                controller: _name,
                style: const TextStyle(color: Colors.black), // Черный текст ввода
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.fieldFillColor,
                  contentPadding:const EdgeInsets.fromLTRB(10,0,10,0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8,),
              const SizedBox(height: 10,),
              const Text("Фамилия", style: TextStyle(color: AppColors.greytextColor),),
              TextField(
                controller: _sname,
                style: const TextStyle(color: Colors.black), // Черный текст ввода
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.fieldFillColor,
                  contentPadding:const EdgeInsets.fromLTRB(10,0,10,0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8,),
              const SizedBox(height: 10,),
              const Text("Отчество", style: TextStyle(color: AppColors.greytextColor),),
              TextField(
                controller: _lname,
                style: const TextStyle(color: Colors.black), // Черный текст ввода
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.fieldFillColor,
                  contentPadding:const EdgeInsets.fromLTRB(10,0,10,0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8,),
              const Text("Дата рождения", style: TextStyle(color: AppColors.greytextColor),),
              Row(
                children: [
                  DropdownButton(
                    items: days.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? val) {
                      setState(() {
                        selectedDay = val!;
                      });
                    },
                    value: selectedDay,
                    icon: const Icon(Icons.arrow_drop_down_sharp),
                  ),
                  const SizedBox(width: 3,),
                  DropdownButton(
                    items: months.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? val) {
                      setState(() {
                        selectedMonth = val!;
                      });
                    },
                    value: selectedMonth,
                    icon: const Icon(Icons.arrow_drop_down_sharp),
                  ),
                  const SizedBox(width: 3,),
                  DropdownButton(
                    items: years.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? val) {
                      setState(() {
                        selectedYear = val!;
                      });
                    },
                    value: selectedYear,
                    icon: const Icon(Icons.arrow_drop_down_sharp),
                  ),
                ],
              ),
              const SizedBox(height: 8,),
              const Text("Пол", style: TextStyle(color: AppColors.greytextColor),),
              Row(
                children: [
                  CustomCheckbox(isCircle: true, onChanged: (value){}),
                  const Text("женский"),
                  const SizedBox(width: 5),
                  CustomCheckbox(isCircle: true, onChanged: (value){}),
                  const Text("мужской"),
                ],
              ),
              const SizedBox(height: 8,),
              const Text("Номер телефона", style: TextStyle(color: AppColors.greytextColor),),
              TextField(
                controller: _phone,
                style: const TextStyle(color: Colors.black), // Черный текст ввода
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.fieldFillColor,
                  contentPadding:const EdgeInsets.fromLTRB(10,0,10,0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8,),
              const SizedBox(height: 10,),
              const Text("e-mail", style: TextStyle(color: AppColors.greytextColor),),
              TextField(
                controller: _email,
                style: const TextStyle(color: Colors.black), // Черный текст ввода
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.fieldFillColor,
                  contentPadding:const EdgeInsets.fromLTRB(10,0,10,0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8,),
              const SizedBox(height: 10,),
              const Text("telegram", style: TextStyle(color: AppColors.greytextColor),),
              TextField(
                controller: _tg,
                style: const TextStyle(color: Colors.black), // Черный текст ввода
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.fieldFillColor,
                  contentPadding:const EdgeInsets.fromLTRB(10,0,10,0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8,),
              CustomCheckbox(isCircle: false, onChanged: (value){}),
              const Text("я согласен(-на) на обработку персональных данных"),
              const SizedBox(height: 8,),
            ],
          ),
        )
      ),
    );
  }
}
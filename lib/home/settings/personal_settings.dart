import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/common/checkbox_widget.dart';
import 'package:wishmap/interface_widgets/sq_checkbox.dart';

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
          padding: const EdgeInsets.all(16),
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
                        appViewModel.mainCircles.clear();
                        if(appViewModel.mainScreenState!=null)appViewModel.startMainScreen(appViewModel.mainScreenState!.moon);
                        BlocProvider.of<NavigationBloc>(context).handleBackPress();
                      }
                  ),
                  const Text("Личные данные", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(width: 28),
                ],
              ),
              const SizedBox(height: 10,),
              const Text("Имя", style: TextStyle(fontWeight: FontWeight.w600),),
              const SizedBox(height: 4),
              TextField(
                controller: _name,
                style: const TextStyle(color: Colors.black), // Черный текст ввода
                decoration: InputDecoration(
                  hintText: "Введите имя",
                  filled: true,
                  fillColor: Colors.white,
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
              const SizedBox(height: 16),
              const Text("Фамилия", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              TextField(
                controller: _sname,
                style: const TextStyle(color: Colors.black), // Черный текст ввода
                decoration: InputDecoration(
                  hintText: "Введите фамилию",
                  filled: true,
                  fillColor: Colors.white,
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
              const SizedBox(height: 16),
              const Text("Отчество", style: TextStyle(fontWeight: FontWeight.w600),),
              const SizedBox(height: 4),
              TextField(
                controller: _lname,
                style: const TextStyle(color: Colors.black), // Черный текст ввода
                decoration: InputDecoration(
                  hintText: "Введите отчество",
                  filled: true,
                  fillColor: Colors.white,
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
              const SizedBox(height: 16),
              const Text("Дата рождения", style: TextStyle(fontWeight: FontWeight.w600),),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          iconSize: 0,
                          items: days.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text("  $value", textAlign: TextAlign.center),
                            );
                          }).toList(),
                          onChanged: (String? val) {
                            setState(() {
                              selectedDay = val!;
                            });
                          },
                          value: selectedDay,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 3,),
                  Container(
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          iconSize: 0,
                          items: months.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text("  $value", textAlign: TextAlign.center),
                            );
                          }).toList(),
                          onChanged: (String? val) {
                            setState(() {
                              selectedMonth = val!;
                            });
                          },
                          value: selectedMonth,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 3,),
                  Container(
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: DropdownButtonHideUnderline(child: DropdownButton(
                        iconSize: 0,
                        items: years.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(" $value", textAlign: TextAlign.center),
                          );
                        }).toList(),
                        onChanged: (String? val) {
                          setState(() {
                            selectedYear = val!;
                          });
                        },
                        value: selectedYear,
                        borderRadius: BorderRadius.circular(8),
                      ),
                                        ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              const Text("Пол", style: TextStyle(fontWeight:FontWeight.w600),),
              const SizedBox(height: 8),
              SquareCheckbox("Мужской", (state){

              }),
              SquareCheckbox("Женский", (state){

              }),
              const SizedBox(height: 16),
              const Text("Номер телефона", style: TextStyle(fontWeight: FontWeight.w600),),
              const SizedBox(height: 4),
              TextField(
                controller: _phone,
                style: const TextStyle(color: Colors.black), // Черный текст ввода
                decoration: InputDecoration(
                  hintText: "+7(999) 999-99-99",
                  filled: true,
                  fillColor: Colors.white,
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
              const SizedBox(height: 16),
              const Text("E-Mail", style: TextStyle(fontWeight: FontWeight.w600),),
              const SizedBox(height: 4),
              TextField(
                controller: _email,
                style: const TextStyle(color: Colors.black), // Черный текст ввода
                decoration: InputDecoration(
                  hintText: "example@exmp.ru",
                  filled: true,
                  fillColor: Colors.white,
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
              const SizedBox(height: 16),
              const Text("Telegram", style: TextStyle(fontWeight: FontWeight.w600),),
              const SizedBox(height: 4),
              TextField(
                controller: _tg,
                style: const TextStyle(color: Colors.black), // Черный текст ввода
                decoration: InputDecoration(
                  hintText: "@example",
                  filled: true,
                  fillColor: Colors.white,
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
              const SizedBox(height: 20),
              SquareCheckbox("Я согласен (-а) на обработку персональных данных", textStyle: const TextStyle(fontSize: 10),(state){}),
            ],
          ),
        )
      ),
    );
  }
}
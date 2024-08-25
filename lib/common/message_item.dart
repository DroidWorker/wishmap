import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wishmap/interface_widgets/colorButton.dart';

import '../interface_widgets/sq_checkbox.dart';

class MessageItem extends StatelessWidget {
  final bool myMessage;
  final String message;
  final bool allowChanging;
  final Function(String)? onAction;
  final Function? onTap;

  const MessageItem(this.myMessage, this.message, this.allowChanging, {super.key, this.onAction, this.onTap});

  @override
  Widget build(BuildContext context) {
    final List<String> days =
        List.generate(31, (index) => (index + 1).toString().padLeft(2, '0'));
    final List<String> months =
        List.generate(12, (index) => (index + 1).toString().padLeft(2, '0'));
    final List<String> years =
        List.generate(90, (index) => (1950 + index).toString());

    String selectedDay = "01";
    String selectedMonth = "01";
    String selectedYear = "1990";

    return InkWell(
      onTap: (){if(allowChanging&&onTap!=null)onTap!();},
      child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8), color: Colors.white),
              padding: const EdgeInsets.all(8),
              margin: EdgeInsets.fromLTRB(
                  myMessage ? 0 : 30, 4, myMessage ? 30 : 0, 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  myMessage
                      ? Row(
                          children: [Text(message, maxLines: null,), if(allowChanging)const Icon(Icons.edit)],
                        )
                      : Row(children: [Expanded(child: Text(message))]
                  ),
                  if(message == "Выберите дату рождения")Row(
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
                                selectedDay = val!;
                              },
                              value: selectedDay,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 3),
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
                                selectedMonth = val!;
                              },
                              value: selectedMonth,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 3,
                      ),
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
                              items: years.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(" $value", textAlign: TextAlign.center),
                                );
                              }).toList(),
                              onChanged: (String? val) {
                                selectedYear = val!;
                              },
                              value: selectedYear,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            String date = "$selectedYear-$selectedMonth-$selectedDay";
                            if (onAction != null) onAction!(date);
                          },
                          icon: const Icon(Icons.check))
                    ],
                  )else if(message == "Выберите ваш пол") Row(children: [
                    SquareCheckbox("Мужской", textStyle: const TextStyle(fontSize: 14), (state){
                      if (onAction != null) onAction!("true");
                    }),
                    SquareCheckbox("Женский", textStyle: const TextStyle(fontSize: 14), (state){
                      if (onAction != null) onAction!("false");
                    }),
                  ],)else if(message== "Проверьте введенные данные и подтвердите")Row(children: [
                    ColorRoundedButton("Изменить данные", radius: 3, (){
                      if (onAction != null) onAction!("changedata");
                    }),
                    ColorRoundedButton("Зарегистрироваться", radius: 3, (){
                      if (onAction != null) onAction!("registration");
                    })
                  ],)
                ],
              )
      ),
    );
  }
}

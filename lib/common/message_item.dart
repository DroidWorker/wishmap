import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wishmap/interface_widgets/colorButton.dart';

import '../interface_widgets/sq_checkbox.dart';

class MessageItem extends StatefulWidget {
  final bool myMessage;
  final String message;
  final bool allowChanging;
  final Function(String)? onAction;
  final Function? onTap;

  const MessageItem(this.myMessage, this.message, this.allowChanging,
      {super.key, this.onAction, this.onTap});

  @override
  MessageItemState createState() => MessageItemState();
}

class MessageItemState extends State<MessageItem>{
  String selectedDay = "01";
  String selectedMonth = "01";
  String selectedYear = "1990";

  final List<String> days =
  List.generate(31, (index) => (index + 1).toString().padLeft(2, '0'));
  final List<String> months =
  List.generate(12, (index) => (index + 1).toString().padLeft(2, '0'));
  final List<String> years =
  List.generate(90, (index) => (1950 + index).toString());


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){if(widget.allowChanging&&widget.onTap!=null)widget.onTap!();},
      child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8), color: Colors.white),
              padding: const EdgeInsets.all(8),
              margin: EdgeInsets.fromLTRB(
                  widget.myMessage ? 0 : 30, 4, widget.myMessage ? 30 : 0, 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  widget.myMessage
                      ? Row(
                          children: [Text(widget.message, maxLines: null,), if(widget.allowChanging)const Icon(Icons.edit)],
                        )
                      : Row(children: [Expanded(child: Text(widget.message))]
                  ),
                  if(widget.message == "Выберите дату рождения")Row(
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
                                setState(() {
                                  selectedMonth = val!;
                                });
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
                                setState(() {
                                  selectedYear = val!;
                                });
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
                            if (widget.onAction != null) widget.onAction!(date);
                          },
                          icon: const Icon(Icons.check))
                    ],
                  )else if(widget.message == "Выберите ваш пол") Row(children: [
                    SquareCheckbox("Мужской", textStyle: const TextStyle(fontSize: 14), (state){
                      if (widget.onAction != null) widget.onAction!("true");
                    }),
                    SquareCheckbox("Женский", textStyle: const TextStyle(fontSize: 14), (state){
                      if (widget.onAction != null) widget.onAction!("false");
                    }),
                  ],)else if(widget.message== "Проверьте введенные данные и подтвердите")Row(children: [
                    ColorRoundedButton("Изменить данные", radius: 3, (){
                      if (widget.onAction != null) widget.onAction!("changedata");
                    }),
                    ColorRoundedButton("Зарегистрироваться", radius: 3, (){
                      if (widget.onAction != null) widget.onAction!("registration");
                    })
                  ],)
                ],
              )
      ),
    );
  }
}

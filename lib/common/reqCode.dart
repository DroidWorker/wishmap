import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wishmap/interface_widgets/colorButton.dart';

class ReqCodeWidget extends StatelessWidget{

  TextEditingController c1 = TextEditingController();
  TextEditingController c2 = TextEditingController();
  TextEditingController c3 = TextEditingController();
  TextEditingController c4 = TextEditingController();
  TextEditingController email = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey();

  bool fillCheck(){
    return c1.text.isNotEmpty&&c2.text.isNotEmpty&&c3.text.isNotEmpty&&c4.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    /*c1.addListener((){
      if(!c1.text.contains(RegExp("^[0-9]\$"), c1.text.length - 1))  c1.text = c1.text.substring(0, c1.text.length - 1);
      if(fillCheck()) Navigator.pop(context, true);
    });
    c2.addListener((){
      if(!c2.text.contains(RegExp("^[0-9]\$"), c2.text.length - 1))  c2.text = c2.text.substring(0, c2.text.length - 1);
      if(fillCheck()) Navigator.pop(context, true);
    });
    c3.addListener((){
      if(!c3.text.contains(RegExp("^[0-9]\$"), c3.text.length - 1))  c3.text = c3.text.substring(0, c3.text.length - 1);
      if(fillCheck()) Navigator.pop(context, true);
    });
    c4.addListener((){
      if(!c4.text.contains(RegExp("^[0-9]\$"), c4.text.length - 1))  c4.text = c4.text.substring(0, c4.text.length - 1);
      if(fillCheck()) Navigator.pop(context, true);
    });*/

    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom+8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
        Form(
          key: formKey,
          child: TextFormField(
          autofocus: true,
          controller: email,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: Colors.black),
          // Черный текст ввода
          keyboardType: TextInputType.emailAddress,
          maxLength: 77,
          validator: (s)=>RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email.text)?null:"Некорректный email",
          autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
            hintText: "email",
            filled: true,
            fillColor: Colors.white,
            counterText: "",
            contentPadding:
            const EdgeInsets.fromLTRB(
                10, 0, 10, 0),
            border: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(10.0),
              borderSide: const BorderSide(
                width: 0,
                style: BorderStyle.none,
              ),
            ),
          ),
          ),
        ),
          const SizedBox(height: 12),
          ColorRoundedButton("Восстановить пароль", (){
            if(formKey.currentState?.validate()??false) Navigator.pop(context, email.text);
          }),
          const Text("На указанный email будет выслана инструкция для восстановления пароля")
          /*const SizedBox(height: 14),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 40,
                  child: TextField(
                    autofocus: true,
                    controller: c1,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.black),
                    // Черный текст ввода
                    keyboardType: TextInputType.phone,
                    maxLength: 1,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      counterText: "",
                      contentPadding:
                      const EdgeInsets.fromLTRB(
                          10, 0, 10, 0),
                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(10.0),
                        borderSide: const BorderSide(
                          width: 0,
                          style: BorderStyle.none,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: TextField(
                    autofocus: true,
                    controller: c2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.black),
                    // Черный текст ввода
                    keyboardType: TextInputType.phone,
                    maxLength: 1,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      counterText: "",
                      contentPadding:
                      const EdgeInsets.fromLTRB(
                          10, 0, 10, 0),
                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(10.0),
                        borderSide: const BorderSide(
                          width: 0,
                          style: BorderStyle.none,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: TextField(
                    autofocus: true,
                    controller: c3,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.black),
                    // Черный текст ввода
                    keyboardType: TextInputType.phone,
                    maxLength: 1,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      counterText: "",
                      contentPadding:
                      const EdgeInsets.fromLTRB(
                          10, 0, 10, 0),
                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(10.0),
                        borderSide: const BorderSide(
                          width: 0,
                          style: BorderStyle.none,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: TextField(
                    autofocus: true,
                    controller: c4,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.black),
                    // Черный текст ввода
                    keyboardType: TextInputType.phone,
                    maxLength: 1,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      counterText: "",
                      contentPadding:
                      const EdgeInsets.fromLTRB(
                          10, 0, 10, 0),
                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(10.0),
                        borderSide: const BorderSide(
                          width: 0,
                          style: BorderStyle.none,
                        ),
                      ),
                    ),
                  ),
                ),
          ])*/
        ],
      ),
    );
  }

}
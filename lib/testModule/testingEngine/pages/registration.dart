import 'package:flutter/material.dart';

import 'package:wishmap/res/colors.dart';

import 'afterregistration.dart';

class Registration extends StatelessWidget {
  const Registration({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: appbarColor,
            scrolledUnderElevation: 0,
            toolbarHeight: 90,
            title: Center(
              child: Image.asset(
                'assets/res/images/logo.png',
                height: 90,
              ),
            )
        ),
        body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                  child: Column(children: [Container(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight-90, // Установите минимальную высоту, которая вам нужна
                      ),
                      width: constraints.maxWidth,
                      color: bgMainColor,
                      padding: constraints.maxWidth>600? const EdgeInsets.all(100.0): const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const Text("Чтобы расшифровать и сохранить результаты теста необходимо зарегестрироваться",style: TextStyle(fontSize: 20),),
                          const SizedBox(height: 20,),
                          RichText(text:const TextSpan(text: "Никакого спама!", children: [TextSpan(text: "Только полезная информация", style: TextStyle(fontWeight: FontWeight.normal))], style: TextStyle(fontWeight: FontWeight.bold))),
                          const SizedBox(height: 30,),
                          const Text("Регистрация",style: TextStyle(fontSize: 20)),
                          const SizedBox(height: 30,),
                          Row(children: [
                            const Expanded(child: Text("email ", textAlign: TextAlign.right, style: TextStyle(fontSize: 18))),
                            Expanded(flex: 2,
                                child:TextField(decoration: InputDecoration(
                                  border: InputBorder.none,
                                  filled: true,
                              fillColor: buttonGrey,
                            ),)),
                            if(constraints.maxWidth>600)const Expanded(child: Text("")),
                          ],),
                          const SizedBox(height: 5,),
                          Row(children: [
                            const Expanded(child: Text("пароль ", textAlign: TextAlign.right, style: TextStyle(fontSize: 18),)),
                            Expanded(flex: 2,
                                child:TextField(decoration: InputDecoration(
                                  border: InputBorder.none,
                                  filled: true,
                              fillColor: buttonGrey,
                            ),)),
                            if(constraints.maxWidth>600)const Expanded(child: Text("")),
                          ],),
                          const SizedBox(height: 5,),
                          Row(children: [
                            const Expanded(child: Text("подтвердить ", textAlign: TextAlign.right, style: TextStyle(fontSize: 18))),
                            Expanded(flex: 2,
                                child:TextField(decoration: InputDecoration(
                                  border: InputBorder.none,
                                  filled: true,
                              fillColor: buttonGrey,
                            ),)),
                            if(constraints.maxWidth>600)const Expanded(child: Text("")),
                          ],),
                          const SizedBox(height: 30,),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AfterRegistration()),
                              );
                            },
                            child: const Text(
                              'ОК',
                              style: TextStyle(fontSize: 20.0, color: Colors.black),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      )),
                    Container(
                      height: 100,
                      color: footerColor,
                    )
                  ]
                  ));
            }));
  }
}
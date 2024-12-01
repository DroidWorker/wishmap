import 'package:flutter/material.dart';

import 'package:wishmap/res/colors.dart';

class AfterRegistration extends StatelessWidget {
  const AfterRegistration({super.key});


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
                        minHeight: constraints.maxHeight-100, // Установите минимальную высоту, которая вам нужна
                      ),
                      width: constraints.maxWidth,
                      color: bgMainColor,
                      padding: constraints.maxWidth>600? const EdgeInsets.all(100.0): const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const Text("На ваш электронный адрес было отправлено письмо. Необходимо открыть письмо и подтвердить регистрацию.",style: TextStyle(fontSize: 18),),
                          const SizedBox(height: 40,),
                          const Text("После подтверждения регистрации результаты теста будут доступны в личном кабинете.",style: TextStyle(fontSize: 18)),
                          const SizedBox(height: 40,),
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: buttonGrey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0.0), // Установите радиус скругления в 0.0, чтобы сделать кнопку квадратной
                              ),
                            ),
                            onPressed: () {

                            },
                            child: const Text(
                              'Смотреть результаты',
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
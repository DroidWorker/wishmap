import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../navigation/navigation_block.dart';
import '../../../res/colors.dart';
import 'module.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  MainPageState createState() => MainPageState();
}

class MainPageState extends State{
  var isToggled = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: appbarColor,
            scrolledUnderElevation: 0,
            toolbarHeight: 90,
            title: Center(
              child: Text(
                "Выход из теста -->"
              )
            ),
          actions: [
            IconButton(onPressed: (){BlocProvider.of<NavigationBloc>(context).handleBackPress();}, icon: const Icon(Icons.close, color: Colors.red,))
          ],
        ),
        body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: Container(
                  width: constraints.maxWidth,
                  color: bgMainColor,
                  padding: constraints.maxWidth>600? const EdgeInsets.all(100.0): const EdgeInsets.all(20.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(mainAxisSize: MainAxisSize.min,
                          children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: isToggled != 1 ? buttonGrey : buttonActive,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0.0), // Установите радиус скругления в 0.0, чтобы сделать кнопку квадратной
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                isToggled = 1;
                              });
                              BlocProvider.of<NavigationBloc>(context).add(
                                  NavigateToModuleScreenEvent());
                            },
                            child: const Text(
                              'начать',
                              style: TextStyle(fontSize: 18.0, color: Colors.black),
                            ),
                          ),
                        ],)
                      ],
                    ),
                  ),
                ),
              );
            })
    );
  }
}
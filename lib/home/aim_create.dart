import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../navigation/navigation_block.dart';
import '../res/colors.dart';

class AimScreen extends StatelessWidget {

  const AimScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(child:SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Цель",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.greytextColor),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        child: const Text(
                          "Сохранить",
                          style: TextStyle(color: AppColors.blueTextColor),
                        ),
                        onTap: (){
                          BlocProvider.of<NavigationBloc>(context)
                              .add(NavigateToAimEditScreenEvent());
                        },
                      )
                    ),
                  ],
                ),
                const Divider(
                  height: 3,
                  color: AppColors.dividerGreyColor,
                  indent: 5,
                  endIndent: 5,
                ),
                const SizedBox(height: 10),
                TextField(
                  style: const TextStyle(color: Colors.black), // Черный текст ввода
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.fieldFillColor,
                    hintText: 'Название цели',
                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
                    border: InputBorder.none
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  minLines: 4,
                  maxLines: 15,
                  style: const TextStyle(color: Colors.black), // Черный текст ввода
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.fieldFillColor,
                    hintText: 'Опиши подробно свое желание',
                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
                    border: InputBorder.none
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.fieldFillColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // <-- Radius
                      ),
                    ),
                    onPressed: (){
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Необходимо созхранить цель'),
                            duration: Duration(seconds: 3), // Установите желаемую продолжительность отображения
                          ),
                        );
                    },
                    child: const Text("Создать задачу", style: TextStyle(color: AppColors.greytextColor),)
                ),
                const SizedBox(height: 5),
                const Text("Укажи задачу дня для достижения цели. Помни! Задача актуальна 24 часа", style: TextStyle(fontSize: 10, color: AppColors.greytextColor),)
                ],
            ),),
        )
    ));
  }
}

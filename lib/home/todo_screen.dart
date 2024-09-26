import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../navigation/navigation_block.dart';
import '../res/colors.dart';

class TodoScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child:
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  style: const ButtonStyle(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap, // the '2023' part
                  ),
                  icon: const Icon(Icons.keyboard_arrow_left, size: 30, color: AppColors.gradientStart),
                  onPressed: () {
                    BlocProvider.of<NavigationBloc>(context).handleBackPress();
                  },
                ),
                const Spacer(),
              ],
              ),
              const Spacer(),
              Image.asset('assets/icons/todo.png'),
              const SizedBox(height: 20),
              const Text("Здесь пока ничего нет", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const Text("Следите за новостями, в скором времени добавим", textAlign: TextAlign.center, style: TextStyle(color: AppColors.greytextColor)),
              const Spacer()
            ],
          ),
        )
      ),
    );
  }
}
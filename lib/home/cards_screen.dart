import 'package:flutter/material.dart';
import 'package:wishmap/common/moon_widget.dart';
import 'package:wishmap/data/models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wishmap/navigation/navigation_block.dart';
import 'package:wishmap/res/colors.dart';

class CardsScreen extends StatelessWidget {
  final List<MoonItem> items = [MoonItem(id: 0, filling: 0.3, text: "Я", date: "08.02.2023"), MoonItem(id: 1, filling: 0.6, text: "Я", date: "28.10.2023"), MoonItem(id: 2, filling: 0.4, text: "Я", date: "04.11.2023"), MoonItem(id: 4, filling: 0.9, text: "Я", date: "31.09.2023")];

  CardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(child:ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(15),
              child: GestureDetector(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MoonWidget(fillPercentage: items[index].filling),
                    Text(items[index].date)
                  ],
                ),
                onTap: (){
                  BlocProvider.of<NavigationBloc>(context)
                      .add(NavigateToMainScreenEvent());
                },
              )
          );
        },
      ),
    ));
  }
}

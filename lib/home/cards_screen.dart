import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/common/moon_widget.dart';
import 'package:wishmap/data/models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wishmap/navigation/navigation_block.dart';
import 'package:wishmap/res/colors.dart';

import '../ViewModel.dart';

class CardsScreen extends StatelessWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appViewModel = Provider.of<AppViewModel>(context);
    if(appViewModel.moonItems.isEmpty)appViewModel.getMoons();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Consumer<AppViewModel>(
        builder: (context, appVM, child){
          List<MoonItem> items = appVM.moonItems;
          return SafeArea(child:ListView.builder(
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
                      if(appViewModel.moonItems.isNotEmpty)appViewModel.startMainScreen(appVM.moonItems[index]);
                      BlocProvider.of<NavigationBloc>(context)
                          .add(NavigateToMainScreenEvent());
                    },
                  )
              );
            },
          ),
          );
        },
      )
    );
  }
}

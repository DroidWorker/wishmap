import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/common/connectivity.dart';
import 'package:wishmap/data/models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wishmap/navigation/navigation_block.dart';
import 'package:wishmap/res/colors.dart';

import '../ViewModel.dart';
import '../common/moon_widget.dart';

class CardsScreen extends StatelessWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appViewModel = Provider.of<AppViewModel>(context);
    if(appViewModel.moonItems.isEmpty) {
      appViewModel.getMoons();
    } else {
      appViewModel.fetchImages();
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      persistentFooterButtons: [
        ConnectionStatus(isShow: true,)
      ],
      body: Consumer<AppViewModel>(
        builder: (context, appVM, child){
          List<MoonItem> items = appVM.moonItems;
          return SafeArea(child:ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              DateTime date = parseDateString(items[index].date)??DateTime.now();
              return Padding(
                  padding: const EdgeInsets.all(15),
                  child: InkWell(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        MoonWidget(
                          date: date,
                          size: 90,
                          resolution: 900,
                        ),
                        Text(items[index].date)
                      ],
                    ),
                    onTap: () async {
                      if(appViewModel.moonItems.isNotEmpty) {
                        final moonId = appVM.moonItems[index];
                        appViewModel.fetchDatas(moonId.id);
                        appViewModel.startMainScreen(moonId);
                        BlocProvider.of<NavigationBloc>(context)
                            .add(NavigateToMainScreenEvent());
                      }else{appViewModel.addError("Ошибка! нет соединения с сервером");}
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

  DateTime? parseDateString(String dateString) {
    List<String> parts = dateString.split('.');
    if (parts.length == 3) {
      int? day = int.tryParse(parts[0]);
      int? month = int.tryParse(parts[1]);
      int? year = int.tryParse(parts[2]);

      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }

    // Вернуть null в случае некорректного формата строки
    return null;
  }
}

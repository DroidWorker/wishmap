import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/ViewModel.dart';
import 'package:wishmap/data/date_static.dart';
import 'package:wishmap/data/models.dart';
import 'package:wishmap/interface_widgets/outlined_button.dart';

import '../dialog/actualizeMoonDialog.dart';
import '../navigation/navigation_block.dart';
import '../res/colors.dart';
import 'moon_widget.dart';

class CardItem extends StatelessWidget{
  CardItem(this.mi, this.isSelected, this.onTap, this.onLongTap, this.onLoadStarted);

  MoonItem mi;
  Function() onTap;
  Function() onLongTap;
  Function() onLoadStarted;
  bool isSelected;
  @override
  Widget build(BuildContext context) {
    var appViewModel = Provider.of<AppViewModel>(context);
    DateTime date = parseDateString(mi.date)??DateTime.now();
    return Padding(
        padding: const EdgeInsets.all(15),
        child: Container(
          decoration: isSelected?BoxDecoration( borderRadius: BorderRadius.circular(8),border: Border.all(width: 1, color: AppColors.buttonBackRed)):null,
          child: InkWell(
            child: mi.id!=-1?Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [MoonWidget(date: date, size: 85, resolution: 800,),
                Text("#${mi.id} ${dateToLongString(mi.date)??mi.date}")]):
              OutlinedGradientButton("Добавить карту", widgetBeforeText: const Icon(Icons.add_circle_outline_rounded), () => {
                showDialog(context: context, builder: (contest){
                  return ActualizeMoonDialog(onActualizeClick: (){
                    Navigator.pop(contest);
                    BlocProvider.of<NavigationBloc>(context)
                        .add(NavigateToQRScreenEvent());
                  }, onCloseDialogClick: (){Navigator.pop(contest);}, onCreateNew: () async {
                    final now = DateTime.now();
                    await appViewModel.createNewMoon("${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}");
                    final moonId = appViewModel.moonItems.last;
                    onLoadStarted();
                    appViewModel.startMainScreen(moonId);
                    Navigator.pop(contest);
                    BlocProvider.of<NavigationBloc>(context)
                        .add(NavigateToMainScreenEvent());
                  });
                })
              }),
            onTap: () => onTap(),
            onLongPress: () => onLongTap(),
          ),
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

  String? dateToLongString(String dateString){
    List<String> parts = dateString.split('.');
    if (parts.length == 3) {
      int? day = int.tryParse(parts[0]);
      int? month = int.tryParse(parts[1]);
      int? year = int.tryParse(parts[2]);

      if (day != null && month != null && year != null) {
        final datetime = DateTime(year, month, day);
        final dayOfWeek = shortDayOfWeek[datetime.weekday];
        final stringMonth = monthOfYear[datetime.month];
        return "$dayOfWeek, $day $stringMonth $year г.";
      }
    }

    // Вернуть null в случае некорректного формата строки
    return null;
  }
}
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/common/connectivity.dart';
import 'package:wishmap/common/speedTest_Overlay.dart';
import 'package:wishmap/data/models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wishmap/dialog/actualizeMoonDialog.dart';
import 'package:wishmap/navigation/navigation_block.dart';
import 'package:wishmap/res/colors.dart';

import '../ViewModel.dart';
import '../common/moon_widget.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  CardsScreenState createState() => CardsScreenState();
}

class CardsScreenState extends State<CardsScreen>{
  bool isInSync = false;
  @override
  Widget build(BuildContext context) {
    final now  = DateTime.now();
    final appViewModel = Provider.of<AppViewModel>(context);
    if(appViewModel.moonItems.isEmpty) {
      appViewModel.getMoons();
    } else {
      appViewModel.fetchImages();
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      persistentFooterButtons: [
        if(!isInSync)
          Column(
              children:[
                ConnectionStatus(isShow: true,),
                TextButton(onPressed: (){showOverlayedSpeedTest(context);}, child: const Text("test speed"))
              ]
          )
        ,
        if(isInSync) Row(children: [
          const Text("синхронизация"),
          const CircularProgressIndicator(),
        ],)
      ],
      body: Consumer<AppViewModel>(
        builder: (context, appVM, child){
          List<MoonItem> items = List<MoonItem>.from(appVM.moonItems);
          items = items.reversed.toList();
          if(items.isNotEmpty&&items.first.date!="${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}"){
            items.insert(0, MoonItem(id: -1, filling: 0, text: "", date: "${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}"));
          }
          return SafeArea(child:ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              DateTime date = parseDateString(items[index].date)??DateTime.now();
              return Padding(
                  padding: const EdgeInsets.all(15),
                  child: InkWell(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if(items[index].id!=-1)MoonWidget(
                          date: date,
                          size: 90,
                          resolution: 900,
                        )else IconButton(onPressed: (){
                          showDialog(context: context, builder: (contest){
                            return ActualizeMoonDialog(onActualizeClick: (){
                              Navigator.pop(contest);
                              BlocProvider.of<NavigationBloc>(context)
                                  .add(NavigateToQRScreenEvent());
                            }, onCloseDialogClick: (){Navigator.pop(contest);}, onCreateNew: () async {
                              await appViewModel.createNewMoon("${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}");
                              final moonId = appVM.moonItems.last;
                              setState(() {
                                isInSync = true;
                              });
                              appViewModel.startMainScreen(moonId);
                              Navigator.pop(contest);
                              BlocProvider.of<NavigationBloc>(context)
                                  .add(NavigateToMainScreenEvent());
                            });
                          });
                        }, iconSize:70, icon: const Icon(Icons.add, color: AppColors.moonColor,size: 70,)),
                        Text(items[index].date)
                      ],
                    ),
                    onTap: () async {
                      try {
                        var result = await Connectivity().checkConnectivity();
                        if (result == ConnectivityResult.none) appViewModel
                            .connectivity = 'No Internet Connection';
                        if (items[index].id != -1 &&
                            appViewModel.moonItems.isNotEmpty) {
                          final moonId = appVM.moonItems
                              .where((e) => e.id == items[index].id)
                              .first;
                          setState(() {
                            isInSync = true;
                          });
                          await appViewModel.fetchDatas(moonId.id);
                          appViewModel.startMainScreen(moonId);
                          appViewModel.hint =
                          "Отлично! Теперь пришло время заполнить все сферы жизни. Ты можешь настроить состав и название сфер так, как считаешь нужным. И помни, что максимальное количество сфер ограничено и равно 13.";
                          BlocProvider.of<NavigationBloc>(context)
                              .add(NavigateToMainScreenEvent());
                        } else {
                          appViewModel.addError(
                              "Ошибка! нет соединения с сервером");
                        }
                      }catch(ex, s){print("eeeeeeeeeeeeeeeeeeeeeeeeeeee $ex --- $s");}
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

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/common/card_item.dart';
import 'package:wishmap/common/connectivity.dart';
import 'package:wishmap/common/speedTest_Overlay.dart';
import 'package:wishmap/data/models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wishmap/interface_widgets/colorButton.dart';
import 'package:wishmap/navigation/navigation_block.dart';
import 'package:wishmap/res/colors.dart';

import '../ViewModel.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  CardsScreenState createState() => CardsScreenState();
}

class CardsScreenState extends State<CardsScreen> {
  bool isInSync = false;
  bool deleteMode = false;

  List<int> deleteQ = [];

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<NavigationBloc>(context).clearHistory();
    final now = DateTime.now();
    final appViewModel = Provider.of<AppViewModel>(context);
    if (appViewModel.moonItems.isEmpty) {
      appViewModel.getMoons();
    } else {
      appViewModel.fetchImages();
    }
    int indexPad = 0;

    return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        persistentFooterButtons: [
          if (!isInSync)
            Column(children: [
              ConnectionStatus(
                isShow: true,
              ),
              TextButton(
                  onPressed: () {
                    showOverlayedSpeedTest(context);
                  },
                  child: const Text("test speed"))
            ]),
          if (isInSync)
            const Row(
              children: [
                Text("синхронизация"),
                CircularProgressIndicator(),
              ],
            )
        ],
        body: Consumer<AppViewModel>(
          builder: (context, appVM, child) {
            List<MoonItem> items = List<MoonItem>.from(appVM.moonItems);
            items = items.reversed.toList();
            if (items.isNotEmpty /*&&
                items.first.date !=
                    "${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}"*/) {
              indexPad=1;
              items.insert(
                  0,
                  MoonItem(
                      id: -1,
                      filling: 0,
                      text: "",
                      date:
                          "${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}"));
            }
            return SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return CardItem(items[index], deleteQ.contains(index-indexPad),
                            () async {
                          if (deleteMode == true) {
                            setState(() {
                              if (deleteQ.contains(index-indexPad)) {
                                deleteQ.remove(index-indexPad);
                                if(deleteQ.isEmpty)deleteMode=false;
                              } else {
                                deleteQ.add(index-indexPad);
                              }
                            });
                          } else {
                            try {
                              var result =
                                  await Connectivity().checkConnectivity();
                              if (result == ConnectivityResult.none)
                                appViewModel.connectivity =
                                    'No Internet Connection';
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
                            } catch (ex, s) {
                              print("eeeeeeeeeeeeeeeeeeeeeeeeeeee $ex --- $s");
                            }
                          }
                        }, () {
                          setState(() {
                            deleteMode = true;
                            deleteQ.add(index-indexPad);
                          });
                        }, () {
                          setState(() {
                            isInSync = true;
                          });
                        });
                      },
                    ),
                  ),
                  deleteMode&&appVM.connectivity!="No Internet Connection"
                      ? ColorRoundedButton("Удалить", () {
                          setState(() {
                            List<int> realIsDeleteQ = [];
                            deleteQ.sort((a, b)=>b.compareTo(a));
                            for (var e in deleteQ) {
                              realIsDeleteQ.add(appVM.moonItems[e].id);
                              appVM.moonItems.removeAt(appVM.moonItems.length-1-e);
                            }
                            appViewModel.deleteMoons(realIsDeleteQ);
                            deleteMode = false;
                            deleteQ.clear();
                          });
                        })
                      : const SizedBox()
                ],
              ),
            );
          },
        ));
  }
}

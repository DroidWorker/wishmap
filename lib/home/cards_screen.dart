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
import '../dialog/bottom_sheet_action.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  CardsScreenState createState() => CardsScreenState();
}

class CardsScreenState extends State<CardsScreen> {
  bool isInSync = false;
  bool deleteMode = false;
  bool allowActualization = false;

  List<int> deleteQ = [];

  Future checkPromocodes(AppViewModel vm) async{
    allowActualization = await vm.hasActivePromocode("default");
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

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
            checkPromocodes(appVM);
            List<MoonItem> items = List<MoonItem>.from(appVM.moonItems);
            items = items.reversed.toList();
            if (items.isNotEmpty&&allowActualization) {
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
                      ? ColorRoundedButton("Удалить", (){
                    showModalBottomSheet<void>(
                      backgroundColor: AppColors.backgroundColor,
                      context: context,
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        return ActionBS('Внимание', "Выбранные карты будут удалены\nУдалить?", "Да", 'Нет',
                            onOk: () async {
                              List<int> realIsDeleteQ = [];
                              setState(() {
                                isInSync = true;
                              });
                              final len = appVM.moonItems.length;
                              deleteQ.sort((a, b)=>a.compareTo(b));
                              for (var e in deleteQ) {
                                realIsDeleteQ.add(appVM.moonItems[len-1-e].id);
                                appVM.moonItems.removeAt(len-1-e);
                              }
                              await appViewModel.deleteMoons(realIsDeleteQ);
                              setState(() {
                                deleteMode = false;
                                deleteQ.clear();
                                isInSync = false;
                              });
                              Navigator.pop(context, 'Cancel');
                            },
                            onCancel: () {
                              setState(() {
                                deleteMode = false;
                                deleteQ.clear();
                                isInSync = false;
                              });
                              Navigator.pop(context, 'Cancel');
                            });
                      },
                    );
                  })
                      : const SizedBox()
                ],
              ),
            );
          },
        ));
  }
}

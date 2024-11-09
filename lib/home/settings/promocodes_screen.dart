import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wishmap/ViewModel.dart';

import '../../interface_widgets/colorButton.dart';
import '../../navigation/navigation_block.dart';
import '../../res/colors.dart';

class PromocodesScreen extends StatefulWidget{
  const PromocodesScreen({super.key});

  @override
  PromocodesScreenState createState() => PromocodesScreenState();
}

class PromocodesScreenState extends State<PromocodesScreen> {
  TextEditingController controller = TextEditingController();
  AppViewModel? vm;

  Map<String, String> promocodes = {};
  RegExp promoPattern = RegExp("^[A-Z0-9]{5}\\d{4}\$");
  bool checkingEnabled = false;
  bool isInCheckingPromo = false;
  bool isInPreload = true;
  String? errorMessage;

  int screen = 1;

  Future<void> initData(AppViewModel viewModel) async {
    promocodes = await viewModel.getPromocodes();
    setState(() {
      isInPreload = false;
    });
  }

  @override
  void initState() {
    controller.addListener(() async {
      checkingEnabled = controller.text.length>8;
      if(checkingEnabled){
        if(promoPattern.hasMatch(controller.text)){
          setState(() {
            errorMessage=null;
            isInCheckingPromo = true;
          });
          final result = await vm?.checkPromocode(controller.text);
            isInCheckingPromo = false;
            if(result==null) {
              setState(() {
                controller.text = "";
                errorMessage = "Промокод неактивен";
              });
            } else{
              setState(() {});
              controller.text='';
              promocodes[result.promocode]=result.expDate;
              showModalBottomSheet(backgroundColor: AppColors.backgroundColor,
                  context: context,
                  isScrollControlled: true,
                  builder: (c){
                return bottomMessageActivated(result.expDate, ()=>Navigator.of(context).pop());
              });
          }
        } else {
          setState(() {
          errorMessage = "Промокод введен неверно";
        });
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final promosText = promocodes.keys.toList();
    final datesText = promocodes.values.toList();
    final dates = datesText.map((e)=>DateFormat("dd.MM.yyyy").parse(e)).toList();
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        style: const ButtonStyle(
                          tapTargetSize:
                          MaterialTapTargetSize.shrinkWrap, // the '2023' part
                        ),
                        icon: const Icon(Icons.keyboard_arrow_left,
                            size: 28, color: AppColors.gradientStart),
                        onPressed: () {
                          BlocProvider.of<NavigationBloc>(context).handleBackPress();
                        }),
                    const Text("Промокоды",
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(width: 30)
                  ],
                ),
                Consumer<AppViewModel>(builder: (context, appVM, child) {
                  vm = appVM;
                  if(isInPreload)initData(appVM);
                  return Expanded(
                    child: isInPreload?const Center(child: CircularProgressIndicator()):promocodes.isEmpty?Column(children: [
                      const Spacer(),
                      Image.asset('assets/icons/promocode_discount.png'),
                      const Text("Промокод", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                      const Text("Для расширения возможностей приложения"),
                      isInCheckingPromo?const SizedBox(height: 44, child: CircularProgressIndicator()):const SizedBox(height: 44),
                      TextField(
                        controller: controller,
                        style: TextStyle(color: errorMessage==null?Colors.black:AppColors.redTextColor),
                        showCursor: false,
                        enabled: !isInCheckingPromo,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          hintText: "Введите промокод",
                          errorText: errorMessage,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                                width: 1,
                                color: errorMessage==null?AppColors.etGrey:AppColors.redTextColor
                            ),
                          ),
                        ),
                      ),
                      const Spacer(flex: 3)
                    ],)
                        :Column(children: [
                      const SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: (){
                                      setState(() {
                                        screen=0;
                                      });
                                    },
                                    child: Container(
                                      height: 35,
                                      decoration: BoxDecoration(
                                          gradient: screen!=0?null:const LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd]),
                                          borderRadius: BorderRadius.circular(10)
                                      ),
                                      child: Center(child: Text("Промокод", style: TextStyle(color: screen!=0?Colors.black:Colors.white)))
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: (){
                                      setState(() {
                                        screen=1;
                                      });
                                    },
                                    child: Container(
                                      height: 35,
                                        decoration: BoxDecoration(
                                            gradient: screen!=1?null:const LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd]),
                                            borderRadius: BorderRadius.circular(10)
                                        ),
                                        child: Center(child: Text("История", style: TextStyle(color: screen!=1?Colors.black:Colors.white)))
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          screen==0?Column(
                            children: [
                              const SizedBox(height: 40),
                              const Text("Промокод", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                              const Text("Для расширения возможностей приложения"),
                              isInCheckingPromo?const SizedBox(height: 44, child: CircularProgressIndicator()):const SizedBox(height: 44),
                              TextField(
                                controller: controller,
                                style: TextStyle(color: errorMessage==null?Colors.black:AppColors.redTextColor),
                                showCursor: false,
                                enabled: !isInCheckingPromo,
                                textCapitalization: TextCapitalization.characters,
                                decoration: InputDecoration(
                                  hintText: "Введите промокод",
                                  errorText: errorMessage,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                        width: 1,
                                        color: errorMessage==null?AppColors.etGrey:AppColors.redTextColor
                                    ),
                                  ),
                                ),
                              ),
                              ColorRoundedButton("Получить промокод", () async {
                                final url = 'tg://resolve?domain=${vm?.static["tg"]}';
                                final uri = Uri.parse(url);
                                Navigator.pop(context, 'OK');
                                if (await canLaunchUrl(uri)) {
                                  launchUrl(uri);
                                }
                              })
                            ],
                          ):
                              ListView.separated(
                                shrinkWrap: true,
                                itemCount: promocodes.length,
                                  itemBuilder: (buildContext, index){
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(promosText[index], style: const TextStyle(fontSize: 18)),
                                        Text(datesText[index], style: const TextStyle(color: AppColors.greytextColor)),
                                        Text(DateTime.now().isAfter(dates[index])?"Неактивный":"Активный", style: TextStyle(color: DateTime.now().isAfter(dates[index])?AppColors.redTextColor:Colors.green))
                                      ],
                                    );
                                  },
                                separatorBuilder: (c, index){
                                  return const Divider(color: AppColors.greytextColor);
                                },
                              )
                        ],),
                  );
                })
              ],
            ),
          )),
    );
  }


  Widget bottomMessageActivated(String date, Function() onClose){
    final datetime = DateFormat("dd.MM.yyyy").parse(date);
    bool isActive = DateTime.now().isAfter(datetime);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: isActive?const Icon(Icons.cancel_outlined, color: AppColors.buttonBackRed, size: 65):Image.asset('assets/icons/green_activated.png'),
        ),
        Text(isActive?"Промокод неактивен":"Промокод активирован", style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
        const Text("Список всех активных промокодов в “Истории”", style: TextStyle(color: AppColors.greytextColor)),
        const SizedBox(height: 60),
        Text("Действителен до $date", style: const TextStyle(color: AppColors.gold)),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ColorRoundedButton("Готово", (){onClose();}
          ),
        ),
        const SizedBox(height: 16)
      ],
    );
  }
}
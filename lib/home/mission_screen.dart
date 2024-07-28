import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wishmap/common/gradientText.dart';

import '../interface_widgets/outlined_button.dart';
import '../res/colors.dart';

Future<void> showOverlayedMissionScreen(BuildContext context, int totalRepeatCount, int type)async {
  Completer<void> completer = Completer<void>();
  OverlayEntry? overlayEntry;

  var myOverlay = MissionScreen(totalRepeatCount, type, () {
    overlayEntry?.remove();
    completer.complete();
  });

  overlayEntry = OverlayEntry(
    builder: (context) => myOverlay,
  );

  Overlay.of(context).insert(overlayEntry);
  return completer.future;
}

class MissionScreen extends StatefulWidget{

  int totalRepeatCount;
  int type = 0;

  Function() onClose;

  MissionScreen(this.totalRepeatCount, this.type, this.onClose, {super.key});

  @override
  MissionScreenState createState() => MissionScreenState();
}

class MissionScreenState extends State<MissionScreen>{
  int currentRepeatCount = 0;
  Uint8List? image;
  List<String> affirmations = [];

  @override
  void initState() {
    currentRepeatCount = widget.totalRepeatCount;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Expanded(
            child: (widget.type==0)? Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        style: const ButtonStyle(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap, // the '2023' part
                        ),
                        icon: const Icon(Icons.keyboard_arrow_left, size: 28, color: AppColors.gradientStart),
                        onPressed: () async {
            
                        }
                    ),
                    const SizedBox(width: 40, height: 40,)
                  ],
                ),
                GradientText(currentRepeatCount.toString(), gradient: const LinearGradient(
                    colors: [AppColors.gradientStart, AppColors.gradientEnd]
                ), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 32),
                ),
                LinearProgressIndicator(value: 1-(widget.totalRepeatCount/currentRepeatCount)),
                const SizedBox(height: 16),
                Expanded(child:
                Stack(
                  fit: StackFit.expand,
                  children: [
                    image!=null?Image.memory(image!, fit: BoxFit.cover):Image.asset("assets/icons/vodopad.png", fit: BoxFit.cover),
                    Center(child: Image.asset('assets/icons/unactual.png', height: 90, width: 90)),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const Text("Неактуально", style: TextStyle(color: Colors.white)),
                            Image.asset('assets/icons/hand.png', height: 44, width: 44),
                            const Text("Актуально", style: TextStyle(color: Colors.white))
                          ],
                        ),
                      ),
                    )
                  ],
                )
                ),
                const SizedBox(height: 16),
                Text("path", style: TextStyle(color: AppColors.greytextColor)),
                const GradientText("Найти водопад в Сочи", gradient: LinearGradient(
                    colors: [AppColors.gradientStart, AppColors.gradientEnd]
                ), style: TextStyle(fontWeight: FontWeight.w700, fontSize: 28),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('assets/icons/unactual.png', height: 52, width: 52),
                    Image.asset('assets/icons/actual.png', height: 52, width: 52)
                  ],
                )
              ],
            ):(widget.type==1)?
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        style: const ButtonStyle(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap, // the '2023' part
                        ),
                        icon: const Icon(Icons.keyboard_arrow_left, size: 28, color: AppColors.gradientStart),
                        onPressed: () async {

                        }
                    ),
                    const SizedBox(width: 40, height: 40,)
                  ],
                ),
                GradientText(currentRepeatCount.toString(), gradient: const LinearGradient(
                    colors: [AppColors.gradientStart, AppColors.gradientEnd]
                ), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 32),
                ),
                LinearProgressIndicator(value: 1-(widget.totalRepeatCount/currentRepeatCount)),
                const SizedBox(height: 16),
                Expanded(child:
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: AppColors.grey)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Spacer(),

                      SizedBox(height: 40),
                      Text("path", style: TextStyle(color: AppColors.greytextColor),),
                      const GradientText("Найти водопад в Сочи", gradient: LinearGradient(
                          colors: [AppColors.gradientStart, AppColors.gradientEnd]
                      ), style: TextStyle(fontWeight: FontWeight.w700, fontSize: 28),
                      ),
                      SizedBox(height: 60),
                      Text("Удалить", style: TextStyle(color: AppColors.greytextColor)),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                        const Text("Не трогать", style: TextStyle(color: AppColors.greytextColor)),
                        SvgPicture.asset('assets/icons/hand.svg', height: 44, width: 44),
                        const Text("Выполнено", style: TextStyle(color: AppColors.greytextColor))
                      ],),
                      const SizedBox(height: 16)
                    ],
                  )
                )
                ),
                const SizedBox(height: 33),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SvgPicture.asset('assets/icons/circle_close.svg', height: 52, width: 52),
                    SvgPicture.asset('assets/icons/circle_trash.svg', height: 52, width: 52),
                    SvgPicture.asset('assets/icons/actual.svg', height: 52, width: 52)
                  ],
                )
              ],
            ):Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        style: const ButtonStyle(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap, // the '2023' part
                        ),
                        icon: const Icon(Icons.keyboard_arrow_left, size: 28, color: AppColors.gradientStart),
                        onPressed: () async {

                        }
                    ),
                    const SizedBox(width: 40, height: 40,)
                  ],
                ),
                const SizedBox(height: 16),
                const Text("Выберите аффирмацию дня", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                const Text("Аффирмация будет указана в “Я”", style: TextStyle(fontSize: 12, color: AppColors.greytextColor)),
                const SizedBox(height: 16),
                const Text("Аффирмации - прикладной инструмент для достижения мечты или цели. Служит для повторения с целью изменить наше мышление и отношение к жизни", style: TextStyle(fontSize: 12, color: AppColors.greytextColor)),
                const SizedBox(height: 32),
                ListView.builder(shrinkWrap: true,
                    itemCount: affirmations.length,
                    itemBuilder: (context, index){
                      return  Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                            child: Container(
                              height: 40, width: 40,

                            ),
                          )
                        ],
                      );
                    }
                    ),
                const SizedBox(height: 24),
                const GradientText("Сменить аффирмации", gradient: LinearGradient(
                    colors: [AppColors.gradientStart, AppColors.gradientEnd]
                )),
                const Spacer(),
                OutlinedGradientButton("Назад", (){

                })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
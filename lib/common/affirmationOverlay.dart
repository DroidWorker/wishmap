import 'dart:async';

import 'package:flutter/material.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';

import '../res/colors.dart';

Future<String?> showOverlayedAffirmations(BuildContext context, List<String> affirmations, bool isChecked, bool isShuffle, {Function(bool value)? onShuffleClick})async {
  Completer<String?> completer = Completer<String?>();
  OverlayEntry? overlayEntry;

    var myOverlay = MyAffirmationOverlay(affirmations: affirmations, isChecked: isChecked, isShuffle: isShuffle, onClose: (value) {
      overlayEntry?.remove();
      completer.complete(value);
    }, onShuffleClick: (value){
      onShuffleClick!(value);
      /*showDialog(context: context,
        builder: (BuildContext context) => AlertDialog(
          contentPadding: const EdgeInsets.all(10),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32.0))),
          title: const Text("Внимание", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Режим Shuffle активирован. теперь аффирмации будут появляться в окне подсказок рандомно", maxLines: 5, textAlign: TextAlign.center,),
              SizedBox(height: 4,),
              Divider(color: AppColors.dividerGreyColor,),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async { Navigator.pop(context, 'OK'); },
              child: const Text('Ok'),
            ),
          ],
        ),
      );*/
    });

    overlayEntry = OverlayEntry(
      builder: (context) => myOverlay,
    );

    Overlay.of(context).insert(overlayEntry);
  return completer.future;
}

class MyAffirmationOverlay extends StatefulWidget {
  Function(String value) onClose;
  Function(bool value) onShuffleClick;

  List<String> affirmations;
  bool isChecked;
  bool isShuffle;

  MyAffirmationOverlay({super.key, required this.affirmations, required this.isChecked, required this.isShuffle, required this.onClose, required this.onShuffleClick});

  @override
  _MyOverlayState createState() => _MyOverlayState();
}

class _MyOverlayState extends State<MyAffirmationOverlay> {
  TextEditingController controller = TextEditingController();
  String currentAffirmation= "";
  int currentIndex = -1;
  int currentEditIndex = -1;

  int screenType = 0;//0 - default 1- aff edit
  @override
  Widget build(BuildContext context) {
    if(widget.isChecked&&currentAffirmation==""){
      currentAffirmation=widget.affirmations.first;
      if(!widget.isShuffle)currentIndex = 0;
    }
    if(currentEditIndex!=-1&&currentEditIndex<widget.affirmations.length)controller.text=widget.affirmations[currentEditIndex];
    return Positioned.fill(
      child: Material(
          color: AppColors.backgroundColor,
          child: Column(
            children: [
              const SizedBox(height: 30,),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_left),
                    onPressed: () {
                      if(screenType==0) {
                        String finalAffs = currentAffirmation;
                        for (var element in widget.affirmations) {
                          if (element != currentAffirmation)
                            finalAffs += "|$element";
                        }
                        widget.onClose(finalAffs);
                      }else{
                        setState(() {
                          screenType = 0;
                          widget.affirmations[currentEditIndex] = controller.text;
                        });
                      }
                    },
                  ),
                  const Spacer(),
                  if(screenType==0)TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: widget.isShuffle?AppColors.pinkButtonTextColor:AppColors.greyBackButton,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      onPressed: (){setState(() {
                        widget.isShuffle = !widget.isShuffle;
                        widget.onShuffleClick(widget.isShuffle);
                        if(widget.isShuffle)currentIndex=-1;
                      });},
                      child: const Text("Shuffle", style: TextStyle(color: AppColors.blueTextColor),)
                  ),
                  const SizedBox(width: 20,),
                  if(screenType==0)TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.greyBackButton,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      onPressed: (){
                        setState(() {
                          widget.affirmations.removeWhere((element) => element==currentAffirmation);
                          currentAffirmation="";
                          currentEditIndex=-1;
                          currentIndex=-1;
                        });
                      },
                      child: const Text("Удалить", style: TextStyle(color: AppColors.blueTextColor))
                  )else TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: currentIndex==currentEditIndex?AppColors.pinkButtonTextColor:AppColors.greyBackButton,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      onPressed: (){
                        setState(() {
                          widget.isShuffle = false;
                          widget.onShuffleClick(widget.isShuffle);
                          currentIndex = currentEditIndex;
                          currentAffirmation = widget.affirmations[currentIndex];
                        });
                      },
                      child: const Text("Выбрать", style: TextStyle(color: AppColors.blueTextColor))
                  ),
                  const SizedBox(width: 19,),
                ],
              ),
              const SizedBox(height: 10),
              if(screenType==0)Expanded(child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                itemCount: widget.affirmations.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        screenType=1;
                        currentEditIndex=index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: currentIndex==index?AppColors.greytextColor:AppColors.greyBackButton,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child:Text(widget.affirmations[index], style: const TextStyle(fontSize: 16))),
                          //if(currentIndex==index)const Icon(Icons.check_circle_outline, color: Colors.black),
                        ],
                      ),
                    ),
                  );
                },
              ),)else Expanded(child: TextField(
                controller: controller,
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  filled: true, // Заливка фона
                  fillColor: AppColors.fieldFillColor, // Серый фон с полупрозрачностью
                  hintText: 'Напиши свое видение здесь. Как если бы эта сфера была бы на 10 из 10, как бы это было? Впиши основные критерии, по которым ты точно сможешь понять, что это максимум, что ты желаешь для этой области.', // Базовый текст
                  hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)), // Полупрозрачный черный базовый текст
                ),)
              ),
              /*const SizedBox(height: 5,),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  filled: true, // Заливка фона
                  fillColor: AppColors.fieldFillColor, // Серый фон с полупрозрачностью
                  hintText: 'Введите текст...', // Базовый текст
                  hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)), // Полупрозрачный черный базовый текст
                ),
              ),*/
              const SizedBox(height: 10,),
              if(screenType==0)Center(child: TextButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.fieldFillColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // <-- Radius
                  ),
                ),
                onPressed: (){
                  setState(() {
                    screenType=1;
                    widget.affirmations.add("");
                    controller.clear();
                    currentEditIndex = widget.affirmations.length-1;
                  });
                },
                child: const Text("Добавить", style: TextStyle(color: AppColors.greytextColor)),
              ),),
              if(MediaQuery.of(context).viewInsets.bottom!=0) SizedBox(height: 30,
                child: FooterLayout(
                  footer: Container(height: 30,color: Colors.white,alignment: Alignment.centerRight, child:
                  GestureDetector(
                    onTap: (){FocusManager.instance.primaryFocus?.unfocus();},
                    child: const Text("готово", style: TextStyle(fontSize: 20),),
                  )
                    ,),
                ),)
            ],
          )
      ),
    );
  }
}

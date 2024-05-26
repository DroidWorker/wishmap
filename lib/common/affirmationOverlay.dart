import 'dart:async';

import 'package:flutter/material.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';
import 'package:wishmap/interface_widgets/colorButton.dart';

import '../res/colors.dart';

Future<String?> showOverlayedAffirmations(BuildContext context, List<String> affirmations, bool isChecked, bool isShuffle, {Function(bool value)? onShuffleClick})async {
  Completer<String?> completer = Completer<String?>();
  OverlayEntry? overlayEntry;

    var myOverlay = MyAffirmationOverlay(affirmations: affirmations, isChecked: isChecked, isShuffle: isShuffle, onClose: (value) {
      overlayEntry?.remove();
      completer.complete(value);
    }, onShuffleClick: (value){
      onShuffleClick!(value);
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
  String oldValue = "";
  int currentIndex = -1;

  bool isAdding = false;

  int screenType = 0;//0 - default 1- aff edit
  @override
  Widget build(BuildContext context) {
    if(widget.isChecked&&currentAffirmation==""){
      currentAffirmation=widget.affirmations.first;
      if(!widget.isShuffle)currentIndex = 0;
    }
    if(isAdding){
    }else if(screenType==1&&currentIndex<widget.affirmations.length&&controller.text.isEmpty)
      {
        oldValue = widget.affirmations[currentIndex];
        controller.text=widget.affirmations[currentIndex];
      }
    return Positioned.fill(
      child: Material(
          color: AppColors.backgroundColor,
          child: Stack(
            children:[
              Column(
              children: [
                const SizedBox(height: 38),
                screenType==0?Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_left, size: 28, color: AppColors.gradientStart),
                      onPressed: () {
                          String finalAffs = currentAffirmation.isNotEmpty?currentAffirmation:"Новая аффирмация";
                          for (var element in widget.affirmations) {
                            if (element != currentAffirmation)
                              finalAffs += "|$element";
                          }
                          widget.onClose(finalAffs);
                      },
                    ),
                    const SizedBox(width: 40),
                    const Spacer(),
                    const Text("Аффирмации", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    IconButton(onPressed: (){
                      setState(() {
                        widget.isShuffle = !widget.isShuffle;
                        widget.onShuffleClick(widget.isShuffle);
                        if(widget.isShuffle)currentIndex=-1;
                      });
                    }, icon: Icon(Icons.shuffle, color: widget.isShuffle?AppColors.gradientEnd:AppColors.darkGrey, size: 28)),
                    IconButton(onPressed: (){
                      setState(() {
                        screenType=1;
                      });
                    }, icon: const Icon(Icons.edit, size: 28))
                    /*if(screenType==0)TextButton(
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
                            widget.affirmations[currentEditIndex] = controller.text;
                            widget.isShuffle = false;
                            widget.onShuffleClick(widget.isShuffle);
                            currentIndex = currentEditIndex;
                            currentAffirmation = widget.affirmations[currentIndex];
                          });
                        },
                        child: const Text("Выбрать", style: TextStyle(color: AppColors.blueTextColor))
                    ),
                    const SizedBox(width: 19,),*/
                  ],
                ):
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_left, size: 28, color: AppColors.gradientStart),
                      onPressed: () {
                          setState(() {
                            screenType = 0;
                            if(!isAdding)widget.affirmations[currentIndex] = oldValue;
                            isAdding = false;
                            controller.clear();
                          });
                      },
                    ),
                    const Spacer(),
                    Text(isAdding?"Новая аффирмация":"Редактировать", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    const SizedBox(width: 40)
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
                          widget.isShuffle = false;
                          widget.onShuffleClick(widget.isShuffle);
                          currentIndex=index;
                          currentAffirmation = widget.affirmations[currentIndex];
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: currentIndex==index?const LinearGradient(
                              colors: [AppColors.gradientStart, AppColors.gradientEnd]
                          ):null,
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child:Text(widget.affirmations[index], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400))),
                              //if(currentIndex==index)const Icon(Icons.check_circle_outline, color: Colors.black),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),)else Expanded(
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Впиши основные критерии, по которым ты точно\n сможешь понять, что это максимум, что ты делаешь",
                            style: TextStyle(fontSize: 12, color: AppColors.etGrey),
                            //textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TextField(
                              controller: controller,
                              maxLines: null,
                              maxLength: 220,
                              decoration: InputDecoration(
                                enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.etGrey)),
                                focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.etGrey)),
                                hintText: 'Введите текст Аффирмации', // Базовый текст
                                hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)), // Полупрозрачный черный базовый текст
                              ),),
                          )
                        ],
                  ),
                ),
              ],
            ),
              Positioned(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    if(screenType==0)Center(
                      child: GestureDetector(
                        onTap: (){
                          setState(() {
                            screenType=1;
                            controller.clear();
                            isAdding=true;
                          });
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration:  const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                  colors: [AppColors.gradientStart, AppColors.gradientEnd]
                              )
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 32),
                        ),
                      ),
                    )else Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ColorRoundedButton("Сохранить", () {
                        setState(() {
                          screenType = 0;
                          if(!isAdding) {
                            widget.affirmations[currentIndex] = controller.text;
                            if(widget.affirmations[currentIndex].isEmpty)widget.affirmations.removeAt(currentIndex);
                          } else{
                            widget.affirmations.add(controller.text);
                            currentIndex = widget.affirmations.length-1;
                            isAdding = false;
                            }
                          controller.clear();
                        });
                      }),
                    ),
                    const SizedBox(height: 24),
                    if(MediaQuery.of(context).viewInsets.bottom!=0) Align(
                      alignment: Alignment.topRight,
                      child: Container(height: 50, width: 50, 
                          margin: const EdgeInsets.fromLTRB(0, 0, 16, 16),
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ), child:
                      GestureDetector(
                        onTap: (){FocusManager.instance.primaryFocus?.unfocus();},
                        child: const Icon(Icons.keyboard_hide_sharp, size: 30, color: AppColors.darkGrey,),
                      )
                      ),
                    )
                  ],
                )
              ),
          ]
          )
      ),
    );
  }
}
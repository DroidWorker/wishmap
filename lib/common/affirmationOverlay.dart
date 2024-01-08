import 'dart:async';

import 'package:flutter/material.dart';

import '../res/colors.dart';

Future<String?> showOverlayedAffirmations(BuildContext context, List<String> affirmations, bool isChecked, bool isShuffle, {Function(bool value)? onShuffleClick})async {
  Completer<String?> completer = Completer<String?>();
  OverlayEntry? overlayEntry;

    var myOverlay = MyAffirmationOverlay(affirmations: affirmations, isChecked: isChecked, isShuffle: isShuffle, onClose: (value) {
      overlayEntry?.remove();
      completer.complete(value);
    }, onShuffleClick: (value){
      onShuffleClick!(value);
      showDialog(context: context,
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
      );
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
  @override
  Widget build(BuildContext context) {
    if(widget.isChecked&&currentAffirmation=="")currentAffirmation=widget.affirmations.first;
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
                      for (var element in widget.affirmations) {
                        if(element!=currentAffirmation) currentAffirmation+="|$element";
                      }
                      widget.onClose(currentAffirmation);
                    },
                  ),
                  const Spacer(),
                  TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.greyBackButton,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      onPressed: (){setState(() {
                        widget.isShuffle = !widget.isShuffle;
                        widget.onShuffleClick(widget.isShuffle);
                      });},
                      child: Text("Shuffle", style: TextStyle(color: widget.isShuffle?AppColors.blueTextColor:AppColors.pinkButtonTextColor),)
                  ),
                  const SizedBox(width: 20,),
                  TextButton(
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
                        });
                      },
                      child: const Text("Удалить", style: TextStyle(color: AppColors.blueTextColor))
                  ),
                  const SizedBox(width: 19,),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                itemCount: widget.affirmations.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        currentIndex = index;
                        currentAffirmation = widget.affirmations[index];
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.greyBackButton,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(widget.affirmations[index], style: const TextStyle(fontSize: 16)),
                          if(currentIndex==index)const Icon(Icons.check_circle_outline, color: Colors.black),
                        ],
                      ),
                    ),
                  );
                },
              ),),
              const SizedBox(height: 5,),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  filled: true, // Заливка фона
                  fillColor: AppColors.fieldFillColor, // Серый фон с полупрозрачностью
                  hintText: 'Введите текст...', // Базовый текст
                  hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)), // Полупрозрачный черный базовый текст
                ),
              ),
              const SizedBox(height: 10,),
              Center(child: TextButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.fieldFillColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // <-- Radius
                  ),
                ),
                onPressed: (){
                  setState(() {
                    widget.affirmations.add(controller.text);
                    controller.clear();
                  });
                },
                child: const Text("Добавить", style: TextStyle(color: AppColors.greytextColor)),
              ),)
            ],
          )
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';

import '../res/colors.dart';

Future<String?> showOverlayedAffirmations(BuildContext context, List<String> affirmations)async {
  Completer<String?> completer = Completer<String?>();
  OverlayEntry? overlayEntry;

    var myOverlay = MyAffirmationOverlay(affirmations: affirmations, onClose: (value) {
      overlayEntry?.remove();
      completer.complete(value);
    });

    overlayEntry = OverlayEntry(
      builder: (context) => myOverlay,
    );

    Overlay.of(context).insert(overlayEntry);
  return completer.future;
}

class MyAffirmationOverlay extends StatefulWidget {
  Function(String value) onClose;

  List<String> affirmations;

  MyAffirmationOverlay({super.key, required this.affirmations, required this.onClose});

  @override
  _MyOverlayState createState() => _MyOverlayState();
}

class _MyOverlayState extends State<MyAffirmationOverlay> {
  TextEditingController controller = TextEditingController();
  String currentAffirmation= "";
  int currentIndex = -1;
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
          color: AppColors.backgroundColor,
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_left),
                    onPressed: () {
                      widget.onClose(currentAffirmation);
                    },
                  ),
                  TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.greyBackButton,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      onPressed: (){},
                      child: const Text("Shuffle", style: TextStyle(color: AppColors.blueTextColor),)
                  ),
                  TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.greyBackButton,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      onPressed: (){},
                      child: Text("Удалить", style: TextStyle(color: AppColors.blueTextColor))
                  )
                ],
              ),
              const SizedBox(height: 15),
              ListView.builder(
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
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.greyBackButton,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(widget.affirmations[index], style: const TextStyle(fontSize: 18)),
                          if(currentIndex==index)const Icon(Icons.arrow_forward, color: Colors.black),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10,),
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

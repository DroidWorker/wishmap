import 'dart:async';

import 'package:flutter/material.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';

import '../res/colors.dart';

Future<String?> showOverlayedEdittext(BuildContext context, String text, bool isActive)async {
  Completer<String?> completer = Completer<String?>();
  OverlayEntry? overlayEntry;

  var myOverlay = MyETOverlay(isActive: isActive, text: text,  onClose: (value) {
    overlayEntry?.remove();
    completer.complete(value);
  });

  overlayEntry = OverlayEntry(
    builder: (context) => myOverlay,
  );

  Overlay.of(context).insert(overlayEntry);
  return completer.future;
}

class MyETOverlay extends StatefulWidget {
  Function(String value) onClose;

  bool isActive;
  String text = "";

  MyETOverlay({super.key, required this.isActive, required this.text, required this.onClose});

  @override
  _MyOverlayState createState() => _MyOverlayState();
}

class _MyOverlayState extends State<MyETOverlay> {
  TextEditingController controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    controller.text=widget.text;
    super.initState();
    _focusNode.requestFocus();
  }
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.backgroundColor,
      child: SafeArea(
        maintainBottomViewPadding: true,
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_left),
                  onPressed: () {
                    widget.onClose(controller.text);
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
                  onPressed: () {
                    widget.onClose(controller.text);
                  },
                  child: const Text("Готово", style: TextStyle(color: AppColors.blueTextColor)),
                ),
                const SizedBox(width: 10,),
              ],
            ),
            const SizedBox(height: 4),
            Expanded(
                child:
                    TextField(
                      controller: controller,
                      focusNode: _focusNode,
                      autofocus: true,
                      maxLines: null,
                      expands: true,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        filled: true,
                        fillColor: AppColors.fieldFillColor,
                        hintText: 'Введите текст...',
                        hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
                      ),
              ),
            ),
            /*if(MediaQuery.of(context).viewInsets.bottom!=0) SizedBox(height: 30,
              child: FooterLayout(
                footer: Container(height: 30,color: Colors.white,alignment: Alignment.centerRight, child:
                GestureDetector(
                  onTap: (){FocusManager.instance.primaryFocus?.unfocus();},
                  child: const Text("готово", style: TextStyle(fontSize: 20),),
                )
                  ,),
              ),),*/
            Container(
              height: MediaQuery.of(context).viewInsets.bottom > 0 ? MediaQuery.of(context).viewInsets.bottom : 1,
            ),
          ],
        ),
      ),
    );
  }
}
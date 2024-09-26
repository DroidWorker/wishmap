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
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
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
                    onPressed: () {
                      widget.onClose(controller.text);
                    },
                  ),
                  const Text("Описание", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(width: 30)
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
                          hintText: 'Введите текст...',
                          hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
                        ),
                ),
              ),
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
              ),
              Container(
                height: MediaQuery.of(context).viewInsets.bottom > 0 ? MediaQuery.of(context).viewInsets.bottom : 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
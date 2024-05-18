import 'dart:async';

import 'package:flutter/material.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';
import 'package:lottie/lottie.dart';

import '../res/colors.dart';

showOverlayedAnimations(BuildContext context) {
  OverlayEntry? overlayEntry;

  var myOverlay = MyAnimationOverlay((){
    overlayEntry?.remove();
  });

  overlayEntry = OverlayEntry(
    builder: (context) => myOverlay,
  );

  Overlay.of(context).insert(overlayEntry);
}

class MyAnimationOverlay extends StatefulWidget{
  Function() onClose;

  MyAnimationOverlay(this.onClose, {super.key});

  @override
  MyAnimationOverlayState createState() => MyAnimationOverlayState();
}

class MyAnimationOverlayState extends State<MyAnimationOverlay> with TickerProviderStateMixin{
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller= AnimationController(vsync: this);
    controller.addStatusListener((status) {
      if(status==AnimationStatus.completed){
        widget.onClose();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child:  Center(
            child: Container(
              width: 100,
              height: 100,
              color: AppColors.backgroundColor,
              child: Lottie.asset(
                  'assets/lottie/testanim.json',
                  width: 100,
                  height: 100,
                  fit: BoxFit.fill,
                  controller: controller,
                onLoaded: (composition) {
                  // Configure the AnimationController with the duration of the
                  // Lottie file and start the animation.
                  controller
                    ..duration = composition.duration
                    ..forward();
                },
              ),
            )
      ),
    );
  }
}

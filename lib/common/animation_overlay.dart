import 'dart:async';

import 'package:flutter/material.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';
import 'package:lottie/lottie.dart';

import '../res/colors.dart';

showOverlayedAnimations(BuildContext context, String path, {bool fillBackground = false, Function(AnimationController controller)? onControllerCreated}) {
  OverlayEntry? overlayEntry;

  var myOverlay = MyAnimationOverlay(path, fillBackground, (){
    overlayEntry?.remove();
  }, onControllerCreated: onControllerCreated);

  overlayEntry = OverlayEntry(
    builder: (context) => myOverlay,
  );

  Overlay.of(context).insert(overlayEntry);
}

class MyAnimationOverlay extends StatefulWidget{
  Function() onClose;
  Function(AnimationController c)? onControllerCreated;
  String path;
  bool fillBackground;

  MyAnimationOverlay(this.path, this.fillBackground, this.onClose, {this.onControllerCreated, super.key});

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
      if(status==AnimationStatus.completed||status==AnimationStatus.dismissed){
        controller.dispose();
        widget.onClose();
      }
    });
    if(widget.onControllerCreated!=null){
      widget.onControllerCreated!(controller);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: widget.fillBackground?BoxDecoration(
                shape: BoxShape.circle,
                  gradient: RadialGradient(radius: 0.6, focalRadius: 0.99,colors: [Colors.grey.shade400, Colors.grey.shade200.withOpacity(0.0)])
              ):null,
              child: Lottie.asset(
                  widget.path,
                  width: 300,
                  height: 300,
                  fit: BoxFit.fill,
                  controller: controller,
                onLoaded: (composition) {
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

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wishmap/interface_widgets/outlined_button.dart';

import '../interface_widgets/colorButton.dart';
import '../res/colors.dart';

class CameraWidget extends StatefulWidget {
  final Function(File? f) onClose;
  const CameraWidget(this.onClose, {super.key});

  @override
  State<CameraWidget> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraWidget> {
  late List<CameraDescription> _cameras;
  CameraController? controller;

  File? f;
  bool applyActive= false;

  _initializeCamera() async{
    _cameras = await availableCameras();
    controller = CameraController(_cameras[0], ResolutionPreset.max);
    controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            Permission.camera.request();
            widget.onClose(null);
            break;
          default:
          // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller==null||!controller!.value.isInitialized) {
      return Container();
    }
    return MaterialApp(
      home: Stack(
        fit: StackFit.expand,
       children: [
         CameraPreview(controller!),
         Positioned(
           left: 16,
             top: 26,
             child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () {
                if(applyActive){
                  controller?.resumePreview();
                  setState(() {applyActive=false;});
                } else widget.onClose(null);
             },)
         ),
         Align(
           alignment: Alignment.bottomCenter,
           child: GestureDetector(
             onTap: () async {
               setState(() {
                 applyActive = true;
               });
               controller?.takePicture().then((XFile? file) {
                 if (mounted) {
                   controller?.pausePreview();
                   setState(() {
                     if(file!=null)f = File(file.path);
                   });
                   if (file != null) {
                     print('Picture saved to ${file.path}');
                   }else {
                     print("picture is nuull");
                   }
                 }
               });
             },
             child: AnimatedContainer(
               width: applyActive?0:50, height: applyActive?0:50,
                 margin: const EdgeInsets.only(bottom: 20),
                 duration: const Duration(milliseconds: 300),
               decoration: BoxDecoration(
                 color: AppColors.backgroundColor,
                 shape: BoxShape.circle,
                 border: Border.all(color: AppColors.gradientEnd, width: 2)
               ),
             ),
           ),
         ),
         if(applyActive)Align(
           alignment: Alignment.bottomCenter,
           child: Container(
             margin: const EdgeInsets.only(bottom: 15),
             child: RawMaterialButton(
               onPressed: () {
                 widget.onClose(f);
               },
               elevation: 1.0,
               fillColor: Colors.white.withOpacity(0.5),
               shape: const CircleBorder(),
               child: const Icon(
                 Icons.add_task,
                 size: 40.0,
               ),
             ),
           )
         )
       ]
      )
    );
  }
}
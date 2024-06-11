import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:voice_message_package/voice_message_package.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import 'package:wishmap/common/gallery_widget.dart';
import 'package:wishmap/interface_widgets/animated_rounded_button.dart';
import 'package:wishmap/interface_widgets/custom_textfield.dart';

import '../res/colors.dart';

Future<Map<String?, List<String>>> showDiaryOverlayedEdittext(BuildContext context, String text, bool isAttachmentsBarActive, )async {
  Completer<Map<String?, List<String>>> completer = Completer<Map<String?, List<String>>>();
  OverlayEntry? overlayEntry;

  var myOverlay = MyDETOverlay(isActive: isAttachmentsBarActive, text: text,  onClose: (text, paths) {
    overlayEntry?.remove();
    completer.complete({text: paths});
  });

  overlayEntry = OverlayEntry(
    builder: (context) => myOverlay,
  );

  Overlay.of(context).insert(overlayEntry);
  return completer.future;
}

class MyDETOverlay extends StatefulWidget {
  Function(String value, List<String> attachmentsPath) onClose;

  bool isActive;
  String text = "";

  MyDETOverlay({super.key, required this.isActive, required this.text, required this.onClose});


  @override
  _MyOverlayState createState() => _MyOverlayState();
}

class _MyOverlayState extends State<MyDETOverlay> {
  TextEditingController controller = TextEditingController();
  final _focusNode = FocusNode();
  List<String> attachments = [];
  List<String> images = [];
  List<String> records = [];

  var contentType = 0;
  //0-edittext
  //1-galleryPicker
  //3-voiceRecorder

  @override
  void initState() {
    controller.text=widget.text;
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    if(attachments.isNotEmpty) {
      images.clear();
      records.clear();
      for (var element in attachments) {
        element.contains(".photo")||element.contains(".jpg")?images.add(element):records.add(element);
      }
    }
    return Material(
      color: AppColors.backgroundColor,
      child: SafeArea(
        maintainBottomViewPadding: true,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_left),
                    onPressed: () {
                      widget.onClose(controller.text, attachments);
                    },
                  ),
                  const Text("Создать запись", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      style: const ButtonStyle(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap, // the '2023' part
                      ),
                      icon: SvgPicture.asset("assets/icons/trash.svg", width: 24, height: 24),
                      onPressed: () {

                      },
                    ),
                  ),
                ],
              ),
              Expanded(
                  child: widget.isActive?(
                      contentType==0?CustomTextField(controller):contentType==1?Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RoundedPhotoGallery(onClick: (image) async {
                          final String filename = "${DateTime.timestamp()}.photo";
                          final String path = "${(await getApplicationDocumentsDirectory()).path}/$filename";
                          final file = File(path);
                          await file.writeAsBytes(image);
                          attachments.add(path);
                          setState(() {
                            contentType=0;
                          });
                        }),
                      ):const SizedBox(
                      )):TextField(
                    controller: controller,
                    focusNode: _focusNode,
                    autofocus: true,
                    maxLines: null,
                    expands: true,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      filled: true,
                      fillColor: AppColors.backgroundColor,
                      hintText: 'Напишите....',
                      hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
                    ),
                  )
              ),
              SizedBox(
                height: 66,
                child: Expanded(
                  child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      scrollDirection: Axis.horizontal,
                        itemCount: images.length,
                        itemBuilder: (BuildContext context, int index){
                      return Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.file(File(images[index]), fit: BoxFit.cover, width: 50, height: 50,),
                          )
                      );
                    }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: records.length,
                    itemBuilder: (BuildContext context, int index){
                      print("play - ${records[index]}");
                      return VoiceMessageView(controller: VoiceController(
                        audioSrc: records[index],
                        onComplete: () {
                          /// do something on complete
                        },
                        onPause: () {
                          /// do something on pause
                        },
                        onPlaying: () {
                          /// do something on playing
                        },
                        onError: (err) {
                          print("error ${err.toString()}");
                        },
                        maxDuration: const Duration(seconds: 60),
                        isFile: true,
                      ),
                      innerPadding: 4,
                      cornerRadius: 12,
                      activeSliderColor: AppColors.gradientEnd,
                      circlesColor: AppColors.gradientEnd,);
                    }),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.isActive?
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(onPressed: (){
                                setState(() {
                                  contentType=1;
                                });
                              }, icon: SvgPicture.asset('assets/icons/gallery.svg', height: 24, width: 24)),
                              IconButton(onPressed: () async {
                                final AssetEntity? entity = await CameraPicker.pickFromCamera(
                                  context,
                                  locale: const Locale.fromSubtags(languageCode: "en"),
                                  pickerConfig: CameraPickerConfig(
                                    theme: ThemeData.dark().copyWith(
                                      primaryColor: Colors.white,
                                      primaryColorLight: Colors.white,
                                      primaryColorDark: Colors.grey[900],
                                      canvasColor: Colors.grey[850],
                                      scaffoldBackgroundColor: Colors.grey[900],
                                      cardColor: Colors.grey[900],
                                      highlightColor: Colors.transparent,
                                      appBarTheme: const AppBarTheme(
                                        systemOverlayStyle: SystemUiOverlayStyle(
                                          statusBarBrightness: Brightness.light,
                                          statusBarIconBrightness: Brightness.light,
                                        ),
                                        elevation: 0,
                                      ),
                                      colorScheme: ColorScheme(
                                        primary: Colors.white,
                                        primaryContainer:  Colors.white,
                                        secondary:  Colors.white,
                                        secondaryContainer:  Colors.white,
                                        background: Colors.grey[200]!,
                                        surface: Colors.grey[200]!,
                                        brightness: Brightness.dark,
                                        error: const Color(0xffcf6679),
                                        onPrimary:  Colors.white,
                                        onSecondary:  Colors.white,
                                        onSurface: Colors.white,
                                        onBackground: Colors.white,
                                        onError: Colors.black,
                                      ),
                                    )
                                  ),
                                );
                                if(entity!=null){
                                  final file = await entity.file;
                                  final String path = "${(await getApplicationDocumentsDirectory()).path}/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
                                    final resultFile = await file?.copy(path);
                                  setState(() {
                                    if(resultFile!=null)attachments.add(resultFile.path);
                                  });
                                }
                              }, icon: SvgPicture.asset('assets/icons/camera.svg', height: 24, width: 24)),
                              AnimatedRoundIconButton(icon: SvgPicture.asset('assets/icons/voice.svg', height: 24, width: 24), onTouchDown: () async {
                              }, onTouchUp: (path){
                                setState(() {
                                  attachments.add(path);
                                });
                              })
                          ],
                          ),
                        ),
                      ):
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: FloatingActionButton(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      onPressed: (){

                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 30,
                          color: AppColors.gradientEnd,
                        ),
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
                  ]
              ),
              Container(
                height: MediaQuery.of(context).viewInsets.bottom > 0 ? MediaQuery.of(context).viewInsets.bottom : 6,
              ),
            ],
          ),
      ),
    );
  }
}
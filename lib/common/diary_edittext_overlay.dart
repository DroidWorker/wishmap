import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/common/gallery_widget.dart';
import 'package:wishmap/dialog/camera_dialog.dart';
import 'package:wishmap/interface_widgets/animated_rounded_button.dart';
import 'package:wishmap/interface_widgets/custom_textfield.dart';

import '../ViewModel.dart';
import '../data/models.dart';
import '../dialog/bottom_sheet_action.dart';
import '../res/colors.dart';

Future<Map<String?, List<String>>> showDiaryOverlayedEdittext(BuildContext context, String text, Article? article, bool isAttachmentsBarActive, )async {
  Completer<Map<String?, List<String>>> completer = Completer<Map<String?, List<String>>>();
  OverlayEntry? overlayEntry;

  var myOverlay = MyDETOverlay(isActive: isAttachmentsBarActive, text: text, article: article, onClose: (text, paths, id) {
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
  Function(String value, List<String> attachmentsPath, int? articleId) onClose;

  bool isActive;
  String text = "";
  Article? article;
  List<String> attachments = [];

  MyDETOverlay({super.key, required this.isActive, required this.text, this.article, required this.onClose});


  @override
  _MyOverlayState createState() => _MyOverlayState();
}

class _MyOverlayState extends State<MyDETOverlay> {
  TextEditingController controller = TextEditingController();
  final _focusNode = FocusNode();
  List<String> attachments = [];
  List<String> images = [];
  List<String> records = [];

  bool isToolBarActive = true;

  var contentType = 0;
  //0-edittext
  //1-galleryPicker
  //3-voiceRecorder


  @override
  void initState() {
    controller.text=widget.text;
    if(widget.article!=null) {
      attachments = widget.article!.attachments;
      for (var element in widget.article!.attachments) {
        element.contains(".photo") || element.contains(".jpg") ? images.add(
            element) : records.add(element);
      }
    }
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    if(attachments.isNotEmpty) {
      images.clear();
      records.clear();
      for (var element in attachments) {
        if(element.isNotEmpty)element.contains(".photo")||element.contains(".jpg")?images.add(element):records.add(element);
      }
    }
    final appVM = Provider.of<AppViewModel>(context);
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
                      widget.onClose(controller.text, attachments, widget.article?.id);
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
                        setState(() {
                          if(widget.article!=null){
                            showModalBottomSheet<bool>(
                              backgroundColor: AppColors.backgroundColor,
                              context: context,
                              isScrollControlled: true,
                              builder: (BuildContext context) {
                                return ActionBS('Удалить', "", "Да", 'Нет',
                                    onOk: () async {
                                      Navigator.pop(context, true);
                                      appVM.deleteDiaryArticle(widget.article!.id);
                                      widget.onClose("", [], null);
                                    },
                                    onCancel: () { Navigator.pop(context, true);
                                    appVM.isChanged=false;}
                                );
                              },
                            );
                          }else{
                            widget.onClose("", [], null);
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
              Expanded(
                  child: widget.isActive?(
                      contentType==0?CustomTextField(key: ValueKey(attachments.length),controller: controller, attachments: attachments,):contentType==1?Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RoundedPhotoGallery(onClick: (image) async {
                          final String filename = "${DateTime.timestamp()}.photo";
                          final String path = "${(await getApplicationDocumentsDirectory()).path}/$filename";
                          final file = File(path);
                          await file.writeAsBytes(image);
                          attachments.add(path);
                          controller.text+="_attach_";
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
              /*Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: records.length,
                    itemBuilder: (BuildContext context, int index){
                      print("play - ${records[index]}");
                      return Row(
                        children: [
                          Expanded(
                            child: VoiceMessageView(controller: VoiceController(
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
                            circlesColor: AppColors.gradientEnd,),
                          ),
                          IconButton(onPressed: (){}, icon: const Icon(Icons.close))
                        ],
                      );
                    }),
              ),*/
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  (widget.isActive&&isToolBarActive)?
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
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
                                  isToolBarActive = false;
                                });
                              }, icon: const Icon(Icons.close, color: AppColors.darkGrey,)),
                              IconButton(onPressed: (){
                                setState(() {
                                  contentType=1;
                                });
                              }, icon: SvgPicture.asset('assets/icons/gallery.svg', height: 24, width: 24)),
                              IconButton(onPressed: () async {
                                /*final AssetEntity? entity = await CameraPicker.pickFromCamera(
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
                                    if(resultFile!=null){
                                      attachments.add(resultFile.path);
                                      controller.text+="_attach_";
                                      setState(() {});
                                    }
                                  });
                                }*/
                                showModalBottomSheet<void>(
                                    backgroundColor: AppColors.backgroundColor,
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (BuildContext context) {
                                        return CameraWidget((file) async {
                                          Navigator.pop(context, 'OK');
                                          final String path = "${(await getApplicationDocumentsDirectory()).path}/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
                                          final resultFile = await file?.copy(path);
                                          setState(() {
                                          if(resultFile!=null){
                                            attachments.add(resultFile.path);
                                            controller.text+="_attach_";
                                            setState(() {});
                                          }
                                          });
                                        });
                                    });
                              }, icon: SvgPicture.asset('assets/icons/camera.svg', height: 24, width: 24)),
                              AnimatedRoundIconButton(icon: SvgPicture.asset('assets/icons/voice.svg', height: 24, width: 24), onTouchDown: () async {
                              }, onTouchUp: (path){
                                attachments.add(path);
                                controller.text+="_attach_";
                                setState(() {});
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
                        setState(() {
                          isToolBarActive = true;
                        });
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
                  if(MediaQuery.of(context).viewInsets.bottom!=0&&Platform.isIOS) Align(
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
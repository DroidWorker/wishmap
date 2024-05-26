import 'dart:async';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wishmap/interface_widgets/colorButton.dart';
import 'package:wishmap/repository/photosSearch.dart';

import '../interface_widgets/outlined_button.dart';
import '../res/colors.dart';

Future<Uint8List?> showOverlayedImageManager(BuildContext context, String url, {int mode = 0, Uint8List? image}) {
  Completer<Uint8List?> completer = Completer<Uint8List?>();
  OverlayEntry? overlayEntry;

  var myOverlay = MyImageManageOverlay(url: url, mode: mode, image: image, onClose: (photo) {
    overlayEntry?.remove();
    completer.complete(photo);
  });

  overlayEntry = OverlayEntry(
    opaque: true,
    builder: (context) => myOverlay,
  );

  Overlay.of(context).insert(overlayEntry);
  return completer.future;
}

class MyImageManageOverlay extends StatefulWidget {
  int mode;
  String url;
  Uint8List? image;
  Function(Uint8List? photo) onClose;

  MyImageManageOverlay({super.key, required this.url, required this.image, required this.onClose, this.mode=0});

  @override
  _MyOverlayState createState() => _MyOverlayState();
}

class _MyOverlayState extends State<MyImageManageOverlay> {
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: SafeArea(
        child: Material(
            color: AppColors.backgroundColor,
            child: Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_left, size: 24,),
                        onPressed: () => widget.onClose(null),
                      ),
                      const Text("Добавить образ", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),),
                      const SizedBox(width: 24)
                    ],
                  ),
                  const Spacer(),
                  widget.image==null?ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                    imageUrl: widget.url,
                    placeholder: (context, url) => const CircularProgressIndicator(color: AppColors.darkGrey,),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                    fit: BoxFit.cover,
                  )):ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(widget.image!, fit: BoxFit.cover)),
                  const SizedBox(height: 16),
                  const Spacer(),
                  ColorRoundedButton(widget.mode==0?"Добавить":"Удалить", c: widget.mode==1?AppColors.buttonBackRed:null, () async {
                    final result = widget.image ?? await GRepository.loadImage(widget.url);
                    widget.onClose(result);
                  }),
                  const SizedBox(height: 8),
                  OutlinedGradientButton("Отмена", () => widget.onClose(null)),
                ],
              ),
            )
        ),
      ),
    );
  }
}

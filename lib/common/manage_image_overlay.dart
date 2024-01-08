import 'dart:async';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wishmap/repository/photosSearch.dart';

import '../res/colors.dart';

Future<Uint8List?> showOverlayedImageManager(BuildContext context, String url, {int mode = 0, Uint8List? image}) {
  Completer<Uint8List?> completer = Completer<Uint8List?>();
  OverlayEntry? overlayEntry;

  var myOverlay = MyImageManageOverlay(url: url, mode: mode, image: image, onClose: (photo) {
    overlayEntry?.remove();
    completer.complete(photo);
  });

  overlayEntry = OverlayEntry(
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
      child: Material(
          color: Color.fromARGB(180, 22, 22, 22),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                widget.image==null?CachedNetworkImage(
                  imageUrl: widget.url,
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fit: BoxFit.cover,
                ):Image.memory(widget.image!, fit: BoxFit.cover),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(onPressed: (){widget.onClose(null);},
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.greyBackButton,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        child: const Text("Отменить", textAlign: TextAlign.center, style: TextStyle(fontSize:10, color: Colors.black))),
                    widget.mode==0?TextButton(onPressed: () async {
                      final result = await GRepository.loadImage(widget.url);
                      widget.onClose(result);
                    },
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.greyBackButton,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        child: const Text("Добавить в мои образы", textAlign: TextAlign.center, style: TextStyle(fontSize:10, color: Colors.black))):
                    TextButton(onPressed: () async {
                      widget.onClose(Uint8List(0));
                    },
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.greyBackButton,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        child: const Text("Удалить", textAlign: TextAlign.center, style: TextStyle(fontSize:10, color: Colors.black)))
                  ],
                )
              ],
            ),
          )
      ),
    );
  }
}

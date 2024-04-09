import 'package:flutter/material.dart';
import '../res/colors.dart';

showOverlayedDetails(BuildContext context, String text) {
  OverlayEntry? overlayEntry;
  bool isVisible = false;

  void _toggleOverlay(){
    if(isVisible){
      overlayEntry?.remove();
      isVisible = false;
    } else{
      var myOverlay = MyOverlay(text: text,  onClose: () {
        _toggleOverlay();
      });
      overlayEntry = OverlayEntry(
        builder: (context) => myOverlay
      );
      Overlay.of(context).insert(overlayEntry!);
      isVisible = true;
    }
  }
  _toggleOverlay();
}

class MyOverlay extends StatefulWidget {
  Function() onClose;

  String text = "";

  MyOverlay({super.key, required this.text, required this.onClose});

  @override
  _MyOverlayState createState() => _MyOverlayState();
}

class _MyOverlayState extends State<MyOverlay> {

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 60),
    child: Material(
      color: Colors.white,
      elevation: 8,
      borderRadius: const BorderRadius.all(Radius.circular(15)),
      child: SafeArea(
        maintainBottomViewPadding: true,
        child: Column(
          children: [
            Row(
              children: [
                const Spacer(),
                const Text("Подробнее", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    widget.onClose();
                  },
                ),
                const SizedBox(width: 10,),
              ],
            ),
            const SizedBox(height: 4),
            Expanded(
              child:
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  widget.text,
                  maxLines: null,
                ),
              )
            )
          ],
        ),
      ),
    ),);
  }
}
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:voice_message_package/voice_message_package.dart';

import '../res/colors.dart';


class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final List<String> attachments;

  const CustomTextField({super.key, required this.controller, required this.attachments});

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _controllers = [];
    final data = widget.controller.text;
    List<String> lines = data.split('\n');
    _controllers.add(TextEditingController(text: lines[0]));
    lines.removeAt(0);
    final othertext = lines.join("\n");
    List<String> parts = othertext.split('_attach_');
    for (var part in parts) {
      if (part.isNotEmpty) {
        _controllers.add(TextEditingController(text: part));
      }else{
        _controllers.add(TextEditingController(text: " "));
      }
    }
  }

  void _updateMainController() {
    String updatedText = "";
    int imageCounter = 0;

    // Добавляем первую строку
    if (_controllers.isNotEmpty) {
      updatedText += _controllers[0].text;
    }

    for (int i = 1; i < _controllers.length; i++) {
      updatedText += '\n${_controllers[i].text}';
      if (imageCounter < widget.attachments.length) {
        updatedText += '_attach_';
        imageCounter++;
      }
    }

    widget.controller.text = updatedText.trim();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    int imageIndex = 0;

    for (int i = 0; i < _controllers.length; i++) {
      if (i == 0 || _controllers[i].text.isNotEmpty) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Container(
              constraints: const BoxConstraints(minHeight: 40, minWidth: 40),
              child: TextField(
                controller: _controllers[i],
                maxLines: null,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: _controllers[i].text,
                  hintStyle: TextStyle(
                    fontWeight: i == 0 ? FontWeight.bold : FontWeight.normal,
                    fontSize: i == 0 ? 16 : 14,
                    color: Colors.black,
                  ),
                ),
                style: TextStyle(
                  fontWeight: i == 0 ? FontWeight.bold : FontWeight.normal,
                  fontSize: i == 0 ? 16 : 14,
                ),
                onChanged: (text) {
                  _updateMainController();
                },
              ),
            ),
          ),
        );
      }

      if (i>0 && i < _controllers.length && imageIndex < widget.attachments.length) {
        children.add(
          (widget.attachments[imageIndex].contains(".photo")||widget.attachments[imageIndex].contains(".jpg"))?Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Image.file(
              File(widget.attachments[imageIndex]),
              height: 150,
              fit: BoxFit.fitHeight,
            ),
          ): VoiceMessageView(controller: VoiceController(
            audioSrc: widget.attachments[imageIndex],
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
        );
        imageIndex++;
      }
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
/*class CustomTextField extends StatefulWidget {
  CustomTextField(this._controller, {required this.imagePaths, super.key});

  final TextEditingController _controller;
  final List<String> imagePaths;

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget._controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              TextField(
                controller: widget._controller,
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
                style: const TextStyle(color: Colors.transparent), // Make the text transparent
                cursorColor: Colors.transparent, // Make the cursor transparent
                // Disable selection to prevent user from seeing the selection handles
                enableInteractiveSelection: false,
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: buildRichText(widget._controller.text, widget.imagePaths),
              ),
            ],
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}
*/
Widget buildRichText(String text, List<String> imagePaths) {
  List<InlineSpan> spans = [];
  List<String> lines = text.split('\n');
  int imageIndex = 0;

  for (int i = 0; i < lines.length; i++) {
    String line = lines[i];
    List<String> parts = line.split('_attach_');

    for (int j = 0; j < parts.length; j++) {
      if (parts[j].isNotEmpty) {
        spans.add(
          TextSpan(
            text: parts[j],
            style: TextStyle(
              height: i == 0 ? 2.2 : null,
              textBaseline: TextBaseline.alphabetic,
              fontWeight: i == 0 ? FontWeight.bold : FontWeight.normal,
              fontSize: i == 0 ? 16 : 14,
              color: Colors.black, // Set text color
            ),
          ),
        );
      }

      if (j < parts.length - 1 && imageIndex < imagePaths.length) {
        spans.add(const TextSpan(text: '\n')); // Add a newline before the image
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Image.file(File(imagePaths[imageIndex]), height: 150, fit: BoxFit.fitHeight,),
            ),
          ),
        );
        spans.add(const TextSpan(text: '\n')); // Add a newline after the image
        imageIndex++;
      }
    }

    if (i < lines.length - 1) {
      spans.add(const TextSpan(text: '\n'));
    }
  }

  return RichText(
    text: TextSpan(
      style: const TextStyle(color: Colors.black),
      children: spans,
    ),
  );
}
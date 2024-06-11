import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../res/colors.dart';

class CustomTextField extends StatefulWidget {
  CustomTextField(this._controller, {super.key});

  final TextEditingController _controller;

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  FocusNode _focusNode = FocusNode();

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
                child: buildRichText(widget._controller.text),
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

Widget buildRichText(String text) {
  List<TextSpan> spans = [];
  List<String> lines = text.split('\n');

  for (int i = 0; i < lines.length; i++) {
    String line = lines[i];
    spans.add(
      TextSpan(
        text: line + (i < lines.length - 1 ? '\n' : ''),
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

  return RichText(
    text: TextSpan(
      style: const TextStyle(color: Colors.black),
      children: spans,
    ),
  );
}
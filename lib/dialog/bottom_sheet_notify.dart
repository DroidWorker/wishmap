import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wishmap/interface_widgets/colorButton.dart';
import 'package:wishmap/interface_widgets/outlined_button.dart';

import '../res/colors.dart';

class NotifyBS extends StatelessWidget {
  NotifyBS(this.title, this.subtitle, this.okText, {required this.onOk, super.key});

  String title;
  String subtitle;
  String okText;
  Function() onOk;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 22),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
          Text(subtitle),
          const SizedBox(height: 16),
          ColorRoundedButton(okText, c: AppColors.buttonBackRed, () => onOk()),
          const SizedBox(height: 40)
        ],
      ),
    );
  }
}
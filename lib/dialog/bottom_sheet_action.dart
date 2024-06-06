import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wishmap/interface_widgets/colorButton.dart';
import 'package:wishmap/interface_widgets/outlined_button.dart';

class ActionBS extends StatelessWidget {
  ActionBS(this.title, this.subtitle, this.okText, this.cancelText, {required this.onOk, required this.onCancel, super.key});

  String title;
  String subtitle;
  String okText;
  String cancelText;
  Function() onOk;
  Function() onCancel;

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
          Row(
            children: [
              Expanded(child: OutlinedGradientButton(cancelText, () => onCancel())),
              const SizedBox(width: 8),
              Expanded(child: ColorRoundedButton(okText, () => onOk()))
            ],
          ),
          const SizedBox(height: 40)
        ],
      ),
    );
  }
}
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wishmap/interface_widgets/colorButton.dart';

import '../../dialog/bottom_sheet_notify.dart';
import '../../navigation/navigation_block.dart';
import '../../res/colors.dart';

class ProposalScreen extends StatelessWidget {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  style: const ButtonStyle(
                    tapTargetSize:
                        MaterialTapTargetSize.shrinkWrap, // the '2023' part
                  ),
                  icon: const Icon(Icons.keyboard_arrow_left,
                      size: 28, color: AppColors.gradientStart),
                  onPressed: () {
                    BlocProvider.of<NavigationBloc>(context).handleBackPress();
                  }),
              const Text("Предложения",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(width: 30)
            ],
          ),
          Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              const Text(
                  "Напишите нам свои предложения по разработке и улучшению функционала",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.greytextColor)),
              const SizedBox(height: 8),
              TextField(
                maxLength: 260,
                minLines: 5,
                maxLines: null,
                controller: controller,
                showCursor: false,
                style: const TextStyle(color: Colors.black),
                // Черный текст ввода
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: AppColors.greytextColor)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: Colors.black.withOpacity(0.3))), // your color
                  counterText: "",
                  filled: false,
                  hintText: 'Введите текст предложения',
                  // Базовый текст
                  hintStyle: TextStyle(
                      color: Colors.black.withOpacity(
                          0.3)), // Полупрозрачный черный базовый текст
                ),
              ),
              const Spacer(),
              ColorRoundedButton("Отправить", () {
                showModalBottomSheet<void>(
                  backgroundColor: AppColors.backgroundColor,
                  context: context,
                  isScrollControlled: true,
                  builder: (BuildContext c) {
                    return NotifyBS('Отправлено', "", 'OK', onOk: () {
                      BlocProvider.of<NavigationBloc>(context)
                          .handleBackPress();
                      Navigator.pop(c, 'OK');
                    });
                  },
                );
              })
            ],
          ))
        ],
      ),
    )));
  }
}

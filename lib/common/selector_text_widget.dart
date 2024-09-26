import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../ViewModel.dart';
import '../res/colors.dart';
import 'detailsOverlay.dart';
import 'gradientText.dart';

class SelectorTextWidget extends StatefulWidget {
  final AppViewModel appViewModel;
  final double maxHeight;

  SelectorTextWidget({required this.appViewModel, required this.maxHeight});

  @override
  _SelectorTextWidgetState createState() => _SelectorTextWidgetState();
}

class _SelectorTextWidgetState extends State<SelectorTextWidget> {
  bool disposed = true;
  @override
  void initState() {
    super.initState();
    widget.appViewModel.onChange = () {
      if(!disposed)setState(() {}); // Вызываем setState для перестройки виджета
    };
  }

  @override
  Widget build(BuildContext context) {
    disposed = false;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 7, // changes position of shadow
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Text(widget.appViewModel.hint, maxLines: widget.maxHeight~/22)),
          const Divider(color: AppColors.backgroundColor, height: 8,),
          TextButton(onPressed: (){
            showModalBottomSheet<void>(
              backgroundColor: AppColors.backgroundColor,
              context: context,
              isScrollControlled: true,
              builder: (BuildContext context) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                    const Text("Подробнее", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 16, width: double.infinity),
                    Text(widget.appViewModel.hint)
                  ],
                  ),
                );
              },
            );
          }, child: const Row(
            children: [
              GradientText("Показать всё", gradient: LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd]),),
              Spacer(),
              GradientText(">", gradient: LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd]),)
            ],
          ))
        ],
      ),
    );
  }

  @override
  void dispose() {
    disposed=true;
    super.dispose();
  }
}
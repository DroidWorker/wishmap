import 'dart:typed_data';

import 'package:capped_progress_indicator/capped_progress_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../res/colors.dart';

Widget buildSingle(double width, Uint8List image, bool isinLoading, bool filtered){
  return Container(width: width, height: width/2, color: AppColors.fieldFillColor,
    child: isinLoading? const Align(alignment: Alignment.bottomCenter,
      child: LinearCappedProgressIndicator(
        backgroundColor: Colors.black26,
        color: Colors.black,
        cornerRadius: 0,
      ),): Image.memory(image, fit: BoxFit.cover, color: !filtered?null:Colors.redAccent),
  );
}
Widget buildTwin(double leftwidth, double rightwidth, List<Uint8List> images, bool isinLoading, bool filtered){
  return Row(
    children: [
      Container(width: leftwidth, height: leftwidth, color: AppColors.fieldFillColor,
        child: isinLoading? const Align(alignment: Alignment.bottomCenter,
          child: LinearCappedProgressIndicator(
            backgroundColor: Colors.black26,
            color: Colors.black,
            cornerRadius: 0,
          ),): Image.memory(images[0], fit: BoxFit.cover, color: !filtered?null:Colors.redAccent),
      ),
      Container(width: rightwidth, height: leftwidth, color: AppColors.fieldFillColor,
        child: isinLoading? const Align(alignment: Alignment.bottomCenter,
          child: LinearCappedProgressIndicator(
            backgroundColor: Colors.black26,
            color: Colors.black,
            cornerRadius: 0,
          ),): Image.memory(images[1], fit: BoxFit.cover, color: !filtered?null:Colors.redAccent),
      )
    ],
  );
}

Widget buildTriple(double leftwidth, double rightwidth, List<Uint8List> images, bool isinLoading, bool filtered){
  return Row(
    children: [
      Container(width: leftwidth, height: leftwidth, color: AppColors.fieldFillColor,
        child: isinLoading? const Align(alignment: Alignment.bottomCenter,
          child: LinearCappedProgressIndicator(
            backgroundColor: Colors.black26,
            color: Colors.black,
            cornerRadius: 0,
          ),): Image.memory(images[0], fit: BoxFit.cover, color: !filtered?null:Colors.redAccent),
      ),
      const SizedBox(width: 2),
      Column(children: [
        Container(width: rightwidth, height: leftwidth/2-2, color: AppColors.fieldFillColor,
          child: isinLoading? const Align(alignment: Alignment.bottomCenter,
            child: LinearCappedProgressIndicator(
              backgroundColor: Colors.black26,
              color: Colors.black,
              cornerRadius: 0,
            ),): Image.memory(images[1], fit: BoxFit.cover, color: !filtered?null:Colors.redAccent),
        ),
        const SizedBox(height: 2),
        Container(width: rightwidth, height: leftwidth/2-1, color: AppColors.fieldFillColor,
          child: isinLoading? const Align(alignment: Alignment.bottomCenter,
            child: LinearCappedProgressIndicator(
              backgroundColor: Colors.black26,
              color: Colors.black,
              cornerRadius: 0,
            ),): Image.memory(images[2], fit: BoxFit.cover, color: !filtered?null:Colors.redAccent),
        ),
      ],)
    ],
  );
}

Widget buildTripleReverce(double leftwidth, double rightwidth, List<Uint8List> images, bool isinLoading, bool filtered){
  return Row(
    children: [
      Column(children: [
        Container(width: rightwidth, height: leftwidth/2-2, color: AppColors.fieldFillColor,
          child: isinLoading? const Align(alignment: Alignment.bottomCenter,
            child: LinearCappedProgressIndicator(
              backgroundColor: Colors.black26,
              color: Colors.black,
              cornerRadius: 0,
            ),): Image.memory(images[1], fit: BoxFit.cover, color: !filtered?null:Colors.redAccent),
        ),
        const SizedBox(height: 2),
        Container(width: rightwidth, height: leftwidth/2-1, color: AppColors.fieldFillColor,
          child: isinLoading? const Align(alignment: Alignment.bottomCenter,
            child: LinearCappedProgressIndicator(
              backgroundColor: Colors.black26,
              color: Colors.black,
              cornerRadius: 0,
            ),): Image.memory(images[2], fit: BoxFit.cover, color: !filtered?null:Colors.redAccent),
        ),
      ],),
      const SizedBox(width: 2),
      Container(width: leftwidth, height: leftwidth, color: AppColors.fieldFillColor,
        child: isinLoading? const Align(alignment: Alignment.bottomCenter,
          child: LinearCappedProgressIndicator(
            backgroundColor: Colors.black26,
            color: Colors.black,
            cornerRadius: 0,
          ),): Image.memory(images[0], fit: BoxFit.cover, color: !filtered?null:Colors.redAccent),
      )
    ],
  );
}
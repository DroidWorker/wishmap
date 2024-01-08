import 'dart:ffi';
import 'dart:typed_data';

import 'package:capped_progress_indicator/capped_progress_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../res/colors.dart';

Widget buildSingle(double width, Uint8List image, bool isinLoading, bool filtered, {int? imageId, Function(int index)? onTap}){
  return InkWell(
    onTap: (){if(onTap!=null&&imageId!=null)onTap(imageId);},
    child: Container(width: width, height: width/2, color: AppColors.fieldFillColor,
      child: isinLoading? const Align(alignment: Alignment.bottomCenter,
        child: LinearCappedProgressIndicator(
          backgroundColor: Colors.black26,
          color: Colors.black,
          cornerRadius: 0,
        ),): Image.memory(image, fit: BoxFit.cover, color: !filtered?null:Colors.redAccent),
    ),
  );
}
Widget buildTwin(double leftwidth, double rightwidth, Map<Uint8List, int?> images, bool isinLoading, bool filtered, {Function(int index)? onTap}){
  return Row(
    children: [
      InkWell(
        onTap: (){if(onTap!=null)onTap(images.values.toList()[0]!);},
        child: Container(width: leftwidth, height: leftwidth, color: AppColors.fieldFillColor,
          child: isinLoading? const Align(alignment: Alignment.bottomCenter,
            child: LinearCappedProgressIndicator(
              backgroundColor: Colors.black26,
              color: Colors.black,
              cornerRadius: 0,
            ),): Image.memory(images.keys.toList()[0], fit: BoxFit.cover, color: !filtered?null:Colors.redAccent),
        ),
      ),
      InkWell(
        onTap: (){if(onTap!=null)onTap(images.values.toList()[1]!);},
        child: Container(width: rightwidth, height: leftwidth, color: AppColors.fieldFillColor,
          child: isinLoading? const Align(alignment: Alignment.bottomCenter,
            child: LinearCappedProgressIndicator(
              backgroundColor: Colors.black26,
              color: Colors.black,
              cornerRadius: 0,
            ),): Image.memory(images.keys.toList()[1], fit: BoxFit.cover, color: !filtered?null:Colors.redAccent),
        ),
      )
    ],
  );
}

Widget buildTriple(double leftwidth, double rightwidth, Map<Uint8List, int?> images, bool isinLoading, bool filtered, {Function(int index)? onTap}){
  return Row(
    children: [
      InkWell(
        onTap: (){if(onTap!=null)onTap(images.values.toList()[0]!);},
        child: Container(width: leftwidth, height: leftwidth, color: AppColors.fieldFillColor,
          child: isinLoading? const Align(alignment: Alignment.bottomCenter,
            child: LinearCappedProgressIndicator(
              backgroundColor: Colors.black26,
              color: Colors.black,
              cornerRadius: 0,
            ),): Image.memory(images.keys.toList()[0], fit: BoxFit.cover, color: !filtered?null:Colors.redAccent),
        ),
      ),
      const SizedBox(width: 2),
      Column(children: [
        InkWell(
          onTap: (){if(onTap!=null)onTap(images.values.toList()[1]!);},
          child: Container(width: rightwidth, height: leftwidth/2-2, color: AppColors.fieldFillColor,
            child: isinLoading? const Align(alignment: Alignment.bottomCenter,
              child: LinearCappedProgressIndicator(
                backgroundColor: Colors.black26,
                color: Colors.black,
                cornerRadius: 0,
              ),): Image.memory(images.keys.toList()[1], fit: BoxFit.cover, color: !filtered?null:Colors.redAccent),
          ),
        ),
        const SizedBox(height: 2),
        InkWell(
          onTap: (){if(onTap!=null)onTap(images.values.toList()[2]!);},
          child: Container(width: rightwidth, height: leftwidth/2-1, color: AppColors.fieldFillColor,
            child: isinLoading? const Align(alignment: Alignment.bottomCenter,
              child: LinearCappedProgressIndicator(
                backgroundColor: Colors.black26,
                color: Colors.black,
                cornerRadius: 0,
              ),): Image.memory(images.keys.toList()[2], fit: BoxFit.cover, color: !filtered?null:Colors.redAccent),
          ),
        ),
      ],)
    ],
  );
}

Widget buildTripleReverce(double leftwidth, double rightwidth, Map<Uint8List, int?> images, bool isinLoading, bool filtered, {Function(int index)? onTap}){
  return Row(
    children: [
      Column(children: [
        InkWell(
          onTap: (){if(onTap!=null)onTap(images.values.toList()[0]!);},
          child: Container(width: rightwidth, height: leftwidth/2-2, color: AppColors.fieldFillColor,
            child: isinLoading? const Align(alignment: Alignment.bottomCenter,
              child: LinearCappedProgressIndicator(
                backgroundColor: Colors.black26,
                color: Colors.black,
                cornerRadius: 0,
              ),): Image.memory(images.keys.toList()[1], fit: BoxFit.cover, color: !filtered?null:Colors.redAccent),
          ),
        ),
        const SizedBox(height: 2),
        InkWell(
          onTap: (){if(onTap!=null)onTap(images.values.toList()[1]!);},
          child: Container(width: rightwidth, height: leftwidth/2-1, color: AppColors.fieldFillColor,
            child: isinLoading? const Align(alignment: Alignment.bottomCenter,
              child: LinearCappedProgressIndicator(
                backgroundColor: Colors.black26,
                color: Colors.black,
                cornerRadius: 0,
              ),): Image.memory(images.keys.toList()[2], fit: BoxFit.cover, color: !filtered?null:Colors.redAccent),
          ),
        ),
      ],),
      const SizedBox(width: 2),
      InkWell(
        onTap: (){if(onTap!=null)onTap(images.values.toList()[2]!);},
        child: Container(width: leftwidth, height: leftwidth, color: AppColors.fieldFillColor,
          child: isinLoading? const Align(alignment: Alignment.bottomCenter,
            child: LinearCappedProgressIndicator(
              backgroundColor: Colors.black26,
              color: Colors.black,
              cornerRadius: 0,
            ),): Image.memory(images.keys.toList()[0], fit: BoxFit.cover, color: !filtered?null:Colors.redAccent),
        ),
      )
    ],
  );
}
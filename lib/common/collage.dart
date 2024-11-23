import 'dart:typed_data';

import 'package:capped_progress_indicator/capped_progress_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wishmap/interface_widgets/galleriPhotoContainer.dart';

import '../res/colors.dart';

Widget buildSingle(double width, Uint8List image, bool isinLoading, bool filtered, {int? imageId, Function(int index)? onTap}){
  return InkWell(
    onTap: (){if(onTap!=null&&imageId!=null)onTap(imageId);},
    child: Container(width: width+9, height: width/2, color: AppColors.fieldFillColor, padding: const EdgeInsets.only(top: 9),
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
  return Container(
    padding: const EdgeInsets.only(top: 9),
    child: Row(
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
        const SizedBox(width: 9),
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
    ),
  );
}

Widget buildTriple(double leftwidth, double rightwidth, Map<Uint8List, int?> images, bool isinLoading, bool filtered, {Function(int index)? onTap}){
  return Container(
    padding: const EdgeInsets.only(top: 9),
    child: Row(
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
        const SizedBox(width: 9),
        Column(children: [
          InkWell(
            onTap: (){if(onTap!=null)onTap(images.values.toList()[1]!);},
            child: Container(width: rightwidth, height: leftwidth/2-4, color: AppColors.fieldFillColor,
              child: isinLoading? const Align(alignment: Alignment.bottomCenter,
                child: LinearCappedProgressIndicator(
                  backgroundColor: Colors.black26,
                  color: Colors.black,
                  cornerRadius: 0,
                ),): Image.memory(images.keys.toList()[1], fit: BoxFit.cover, color: !filtered?null:Colors.redAccent),
            ),
          ),
          const SizedBox(height: 9),
          InkWell(
            onTap: (){if(onTap!=null)onTap(images.values.toList()[2]!);},
            child: Container(width: rightwidth, height: leftwidth/2-4, color: AppColors.fieldFillColor,
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
    ),
  );
}

Widget buildTripleReverce(double leftwidth, double rightwidth, Map<Uint8List, int?> images, bool isinLoading, bool filtered, {Function(int index)? onTap}){
  return Container(
    padding: const EdgeInsets.only(top: 9),
    child: Row(
      children: [
        Column(
          children: [
          InkWell(
            onTap: (){if(onTap!=null)onTap(images.values.toList()[1]!);},
            child: Container(width: rightwidth, height: leftwidth/2-4, color: AppColors.fieldFillColor,
              child: isinLoading? const Align(alignment: Alignment.bottomCenter,
                child: LinearCappedProgressIndicator(
                  backgroundColor: Colors.black26,
                  color: Colors.black,
                  cornerRadius: 0,
                ),): Image.memory(images.keys.toList()[1], fit: BoxFit.cover, color: !filtered?null:Colors.redAccent),
            ),
          ),
          const SizedBox(height: 9),
          InkWell(
            onTap: (){if(onTap!=null)onTap(images.values.toList()[2]!);},
            child: Container(width: rightwidth, height: leftwidth/2-4, color: AppColors.fieldFillColor,
              child: isinLoading? const Align(alignment: Alignment.bottomCenter,
                child: LinearCappedProgressIndicator(
                  backgroundColor: Colors.black26,
                  color: Colors.black,
                  cornerRadius: 0,
                ),): Image.memory(images.keys.toList()[2], fit: BoxFit.cover, color: !filtered?null:Colors.redAccent),
            ),
          ),
        ],),
        const SizedBox(width: 9),
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
      ],
    ),
  );
}
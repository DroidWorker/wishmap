import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:voice_message_package/voice_message_package.dart';

import '../data/models.dart';
import '../interface_widgets/custom_textfield.dart';
import '../res/colors.dart';

class DiaryArticleItem extends StatelessWidget{
  final Article article;
  List<String> images = [];
  List<String> records = [];

  DiaryArticleItem(this.article, {super.key});

  @override
  Widget build(BuildContext context) {
    if(article.attachments.isNotEmpty) {
      for (var element in article.attachments) {
      if(element.isNotEmpty)element.contains(".photo")||element.contains(".jpg")?images.add(element):records.add(element);
    }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(article.date, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(article.time, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w400)),
                      buildRichText(article.text, []),
                      if(images.isNotEmpty||records.isNotEmpty)const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Divider(color: AppColors.grey, height: 2,),
                      ),
                      Row(children: [
                        ...images.map((e) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 4.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.file(File(e), fit: BoxFit.cover, width: 50, height: 50,),
                            )
                          );
                        })
                      ],),
                      if(records.isNotEmpty)ListView.builder(
                            shrinkWrap: true,
                            itemCount: records.length,
                            itemBuilder: (BuildContext context, int index){
                              print("play - ${records[index]}");
                              return VoiceMessageView(controller: VoiceController(
                                audioSrc: records[index],
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
                                circlesColor: AppColors.gradientEnd,);
                            }),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
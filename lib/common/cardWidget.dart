import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wishmap/data/models.dart';

class CardWidget extends StatelessWidget {
  final CardData data;

  CardWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0), // Установите желаемый радиус скругления
      ),
      color: data.color,
      margin: const EdgeInsets.all(4.0),
        child: Center(
            child: Column(
              children: [
                const SizedBox(height: 3,),
                Text(data.emoji,style: const TextStyle(fontSize: 36),),
                Text(data.title,style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(data.description,style: const TextStyle(fontSize: 13))
              ],
            )),
    );
  }
}
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wishmap/data/models.dart';

class CardWidget extends StatelessWidget {
  final CardData data;

  CardWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Colors.white
      ),
      margin: const EdgeInsets.all(4.0),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 3,),
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(7)), color: data.color),
                      child: Center(child: Text(data.emoji,style: const TextStyle(fontSize: 26),))
                  ),
                  const SizedBox(height: 8),
                  Text(data.title,style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(data.description, maxLines: 3, overflow: TextOverflow.ellipsis, softWrap: true, style: const TextStyle(fontSize: 12))
                ],
              ),
        ),
    );
  }
}
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget getButton(String num){
  return Container(width: 50, height: 50,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
        color: Colors.black12.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25)
    ),
    child: Center(child: Text(num, style: const TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.w600))),
  );
}
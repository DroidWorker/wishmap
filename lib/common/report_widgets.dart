import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../res/colors.dart';

Widget SphereButtonItem(Color boxBGColor, int percentValue, String sphereName,
    Function() onClick) {
  return GestureDetector(
    onTap: () {
      onClick();
    },
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.grey)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: boxBGColor, borderRadius: BorderRadius.circular(10)),
            width: 77,
            height: 50,
            child: Center(
              child: Text("${percentValue.toString()}%",
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ),
          ),
          Text(sphereName),
          const Spacer(),
          const Icon(Icons.keyboard_arrow_right, size: 28),
          const SizedBox(width: 5)
        ],
      ),
    ),
  );
}
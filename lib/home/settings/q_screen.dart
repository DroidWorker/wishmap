import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/ViewModel.dart';
import 'package:wishmap/common/ExpandableTextItem.dart';

import '../../navigation/navigation_block.dart';
import '../../res/colors.dart';

class QScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
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
                const Text("Частые вопросы",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(width: 30)
              ],
            ),
            Consumer<AppViewModel>(builder: (context, appVM, child) {
              final q = appVM.questions.keys.toList();
              final answer = appVM.questions.values.toList();
              return Expanded(
                child: SingleChildScrollView(
                    child: ListView.builder(
                      shrinkWrap: true,
                        itemCount: q.length,
                        itemBuilder: (context, index) {
                          return ExpandableTextWidget(q[index], answer[index]);
                        })),
              );
            })
                    ],
                  ),
          )),
    );
  }
}

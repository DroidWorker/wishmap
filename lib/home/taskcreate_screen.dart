import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../ViewModel.dart';
import '../data/models.dart';
import '../navigation/navigation_block.dart';
import '../res/colors.dart';

class TaskScreen extends StatelessWidget {
  int parentAimId = 0;
  TaskScreen({super.key, required this.parentAimId});

  @override
  Widget build(BuildContext context) {
    final appViewModel = Provider.of<AppViewModel>(context);
    final TextEditingController text = TextEditingController();
    final TextEditingController description = TextEditingController();

    return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(child:SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Задача",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.greytextColor),
                        ),
                      ),
                    ),
                    Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          child: const Text(
                            "Сохранить",
                            style: TextStyle(color: AppColors.blueTextColor),
                          ),
                          onTap: () async {
                            int? taskId = await appViewModel.createTask(TaskData(id: 999, text: text.text, description: description.text), parentAimId);
                            if(taskId!=null) {
                              BlocProvider.of<NavigationBloc>(context)
                                  .add(NavigateToTaskEditScreenEvent(taskId));
                            }else{
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Ошибка сохранения'),
                                  duration: Duration(
                                      seconds: 3), // Установите желаемую продолжительность отображения
                                ),
                              );
                            }
                          },
                        )
                    ),
                  ],
                ),
                const Divider(
                  height: 3,
                  color: AppColors.dividerGreyColor,
                  indent: 5,
                  endIndent: 5,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: text,
                  style: const TextStyle(color: Colors.black), // Черный текст ввода
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.fieldFillColor,
                      hintText: 'Название цели',
                      hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
                      border: InputBorder.none
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: description,
                  minLines: 4,
                  maxLines: 15,
                  style: const TextStyle(color: Colors.black), // Черный текст ввода
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.fieldFillColor,
                      hintText: 'Опиши подробно свое желание',
                      hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
                      border: InputBorder.none
                  ),
                ),
                ],
            ),),
        ))
    );
  }
}
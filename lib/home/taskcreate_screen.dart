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
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blueButtonBack,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  10), // <-- Radius
                            ),
                          ),
                          onPressed: () async {
                            int? taskId = await appViewModel.createTask(TaskData(id: 999, parentId: parentAimId, text: text.text, description: description.text), parentAimId);
                            if(taskId!=null) {
                              showDialog(context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: const Text('сохранено'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () { Navigator.pop(context, 'OK');
                                      BlocProvider.of<NavigationBloc>(context)
                                          .add(NavigateToTaskEditScreenEvent(taskId));},
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );

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
                          child: const Text("Сохранить")
                      ),
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
                      hintText: 'Название задачи',
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
                      hintText: 'Опиши подробно свою задачу',
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

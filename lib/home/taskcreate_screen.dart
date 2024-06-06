import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';
import 'package:provider/provider.dart';
import '../ViewModel.dart';
import '../common/EditTextOverlay.dart';
import '../data/models.dart';
import '../dialog/bottom_sheet_action.dart';
import '../dialog/bottom_sheet_notify.dart';
import '../interface_widgets/colorButton.dart';
import '../navigation/navigation_block.dart';
import '../res/colors.dart';

class TaskScreen extends StatefulWidget {
  int parentAimId = 0;

  TaskScreen({super.key, required this.parentAimId});
  @override
  TaskScreenState createState() => TaskScreenState();
}

class TaskScreenState extends State<TaskScreen>{
  final TextEditingController text = TextEditingController();
  final TextEditingController description = TextEditingController();
  bool taskCreateClicked = false;
  @override
  Widget build(BuildContext context) {
    final appViewModel = Provider.of<AppViewModel>(context);
    return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
            maintainBottomViewPadding: true,
            child:Column(children:[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                    constraints: const BoxConstraints(),
                    style: const ButtonStyle(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap, // the '2023' part
                    ),
                    icon: const Icon(Icons.keyboard_arrow_left, size: 28, color: AppColors.gradientStart),
                    onPressed: () {
                      if(text.text.isNotEmpty&&!taskCreateClicked){
                        showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          builder: (BuildContext context) {
                            return ActionBS('Внимание', "Вы изменили поля но не нажали 'Сохранить'\nСохранить изменения?", "Да", 'Нет',
                                onOk: () async { Navigator.pop(context, 'OK');
                                await onSaveClicked(appViewModel);
                                BlocProvider.of<NavigationBloc>(context)
                                    .handleBackPress();
                                },
                                onCancel: () { Navigator.pop(context, 'Cancel');
                                BlocProvider.of<NavigationBloc>(context)
                                    .handleBackPress();
                                });
                          },
                        );
                        }else{
                        BlocProvider.of<NavigationBloc>(context)
                            .handleBackPress();
                      }
                    },
                  ),
                  const Text("Новая задача", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(width: 30, height: 40)
                ],
              ),
              Expanded(child:SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: text,
                  style: const TextStyle(color: Colors.black), // Черный текст ввода
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 19),
                    filled: true,
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 2,
                    ),
                    suffixIcon: const Text("*", style: TextStyle(fontSize: 30, color: AppColors.greytextColor)),
                    fillColor: Colors.white,
                    hintText: 'Название',
                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        width: 0,
                        style: BorderStyle.none,
                      ),
                    ),
                  )
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: description,
                  minLines: 4,
                  maxLines: 15,
                  onTap: () async {
                    final returnedText = await showOverlayedEdittext(context, description.text, true)??"";
                    if(returnedText!=description.text) {
                      description.text = returnedText;
                    }
                  },
                  showCursor: false,
                  readOnly: true,
                  style: const TextStyle(color: Colors.black), // Черный текст ввода
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 19),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        width: 0,
                        style: BorderStyle.none,
                      ),
                    ),
                    filled: true, // Заливка фона
                    fillColor: Colors.white,
                    hintText: 'Описание', // Базовый текст
                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)), // Полупрозрачный черный базовый текст
                  ),
                ),
                ],
            ),),
        )),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ColorRoundedButton("Сохранить", () async {
                  if(!taskCreateClicked){
                    taskCreateClicked = true;
                    await onSaveClicked(appViewModel);
                  }
                }
                ),
              ),
              if(MediaQuery.of(context).viewInsets.bottom!=0) Align(
                alignment: Alignment.topRight,
                child: Container(height: 50, width: 50,
                    margin: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ), child:
                    GestureDetector(
                      onTap: (){FocusManager.instance.primaryFocus?.unfocus();},
                      child: const Icon(Icons.keyboard_hide_sharp, size: 30, color: AppColors.darkGrey,),
                    )
                ),
              )
            ])
        ),
    );
  }

  Future<void> onSaveClicked(AppViewModel appViewModel) async {
    if (text.text.isEmpty) {
      taskCreateClicked=false;
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return NotifyBS('Заполните поля', "", 'OK',
              onOk: () => Navigator.pop(context, 'OK'));
        },
      );
    }else {
      int? taskId = await appViewModel.createTask(TaskData(id: 999,
          parentId: widget.parentAimId,
          text: text.text,
          description: description.text), widget.parentAimId);
      if (taskId != null) {
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return NotifyBS('сохранено', "", 'OK',
                onOk: () => Navigator.pop(context, 'OK'));
          },
        ).then((value) {
          BlocProvider.of<NavigationBloc>(context).removeLastFromBS();
          BlocProvider.of<NavigationBloc>(context)
              .add(NavigateToTaskEditScreenEvent(taskId));
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ошибка сохранения'),
            duration: Duration(
                seconds: 3), // Установите желаемую продолжительность отображения
          ),
        );
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/data/models.dart';
import '../ViewModel.dart';
import '../navigation/navigation_block.dart';
import '../res/colors.dart';

class AimScreen extends StatelessWidget {
  int parentCircleId = 0;
  AimScreen({super.key, required this.parentCircleId});
  final TextEditingController text = TextEditingController();
  final TextEditingController description = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final appViewModel = Provider.of<AppViewModel>(context);

    return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
            maintainBottomViewPadding: true,
            child:Column(children:[Expanded(child:SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_left),
                      iconSize: 30,
                      onPressed: () {
                        BlocProvider.of<NavigationBloc>(context)
                            .handleBackPress();
                      },
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.greyBackButton,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                          ),
                          onPressed: () async {
                            if(text.text.isEmpty||description.text.isEmpty){
                              showDialog(context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: const Text('Заполните поля', textAlign: TextAlign.center,),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () { Navigator.pop(context, 'OK');},
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                              return;
                            }
                            int? aimId = await appViewModel.createAim(AimData(id: 999, parentId: parentCircleId, text: text.text, description: description.text), parentCircleId);
                            if(aimId!=null) {
                              showDialog(context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: const Text('сохранено'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () { Navigator.pop(context, 'OK');
                                        BlocProvider.of<NavigationBloc>(context).removeLastFromBS();
                                      BlocProvider.of<NavigationBloc>(context)
                                          .add(NavigateToAimEditScreenEvent(aimId));},
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
                          child: const Text("Сохранить цель", style: TextStyle(color: AppColors.blueButtonTextColor))
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
                const SizedBox(height: 10),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.fieldFillColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // <-- Radius
                      ),
                    ),
                    onPressed: (){
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Необходимо сохранить цель'),
                            duration: Duration(
                                seconds: 3), // Установите желаемую продолжительность отображения
                          ),
                        );
                    },
                    child: const Text("Создать задачу", style: TextStyle(color: AppColors.greytextColor),)
                ),
                const SizedBox(height: 5),
                const Text("Укажи задачу дня для достижения цели. Помни! Задача актуальна 24 часа", style: TextStyle(fontSize: 10, color: AppColors.greytextColor),)
                ],
            ),),
        )), if(MediaQuery.of(context).viewInsets.bottom!=0) SizedBox(height: 30,
              child: FooterLayout(
                footer: Container(height: 30,color: Colors.white,alignment: Alignment.centerRight, child:
                GestureDetector(
                  onTap: (){FocusManager.instance.primaryFocus?.unfocus();},
                  child: const Text("готово", style: TextStyle(fontSize: 20),),
                )
                  ,),
              ),)])
    ));
  }
}

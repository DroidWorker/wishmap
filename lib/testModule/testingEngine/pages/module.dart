import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/interface_widgets/colorButton.dart';
import 'package:wishmap/interface_widgets/outlined_button.dart';

import 'package:wishmap/res/colors.dart';

import '../../../navigation/navigation_block.dart';
import '../ViewModel.dart';
import '../data/models.dart';

class Module1 extends StatefulWidget {
  const Module1({super.key});

  Module1State createState() => Module1State();
}

class Module1State extends State {
  late TestViewModel vm;
  List<Question> questions = [];
  var maxStep = 21;

  @override
  void initState() {
    super.initState();
    // Получаем экземпляр ViewModel
    vm = Provider.of<TestViewModel>(context, listen: false);

    // Вызываем методы во ViewModel только один раз
    vm.getmoduleName();
    vm.getQuestions();
    vm.ansversM1.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TestViewModel>(builder: (context, viewModel, child) {
      questions = viewModel.questionsAndKoeffs;
      var step = viewModel.step;
      if (questions.isNotEmpty) maxStep = questions.length;

      return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          appBar: AppBar(
            backgroundColor: AppColors.backgroundColor,
            scrolledUnderElevation: 0,
            toolbarHeight: 50,
            title: Row(
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
                      if(step!=1){
                        setState(() {
                          viewModel.ansversM1.removeLast();
                            viewModel.step--;
                        });
                      }else {
                        BlocProvider.of<NavigationBloc>(context)
                          .handleBackPress();
                      }
                    }),
                Text(viewModel.moduleName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(width: 29)
              ],
            ),
          ),
          body: SafeArea(
            child: LayoutBuilder(builder: (context, constraints) {
              return Container(
                  width: constraints.maxWidth,
                  color: AppColors.backgroundColor,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Утверждение $step из $maxStep (${(step * 100) ~/ maxStep}%)',
                          // Текст внутри progress bar
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                          height: 20,
                          child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10.0)),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: LinearProgressIndicator(
                                      minHeight: 10,
                                      value: (step) / questions.length,
                                      // Пример: 0.5 означает 50% заполнения
                                      backgroundColor: buttonGrey,
                                      // Прозрачный фон для видимости границ
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          progressColor),
                                    ),
                                  ),
                                ],
                              ))),
                      const SizedBox(
                        height: 30,
                      ),
                      const Text(
                        'Оцените утверждение ниже',
                        textAlign: TextAlign.left,
                        style: TextStyle(color: AppColors.greytextColor),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        "Yтверждение:",
                        style: TextStyle(fontSize: 18),
                      ),
                      Expanded(
                        child: AutoSizeText(
                          questions.isNotEmpty
                              ? "\"${questions[step - 1].question}\""
                              : "",
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      //const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          OutlinedGradientButton(
                            questions.isNotEmpty
                                ? questions[step - 1].answers[0]
                                : 'Согласен',
                            () {
                              setState(() {
                                viewModel.ansversM1.add(1);
                                if (step != maxStep) {
                                  viewModel.step++;
                                } else {
                                  viewModel.calculateResult();
                                  BlocProvider.of<NavigationBloc>(context).handleBackPress();
                                  BlocProvider.of<NavigationBloc>(context)
                                      .add(NavigateToReport1ScreenEvent());
                                }
                              });
                            },
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          OutlinedGradientButton(
                              questions.isNotEmpty
                                  ? questions[step - 1].answers[1]
                                  : 'Скорее согласен', () {
                            setState(() {
                              viewModel.ansversM1.add(0.75);
                              if (step != maxStep) {
                                viewModel.step++;
                              } else {
                                viewModel.calculateResult();
                                BlocProvider.of<NavigationBloc>(context).handleBackPress();
                                BlocProvider.of<NavigationBloc>(context)
                                    .add(NavigateToReport1ScreenEvent());
                              }
                            });
                          }),
                          const SizedBox(
                            height: 8,
                          ),
                          OutlinedGradientButton(
                            questions.isNotEmpty
                                ? questions[step - 1].answers[2]
                                : 'Нечто среднее',
                            () {
                              setState(() {
                                viewModel.ansversM1.add(0.5);
                                if (step != maxStep) {
                                  viewModel.step++;
                                } else {
                                  viewModel.calculateResult();
                                  BlocProvider.of<NavigationBloc>(context).handleBackPress();
                                  BlocProvider.of<NavigationBloc>(context)
                                      .add(NavigateToReport1ScreenEvent());
                                }
                              });
                            },
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          OutlinedGradientButton(
                            questions.isNotEmpty
                                ? questions[step - 1].answers[3]
                                : 'Скорее не согласен',
                            () {
                              setState(() {
                                viewModel.ansversM1.add(0.25);
                                if (step != maxStep) {
                                  viewModel.step++;
                                } else {
                                  viewModel.calculateResult();
                                  BlocProvider.of<NavigationBloc>(context).handleBackPress();
                                  BlocProvider.of<NavigationBloc>(context)
                                      .add(NavigateToReport1ScreenEvent());
                                }
                              });
                            },
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          OutlinedGradientButton(
                            questions.isNotEmpty
                                ? questions[step - 1].answers[4]
                                : 'Не согласен',
                            () {
                              setState(() {
                                viewModel.ansversM1.add(0);
                                if (step != maxStep) {
                                  viewModel.step++;
                                } else {
                                  viewModel.calculateResult();
                                  BlocProvider.of<NavigationBloc>(context).handleBackPress();
                                  BlocProvider.of<NavigationBloc>(context)
                                      .add(NavigateToReport1ScreenEvent());
                                }
                              });
                            },
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                        ],
                      ),
                      //const Spacer(),
                      const Text(
                        "Возможности кинезиологического теста",
                        style: TextStyle(
                            color: AppColors.gold,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                          "Это поможет тебе определить, какие жизненные проекты и желания для тебя наиболее актуальны, какие изменения на пути к их реализации принесут наибольшую пользу."),
                      const SizedBox(height: 10),
                      if (!viewModel.kinClicked)
                        ColorRoundedButton("Важность кинезиологический теста",
                            () {
                          viewModel.kinClicked= true;
                          BlocProvider.of<NavigationBloc>(context)
                              .add(NavigateToKinScreenEvent());
                        })
                      else
                        OutlinedGradientButton(
                            "Важность кинезиологический теста", () {
                          BlocProvider.of<NavigationBloc>(context)
                              .add(NavigateToKinScreenEvent());
                        })
                    ],
                  ));
            }),
          ));
    });
  }
}

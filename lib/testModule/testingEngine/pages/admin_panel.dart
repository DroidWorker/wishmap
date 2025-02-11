import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cross_scroll/cross_scroll.dart';

import 'package:wishmap/res/colors.dart';
import '../../toolWidgets/hokins_distribution_for_question_edit.dart';
import '../../toolWidgets/indexes_edit_table.dart';
import '../ViewModel.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  AdminPanelState createState() => AdminPanelState();
}
class AdminPanelState extends State {
  bool isVideoVisible = true;
  int expandedIndex = -1;
  @override
  Widget build(BuildContext context) {
    final ScrollController _vertical = ScrollController();

    List<double> qSummWeight = [100,100,100,100,100,100,100,100,100];

    TestViewModel vm = Provider.of<TestViewModel>(context, listen: false);
    if (vm.questionsAndKoeffs.isEmpty) vm.getQuestions();
    if (vm.hokinsKoefs.isEmpty) vm.getHokinsKoefs();

    return Consumer<TestViewModel>(
      builder: (context, viewModel, child) {
        final questions = viewModel.questionsAndKoeffs;
        final List<List<String>> answ = questions.map((e) => e.answers).toList();
        final hokinsKoefs = viewModel.hokinsKoefs;

        return questions.isNotEmpty&&hokinsKoefs.isNotEmpty
            ? Scaffold(
          appBar: AppBar(
            backgroundColor: appbarColor,
            scrolledUnderElevation: 0,
            toolbarHeight: 90,
            title: Center(
              child: Image.asset(
                'assets/res/images/logo.png',
                height: 90,
              ),
            ),
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return CrossScroll(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: constraints.maxWidth,
                            color: bgMainColor,
                            padding: constraints.maxWidth > 600
                                ? const EdgeInsets.all(20.0)
                                : const EdgeInsets.all(4.0),
                            child: Column(
                              children: [
                                const Center(
                                  child: Text(
                                    'Настройки: Модуль 1 - Сферы жизни',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                                const SizedBox(height: 40),
                                const Text("Настройки текста и веса вопросов"),
                                const SizedBox(height: 30),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: constraints.maxWidth > 600
                                          ? ((constraints.maxWidth - 40) * 0.6)
                                          : ((constraints.maxWidth - 10) * 0.6),
                                      child: Text("Текст вопроса"),
                                    ),
                                    Text("Вес вопроса в %")
                                  ],
                                ),
                               SizedBox(width:constraints.maxWidth-40, child: EditableTable(maxWidth: constraints.maxWidth, questions: questions, onValueUpdate: (values){setState(() {
                                 qSummWeight = values;
                               });},)),
                                Row(
                                  children: [
                                    SizedBox(
                                        width: constraints.maxWidth > 600
                                            ? ((constraints.maxWidth - 200) * 0.4)
                                            : ((constraints.maxWidth - 40) * 0.4)),
                                    const Text(
                                        "Итоговый вес всех вопросов по каждому критерию"),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child:Text("Число вопросов = ${questions.length}")),
                                    Expanded(flex: 2,
                                      child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text("здоровье\n${qSummWeight[0]}", maxLines: 2, textAlign: TextAlign.center),
                                        Text("Отношения\n${qSummWeight[1]}", maxLines: 2, textAlign: TextAlign.center),
                                        Text("Окружение\n${qSummWeight[2]}", maxLines: 2, textAlign: TextAlign.center),
                                        Text("Призвание\n${qSummWeight[3]}", maxLines: 2, textAlign: TextAlign.center),
                                        Text("Богатство\n${qSummWeight[4]}", maxLines: 2, textAlign: TextAlign.center),
                                        Text("Саморазвитие\n${qSummWeight[5]}", maxLines: 2, textAlign: TextAlign.center),
                                        Text("Яркость жизни\n${qSummWeight[6]}", maxLines: 2, textAlign: TextAlign.center),
                                        Text("Духовность\n${qSummWeight[7]}", maxLines: 2, textAlign: TextAlign.center),
                                      ],
                                    ),)
                                  ],
                                ),
                                const SizedBox(height: 30),
                                ...questions.map((e) => Column(children:[
                                  Row(children: [Text(e.question), IconButton(onPressed: (){setState(() {expandedIndex=questions.indexOf(e);});}, icon: const Icon(Icons.arrow_drop_down))],),
                                  if(expandedIndex==questions.indexOf(e)) SizedBox(width:constraints.maxWidth-40, child: HokinsDistributionForQuestionEdit(answers: e.answers, koeffs: hokinsKoefs[expandedIndex]))
                                ])),
                                const SizedBox(height: 50),
                                Center(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Ваша логика для кнопки
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.yellow,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    child: const Text(
                                      "Сохранить",
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            height: 100,
                            color: footerColor,
                          )
                        ],
                      ),
              );
            },
          ),
        )
            : inCalculating();
      },
    );
  }

  Widget inCalculating() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appbarColor,
        scrolledUnderElevation: 0,
        toolbarHeight: 90,
        title: Center(
          child: Image.asset(
            'assets/res/images/logo.png',
            height: 90,
          ),
        ),
      ),
      body: const Center(
        child: Text("Preparing..."),
      ),
    );
  }
}
